################################################################################
#
# Stat related items.
#
################################################################################

#===============================================================================
# Stat boosting items (X Attack, X Defense, etc.)
#===============================================================================
Battle::AI::Handlers::BattlerItemEffectScore.add(:XATTACK,
  proc { |item, score, battler, ai, battle|
    old_score = score
    #---------------------------------------------------------------------------
    # Stat raising berries. Included for Item Urge compatibility.
    stat_berries = {
      :LIECHIBERRY  => [:ATTACK,          1],
      :GANLONBERRY  => [:DEFENSE,         1],
      :KEEBERRY     => [:DEFENSE,         1],
      :PETAYABERRY  => [:SPECIAL_ATTACK,  1],
      :APICOTBERRY  => [:SPECIAL_DEFENSE, 1],
      :MARANGABERRY => [:SPECIAL_DEFENSE, 1],
      :SALACBERRY   => [:SPEED,           1]
    }
    #---------------------------------------------------------------------------
    # Determines which stat to raise and the number of stages.
    if stat_berries.keys.include?(item)
      stat = stat_berries[item]
      stat[1] = stat[1] * 2 if battler.has_active_ability?(:RIPEN)
    else
      stat = Battle::AI::ONE_STAT_RAISE_ITEMS[item]
    end
    if !stat
      score = Battle::AI::ITEM_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because item doesn't raise any stats")
      next score
    end
    #---------------------------------------------------------------------------
    next ai.get_item_score_for_target_stat_change(score, battler, stat[0], stat[1])
  }
)

Battle::AI::Handlers::BattlerItemEffectScore.copy(:XATTACK,:XATTACK2,:XATTACK3,:XATTACK6,
                                                  :XDEFEND,:XDEFEND2,:XDEFEND3,:XDEFEND6,
                                                  :XDEFENSE,:XDEFENSE2,:XDEFENSE3,:XDEFENSE6,
                                                  :XSPATK,:XSPATK2,:XSPATK3,:XSPATK6,
                                                  :XSPECIAL,:XSPECIAL2,:XSPECIAL3,:XSPECIAL6,
                                                  :XSPDEF,:XSPDEF2,:XSPDEF3,:XSPDEF6,
                                                  :XSPEED,:XSPEED2,:XSPEED3,:XSPEED6,
                                                  :XACCURACY,:XACCURACY2,:XACCURACY3,:XACCURACY6,
                                                  :LIECHIBERRY, :GANLONBERRY, :KEEBERRY, 
                                                  :PETAYABERRY, :APICOTBERRY, :MARANGABERRY, :SALACBERRY)

#===============================================================================
# Max Mushrooms
#===============================================================================
Battle::AI::Handlers::BattlerItemEffectScore.add(:MAXMUSHROOMS,
  proc { |item, score, battler, ai, battle|
    tryScores = []
    tryItems = [:LIECHIBERRY, :GANLONBERRY, :PETAYABERRY, :APICOTBERRY, :SALACBERRY]
    old_score = score
    tryItems.each do |itm|
      tryScore = Battle::AI::Handlers.battler_item_score(itm, score, battler, ai, battle)
      tryScores.push(tryScore - old_score) if tryScore > Battle::AI::ITEM_USELESS_SCORE
    end
    score += tryScores.sum
    next score
  }
)

#===============================================================================
# Critical hit boosting items (Dire Hit)
#===============================================================================											  
Battle::AI::Handlers::BattlerItemEffectScore.add(:DIREHIT,
  proc { |item, score, battler, ai, battle|
    old_score = score
    #-------------------------------------------------------------------------
    # Determines critical hit stages.
    case item
    when :DIREHIT     then increment = 1
    when :DIREHIT2    then increment = 2
    when :DIREHIT3    then increment = 3
    when :LANSATBERRY then increment = 2
    end
    if !increment
      score = Battle::AI::ITEM_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because item doesn't raise critical hit ratio")
      next score
    end
    stages = battler.effects[PBEffects::FocusEnergy]
    if stages >= increment
      score = Battle::AI::ITEM_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because unable to raise #{battler.name}'s critical hit ratio")
      next score
    end
    if battler.rough_end_of_round_damage >= battler.hp
      score = Battle::AI::ITEM_USELESS_SCORE
      PBDebug.log_score_change(score - old_score, "useless because #{battler.name} predicted to faint this round")
      next score
    end
    if battler.item_active?
      if [:RAZORCLAW, :SCOPELENS].include?(battler.item_id) ||
         (battler.item_id == :LUCKYPUNCH && battler.battler.isSpecies?(:CHANSEY)) ||
         ([:LEEK, :STICK].include?(battler.item_id) &&
         (battler.battler.isSpecies?(:FARFETCHD) || battler.battler.isSpecies?(:SIRFETCHD)))
        stages += 1
      end
    end
    stages += 1 if battler.has_active_ability?(:SUPERLUCK)
    #---------------------------------------------------------------------------
    # Calculates the crit boosting score.
    desire_mult = (battler.opposes?(ai.trainer)) ? -1 : 1
    if stages < 3 && battler.check_for_move { |m| m.damagingMove? && m.pp > 0 }
      increment = [increment, 3 - stages].min
      score += 3 * increment
      if ai.trainer.has_skill_flag?("HPAware")
        score += increment * desire_mult * ((100 * battler.hp / battler.totalhp) - 50) / 8
      end
      if battler.stages[:ATTACK] < 0 && battler.check_for_move { |m| m.physicalMove? && m.pp > 0 }
        score += 8 * desire_mult
      end
      if battler.stages[:SPECIAL_ATTACK] < 0 && battler.check_for_move { |m| m.specialMove? && m.pp > 0 }
        score += 8 * desire_mult
      end
      score += 10 * desire_mult if battler.has_active_ability?(:SNIPER)
      score += 10 * desire_mult if stages < 2 && battler.check_for_move { |m| m.highCriticalRate? && m.pp > 0 }
      score -= 20 * desire_mult if battler.pbOpposingSide.effects[PBEffects::LuckyChant] > 0
      score -= 10 * desire_mult if battler.opponent_side_has_ability?([:ANGERPOINT, :BATTLEARMOR, :SHELLARMOR])
      if desire_mult > 0
        functions = [
          "FixedDamage",
          "AlwaysCriticalHit",
          "RaiseUserCriticalHitRate1",
          "RaiseUserCriticalHitRate2",
          "RaiseUserCriticalHitRate3"
        ]
        battler.moves.each do |m|
          next if m.pp == 0
          score -= 10 if functions.any? { |f| m.function_code.include?(f) }
        end
      end
      PBDebug.log_score_change(score - old_score, "raising #{battler.name}'s critical hit ratio")
    elsif desire_mul < 0
      score += 5
      PBDebug.log_score_change(score - old_score, "#{battler.name} doesn't benefit from raised critical hit ratio")
    else
      score = Battle::AI::ITEM_USELESS_SCORE
      PBDebug.log_score_change(score - old_score, "useless because #{battler.name} doesn't need raised critical hit ratio")
    end
    next score
  }
)

Battle::AI::Handlers::BattlerItemEffectScore.copy(:DIREHIT, :DIREHIT2, :DIREHIT3, :LANSATBERRY)


################################################################################
#
# Condition curing items.
#
################################################################################

#===============================================================================
# Persim Berry
#===============================================================================
Battle::AI::Handlers::BattlerItemEffectScore.add(:PERSIMBERRY,
  proc { |item, score, battler, ai, battle|
    old_score = score
    if battler
      if battler.effects[PBEffects::Confusion] > 0
        items = [:PERSIMBERRY, :LUMBERRY]
        abils = [:OWNTEMPO]
        if battler.has_active_item?(items) || battler.has_active_ability?(abils)
          score = Battle::AI::ITEM_USELESS_SCORE
          PBDebug.log_score_change(score - old_score, "useless because #{battler.name} doesn't mind confusion")
        elsif battler.rough_end_of_round_damage >= battler.hp
          score = Battle::AI::ITEM_USELESS_SCORE
          PBDebug.log_score_change(score - old_score, "useless because #{battler.name} predicted to faint this round")
        else
          desire_mult = (battler.opposes?(ai.trainer)) ? -1 : 1
          score += 5 * desire_mult * battler.effects[PBEffects::Confusion]
          score += 3 * desire_mult * battler.stages[:ATTACK]
          if ai.trainer.has_skill_flag?("HPAware") && battler.hp <= battler.totalhp / 2
            score -= 8 * desire_mult if battle.pbHasHealingItem?(ai.user.index)
          end
          score -= 5 * desire_mult if battler.has_active_ability?(:TANGLEDFEET)
          score += 8 * desire_mult if battler.status == :PARALYSIS || battler.effects[PBEffects::Attract] >= 0
          PBDebug.log_score_change(score - old_score, "curing #{battler.name}'s confusion")
        end
      else
        score = Battle::AI::ITEM_FAIL_SCORE
        PBDebug.log_score_change(score - old_score, "fails because #{battler.name} isn't confused")
      end
    else
      score = Battle::AI::ITEM_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because target isn't an active battler")
    end
    next score
  }
)

#===============================================================================
# Yellow Flute
#===============================================================================
Battle::AI::Handlers::BattlerItemEffectScore.add(:YELLOWFLUTE,
  proc { |item, score, battler, ai, battle|
    if !battler.has_active_ability?(:SOUNDPROOF)
      next Battle::AI::Handlers.battler_item_score(:PERSIMBERRY, score, battler, ai, battle)
    else
      old_score = score
      score = Battle::AI::ITEM_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because #{battler.name} has #{battler.battler.abilityName}")
    end
    next score
  }
)

#===============================================================================
# Red Flute
#===============================================================================
Battle::AI::Handlers::BattlerItemEffectScore.add(:REDFLUTE,
  proc { |item, score, battler, ai, battle|
    old_score = score
    if !battler.has_active_ability?(:SOUNDPROOF)
      if battler.effects[PBEffects::Attract] >= 0
        items = [:MENTALHERB]
        abils = [:OBLIVIOUS]
        if battler.has_active_item?(items) || battler.has_active_ability?(abils)
          score = Battle::AI::ITEM_USELESS_SCORE
          PBDebug.log_score_change(score - old_score, "useless because #{battler.name} doesn't mind infatuation")
        elsif battler.rough_end_of_round_damage >= battler.hp
          score = Battle::AI::ITEM_USELESS_SCORE
          PBDebug.log_score_change(score - old_score, "useless because #{battler.name} predicted to faint this round")
        else
          desire_mult = (battler.opposes?(ai.trainer)) ? -1 : 1
          score += 10 * desire_mult
          score += 8 * desire_mult if battler.status == :PARALYSIS || battler.effects[PBEffects::Confusion] > 1
          PBDebug.log_score_change(score - old_score, "curing #{battler.name}'s infatuation")
        end
      else
        score = Battle::AI::ITEM_FAIL_SCORE
        PBDebug.log_score_change(score - old_score, "fails because #{battler.name} isn't infatuated")
      end
    else
      score = Battle::AI::ITEM_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because #{battler.name} has #{battler.battler.abilityName}")
    end
    next score
  }
)