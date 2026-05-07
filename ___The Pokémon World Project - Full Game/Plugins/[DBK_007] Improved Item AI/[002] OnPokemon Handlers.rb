################################################################################
#
# HP healing items.
#
################################################################################

#===============================================================================
# HP healing items (Potion, Fresh Water, etc.)
#===============================================================================
Battle::AI::Handlers::PokemonItemEffectScore.add(:POTION,
  proc { |item, score, pkmn, battler, move, ai, battle|
    old_score = score
    logName = (battler) ? battler.name : pkmn.name
    if pkmn.able? && pkmn.hp < pkmn.totalhp
      itemData = GameData::Item.get(item)
      opposes = battler && battler.opposes?(ai.trainer)
      #-------------------------------------------------------------------------
      # Confusion berries. Included for Item Urge compatibility.
      confuse_berries = {
        :FIGYBERRY   => :ATTACK,
        :IAPAPABERRY => :DEFENSE,
        :WIKIBERRY   => :SPECIAL_ATTACK,
        :AGUAVBERRY  => :SPECIAL_DEFENSE,
        :MAGOBERRY   => :SPEED
      }
      #-------------------------------------------------------------------------
      # Determines the amount of HP to heal.
      if confuse_berries.keys.include?(item)
        if Settings::MECHANICS_GENERATION == 7
          heal_amt = pkmn.totalhp / 2
        elsif Settings::MECHANICS_GENERATION >= 8
          heal_amt = pkmn.totalhp / 3
        else
          heal_amt = pkmn.totalhp / 8
        end
      else
        heal_amt = Battle::AI::HP_HEAL_ITEMS[item] || 0
        heal_amt = pkmn.totalhp / 4 if heal_amt == 1 || item == :ENIGMABERRY
      end
      if heal_amt >= 999
        score -= 5
        heal_amt = pkmn.totalhp - 1
      elsif itemData.is_berry? && battler.has_active_ability?(:RIPEN)
        heal_amt *= 2
      end
      if heal_amt <= 0
        score = Battle::AI::ITEM_FAIL_SCORE
        PBDebug.log_score_change(score - old_score, "fails because item doesn't heal any HP")
        next score
      end
      over_heal = (pkmn.hp + heal_amt) - pkmn.totalhp
      #-------------------------------------------------------------------------
      # Calculates healing score.
      if !opposes && pkmn.hp > pkmn.totalhp * 0.55
        score = Battle::AI::ITEM_USELESS_SCORE
        PBDebug.log_score_change(score - old_score, "useless because #{logName}'s HP isn't worth healing")
        next score
      end
      if battler && battler.rough_end_of_round_damage >= battler.hp
        if opposes
          score = Battle::AI::ITEM_USELESS_SCORE
          PBDebug.log_score_change(score - old_score, "useless because #{logName} predicted to faint this round")
          next score
        else
          score += 20
          PBDebug.log_score_change(score - old_score, "prefer healing because #{logName} predicted to faint this round")
          old_score = score
        end
      end
      if ai.trainer.has_skill_flag?("HPAware")
        scoreHP = 20 * (pkmn.totalhp - pkmn.hp) / pkmn.totalhp
        scoreHP += 20 * [heal_amt, pkmn.totalhp - pkmn.hp].min / pkmn.totalhp
        scoreHP += 5 if pkmn.hp <= pkmn.totalhp / 2
        scoreHP += 5 if pkmn.hp <= pkmn.totalhp / 4
        (opposes) ? score -= scoreHP : score += scoreHP
        hpchange = sprintf("%d -> %d", pkmn.hp, [pkmn.hp + heal_amt, pkmn.totalhp].min)
        PBDebug.log_score_change(score - old_score, "healing #{logName} by #{heal_amt} HP (#{hpchange}) (#{[0, over_heal].max} over heal)")
        if ai.trainer.medium_skill?
          if battle.pbAbleTeamCounts(ai.trainer.side) == 1
            (opposes) ? score -= 10 : score += 10
            PBDebug.log_score_change(score - old_score, "#{logName} is trainer's final Pokémon")
            old_score = score
          end
          if battler && confuse_berries.keys.include?(item) && battler.battler.pbCanConfuse?(nil, false)
            confuse_berries.each do |itm, stat|
              next if item != itm
              next if battler.battler.nature.stat_changes.any? { |val| val[0] == stat && val[1] < 0 }
              (opposes) ? score += 15 : score -= 10
              PBDebug.log_score_change(score - old_score, "inflicts confusion on #{logName}")
              old_score = score
              break
            end
          end
          pkmn.moves.each do |m|
            next if m.pp == 0
            case m.function_code
            when "PowerHigherWithUserHP",       # Eruption
                 "UserFaintsFixedDamageUserHP"  # Final Gambit
              (opposes) ? score -= 15 : score += 15
              PBDebug.log_score_change(score - old_score, "#{logName}'s move #{m.name} prefers higher HP")
              old_score = score
            when "PowerLowerWithUserHP",        # Flail
                 "LowerTargetHPToUserHP"        # Endeavor
              (opposes) ? score += 15 : score -= 15
              PBDebug.log_score_change(score - old_score, "#{logName}'s move #{m.name} prefers lower HP")
              old_score = score
            end
          end
          heal_hp = pkmn.hp + heal_amt
          if heal_hp >= pkmn.totalhp
            if pkmn.item_id == :FOCUSSASH
              (opposes) ? score -= 8 : score += 8
              itemName = GameData::Item.get(pkmn.item_id).name
              PBDebug.log_score_change(score - old_score, "#{logName}'s held item #{itemName} prefers max HP")
            elsif [:STURDY, :MULTISCALE, :SHADOWSHIELD].include?(pkmn.ability_id)
              (opposes) ? score -= 8 : score += 8
              abilName = GameData::Ability.get(pkmn.ability_id).name
              PBDebug.log_score_change(score - old_score, "#{logName}'s ability #{abilName} prefers max HP")
            end
          elsif pkmn.hp < pkmn.totalhp / 2 && heal_hp > pkmn.totalhp / 2
            if [:DEFEATIST, :BERSERK, :ANGERSHELL].include?(pkmn.ability_id)
              (opposes) ? score -= 8 : score += 8
              abilName = GameData::Ability.get(pkmn.ability_id).name
              PBDebug.log_score_change(score - old_score, "#{logName}'s ability #{abilName} prefers >50% HP")
            end
          end
        end
      end
      if !opposes && over_heal > 0 && battle.pbHasHealingItem?(ai.user.index, heal_amt)
        old_score = score
        score -= 10 * (over_heal / pkmn.totalhp)
        PBDebug.log_score_change(score - old_score, "prefers a weaker healing item in the inventory")
      end
    else
      score = Battle::AI::ITEM_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because #{logName}'s HP can't be healed")
    end
    next score
  }
)

Battle::AI::Handlers::PokemonItemEffectScore.copy(:POTION, :SUPERPOTION, :HYPERPOTION, :MAXPOTION,
                                                  :BERRYJUICE, :SWEETHEART, :FRESHWATER, :SODAPOP, :LEMONADE, :MOOMOOMILK, 
                                                  :ORANBERRY, :SITRUSBERRY, :ENERGYPOWDER, :ENERGYROOT,
                                                  :FIGYBERRY, :IAPAPABERRY, :WIKIBERRY, :AGUAVBERRY, :MAGOBERRY, :ENIGMABERRY)
										   
										   
################################################################################
#
# Status cure items.
#
################################################################################

#===============================================================================
# Sleep cure items (Awakening, Chesto Berry)
#===============================================================================
Battle::AI::Handlers::PokemonItemEffectScore.add(:AWAKENING,
  proc { |item, score, pkmn, battler, move, ai, battle|
    old_score = score
    logName = (battler) ? battler.name : pkmn.name
    if [:SLEEP, :DROWSY].include?(pkmn.status)
      items = [:CHESTOBERRY, :LUMBERRY]
      abils = [:INSOMNIA, :VITALSPIRIT]
      statusName = GameData::Status.get(pkmn.status).name
      if battler
        if battler.rough_end_of_round_damage >= battler.hp && 
		   !battler.effects[PBEffects::Nightmare] && !battler.opponent_side_has_ability?(:BADDREAMS)
          score = Battle::AI::ITEM_USELESS_SCORE
          PBDebug.log_score_change(score - old_score, "useless because #{logName} predicted to faint this round")
          next score
        end
        if battler.opposes?(ai.trainer)
          wants_status = battler.wants_status_problem?(pkmn.status) ||
                         battler.check_for_move { |m| m.usableWhenAsleep? }
          foe_prefers_status = battler.effects[PBEffects::Nightmare] ||
                               battler.opponent_side_has_ability?(:BADDREAMS) ||
                               battler.opponent_side_has_function?(
            "DoublePowerIfTargetStatusProblem",        # Hex
            "StartDamageTargetEachTurnIfTargetAsleep", # Nightmare
            "DoublePowerIfTargetAsleepCureTarget",     # Wake-Up Slap
            "HealUserByHalfOfDamageDoneIfTargetAsleep" # Dream Eater
          )
          if wants_status && !foe_prefers_status
            score += 20
            PBDebug.log_score_change(score - old_score, "curing #{logName}'s #{statusName} status")
          else
            score = Battle::AI::ITEM_USELESS_SCORE
            PBDebug.log_score_change(score - old_score, "useless because user wants #{logName} to keep #{statusName} status")
          end
        elsif battler.wants_status_problem?(pkmn.status) || battler.statusCount <= 1 ||
              battler.has_active_item?(items) || battler.has_active_ability?(abils)
          score = Battle::AI::ITEM_USELESS_SCORE
          PBDebug.log_score_change(score - old_score, "useless because #{logName} doesn't mind the #{statusName} status")
        else
          score += 15
          if ai.trainer.medium_skill?
            score -= 20 if battler.has_active_ability?(:HYDRATION) && 
                           [:Rain, :HeavyRain].include?(battler.battler.effectiveWeather)
            score += 10 if battler.effects[PBEffects::Nightmare]
            score += 10 if battler.opponent_side_has_ability?(:BADDREAMS)
            score -= 10 if battler.has_active_ability?(:EARLYBIRD)
            score -= 8 if battler.has_active_ability?([:NATURALCURE, :SHEDSKIN])
            score += 5 if battler.opponent_side_has_function?(
              "DoublePowerIfTargetStatusProblem",        # Hex
              "StartDamageTargetEachTurnIfTargetAsleep", # Nightmare
              "DoublePowerIfTargetAsleepCureTarget",     # Wake-Up Slap
              "HealUserByHalfOfDamageDoneIfTargetAsleep" # Dream Eater
            )
            score -= 8 if battler.check_for_move { |m| m.usableWhenAsleep? }
            ai.each_same_side_battler(ai.trainer.side) do |b, i|
              score -= 8 if i != battler.index && b.has_active_ability?(:HEALER)
            end
          end
          PBDebug.log_score_change(score - old_score, "curing #{logName}'s #{statusName} status")
        end
      else
        if items.include?(pkmn.item_id) || abils.include?(pkmn.ability_id)
          score = Battle::AI::ITEM_USELESS_SCORE
          PBDebug.log_score_change(score - old_score, "useless because #{logName} doesn't mind the #{statusName} status")
        else
          score += 20
          if ai.trainer.medium_skill?
            score -= 8 if pkmn.ability_id == :EARLYBIRD
            score -= 4 if [:NATURALCURE, :SHEDSKIN].include?(pkmn.ability_id)
          end
          PBDebug.log_score_change(score - old_score, "curing #{logName}'s #{statusName} status")
        end
      end
    elsif !battler || !battler.opposes?(ai.trainer)
      score = Battle::AI::ITEM_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because #{logName} isn't asleep")
    end
    next score
  }
)

Battle::AI::Handlers::PokemonItemEffectScore.copy(:AWAKENING, :CHESTOBERRY)

#===============================================================================
# Poison cure items (Antidote, Pecha Berry)
#===============================================================================
Battle::AI::Handlers::PokemonItemEffectScore.add(:ANTIDOTE,
  proc { |item, score, pkmn, battler, move, ai, battle|
    old_score = score
    logName = (battler) ? battler.name : pkmn.name
    if pkmn.status == :POISON
      items = [:TOXICORB, :PECHABERRY, :LUMBERRY]
      abils = [:IMMUNITY, :PASTELVEIL]
      statusName = GameData::Status.get(pkmn.status).name
      if battler
        if battler.opposes?(ai.trainer)
          wants_status = battler.wants_status_problem?(:POISON) ||
                         battler.has_move_with_function?(
            "DoublePowerIfUserPoisonedBurnedParalyzed" # Facade
          )
          foe_prefers_status = battler.opponent_side_has_function?(
            "DoublePowerIfTargetPoisoned",             # Venoshock
            "DoublePowerIfTargetStatusProblem"         # Hex
          )
          if wants_status && !foe_prefers_status
            score += 20
            PBDebug.log_score_change(score - old_score, "curing #{logName}'s #{statusName} status")
          else
            score = Battle::AI::ITEM_USELESS_SCORE
            PBDebug.log_score_change(score - old_score, "useless because user wants #{logName} to keep #{statusName} status")
          end
        elsif battler.wants_status_problem?(:POISON) || !battler.battler.takesIndirectDamage? ||
              battler.has_active_item?(items) || battler.has_active_ability?(abils)
          score = Battle::AI::ITEM_USELESS_SCORE
          PBDebug.log_score_change(score - old_score, "useless because #{logName} doesn't mind the #{statusName} status")
        else
          score += 10
          if ai.trainer.has_skill_flag?("HPAware")
            score += 10 if battler.hp < battler.totalhp / 2
          end
          score += 8 if battler.rough_end_of_round_damage >= battler.hp
          if ai.trainer.medium_skill?
            score -= 20 if battler.has_active_ability?(:HYDRATION) && 
                        [:Rain, :HeavyRain].include?(battler.battler.effectiveWeather)
            score += (8 * battler.effects[PBEffects::Toxic])
            score += 10 if battler.opponent_side_has_ability?(:MERCILESS)
            score -= 8 if battler.has_active_ability?([:NATURALCURE, :SHEDSKIN])
            score += 5 if battler.opponent_side_has_function?(
              "DoublePowerIfTargetPoisoned",             # Venoshock
              "DoublePowerIfTargetStatusProblem"         # Hex
            )
            score -= 30 if battler.has_move_with_function?(
              "CureUserPartyStatus",                     # Heal Bell
              "GiveUserStatusToTarget",                  # Psycho Shift
              "HealUserFullyAndFallAsleep",              # Rest
              "CureUserBurnPoisonParalysis",             # Refresh
              "DoublePowerIfUserPoisonedBurnedParalyzed" # Facade
            )
            ai.each_same_side_battler(ai.trainer.side) do |b, i|
              score -= 8 if i != battler.index && b.has_active_ability?(:HEALER)
            end
          end
          PBDebug.log_score_change(score - old_score, "curing #{logName}'s #{statusName} status")
        end
      else
        if items.include?(pkmn.item_id) || abils.include?(pkmn.ability_id) ||
           [:POISONHEAL, :TOXICBOOST, :MAGICGUARD].include?(pkmn.ability_id)
          score = Battle::AI::ITEM_USELESS_SCORE
          PBDebug.log_score_change(score - old_score, "useless because #{logName} doesn't mind the #{statusName} status")
        else
          score += 20
          if ai.trainer.has_skill_flag?("HPAware")
            score += 10 if pkmn.hp < pkmn.totalhp / 2
          end
          if ai.trainer.medium_skill?
            score -= 4 if [:NATURALCURE, :SHEDSKIN].include?(pkmn.ability_id)
            score -= 20 if [:GUTS, :MARVELSCALE, :QUICKFEET].include?(pkmn.ability_id)
          end
          PBDebug.log_score_change(score - old_score, "curing #{logName}'s #{statusName} status")
        end
      end
    elsif !battler || !battler.opposes?(ai.trainer)
      score = Battle::AI::ITEM_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because #{logName} isn't poisoned")
    end
    next score
  }
)

Battle::AI::Handlers::PokemonItemEffectScore.copy(:ANTIDOTE, :PECHABERRY)

#===============================================================================
# Burn cure items (Burn Heal, Rawst Berry)
#===============================================================================
Battle::AI::Handlers::PokemonItemEffectScore.add(:BURNHEAL,
  proc { |item, score, pkmn, battler, move, ai, battle|
    old_score = score
    logName = (battler) ? battler.name : pkmn.name
    if pkmn.status == :BURN
      items = [:FLAMEORB, :RAWSTBERRY, :LUMBERRY]
      abils = [:WATERVEIL, :WATERBUBBLE, :THERMALEXCHANGE]
      statusName = GameData::Status.get(pkmn.status).name
      if battler
        if battler.opposes?(ai.trainer)
          wants_status = battler.wants_status_problem?(:BURN) ||
                         battler.has_move_with_function?(
            "DoublePowerIfUserPoisonedBurnedParalyzed" # Facade
          )
          foe_prefers_status = ai.stat_raise_worthwhile?(battler, :ATTACK, true) ||
                               battler.opponent_side_has_function?(
            "DoublePowerIfTargetStatusProblem"         # Hex
          )
          if wants_status && !foe_perfers_status 
            score += 20
            PBDebug.log_score_change(score - old_score, "curing #{logName}'s #{statusName} status")
          else
            score = Battle::AI::ITEM_USELESS_SCORE
            PBDebug.log_score_change(score - old_score, "useless because user wants #{logName} to keep #{statusName} status")
          end
        elsif battler.wants_status_problem?(:BURN) ||
              battler.has_active_item?(items) || battler.has_active_ability?(abils)
          score = Battle::AI::ITEM_USELESS_SCORE
          PBDebug.log_score_change(score - old_score, "useless because #{logName} doesn't mind the #{statusName} status")
        else
          score += 15
          if ai.trainer.has_skill_flag?("HPAware") && battler.battler.takesIndirectDamage?
            score += 10 if battler.hp < battler.totalhp / 2
          end
          score += 8 if battler.rough_end_of_round_damage >= battler.hp
          if ai.trainer.medium_skill?
            score -= 20 if battler.has_active_ability?(:HYDRATION) && 
                        [:Rain, :HeavyRain].include?(battler.battler.effectiveWeather)
            score += 10 if ai.stat_raise_worthwhile?(battler, :ATTACK, true)
            score -= 5 if battler.has_active_ability?(:HEATPROOF)
            score -= 8 if battler.has_active_ability?([:NATURALCURE, :SHEDSKIN])
            score += 5 if battler.opponent_side_has_function?(
              "DoublePowerIfTargetStatusProblem"         # Hex
            )
            score -= 30 if battler.has_move_with_function?(
              "CureUserPartyStatus",                     # Heal Bell
              "GiveUserStatusToTarget",                  # Psycho Shift
              "HealUserFullyAndFallAsleep",              # Rest
              "CureUserBurnPoisonParalysis",             # Refresh
              "DoublePowerIfUserPoisonedBurnedParalyzed" # Facade
            )
            ai.each_same_side_battler(ai.trainer.side) do |b, i|
              score -= 8 if i != battler.index && b.has_active_ability?(:HEALER)
            end
          end
          PBDebug.log_score_change(score - old_score, "curing #{logName}'s #{statusName} status")
        end
      else
        if items.include?(pkmn.item_id) || abils.include?(pkmn.ability_id) ||
           [:FLAREBOOST, :MAGICGUARD].include?(pkmn.ability_id)
          score = Battle::AI::ITEM_USELESS_SCORE
          PBDebug.log_score_change(score - old_score, "useless because #{logName} doesn't mind the #{statusName} status")
        else
          score += 20
          if ai.trainer.has_skill_flag?("HPAware")
            score += 10 if pkmn.hp < pkmn.totalhp / 2
          end
          if ai.trainer.medium_skill?
            score += 10 if pkmn.moves.any? { |m| m.category == 0 }
            score -= 4 if [:NATURALCURE, :SHEDSKIN].include?(pkmn.ability_id)
            score -= 10 if [:GUTS, :MARVELSCALE, :QUICKFEET].include?(pkmn.ability_id)
          end
          PBDebug.log_score_change(score - old_score, "curing #{logName}'s #{statusName} status")
        end
      end
    elsif !battler || !battler.opposes?(ai.trainer)
      score = Battle::AI::ITEM_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because #{logName} isn't burned")
    end
    next score
  }
)

Battle::AI::Handlers::PokemonItemEffectScore.copy(:BURNHEAL, :RAWSTBERRY)

#===============================================================================
# Paralysis cure items (Paralyze Heal, Cheri Berry)
#===============================================================================
Battle::AI::Handlers::PokemonItemEffectScore.add(:PARALYZEHEAL,
  proc { |item, score, pkmn, battler, move, ai, battle|
    old_score = score
    logName = (battler) ? battler.name : pkmn.name
    if pkmn.status == :PARALYSIS
      items = [:CHERIBERRY, :LUMBERRY]
      abils = [:LIMBER]
      statusName = GameData::Status.get(pkmn.status).name
      if battler
        if battler.rough_end_of_round_damage >= battler.hp
          score = Battle::AI::ITEM_USELESS_SCORE
          PBDebug.log_score_change(score - old_score, "useless because #{logName} predicted to faint this round")
          next score
        end
        if battler.opposes?(ai.trainer)
          wants_status = battler.wants_status_problem?(:PARALYSIS) ||
		                 battler.has_move_with_function?(
            "DoublePowerIfUserPoisonedBurnedParalyzed" # Facade
          )
          foe_prefers_status = ai.stat_raise_worthwhile?(battler, :SPEED, true) ||
                               battler.effects[PBEffects::Confusion] > 1 ||
                               battler.effects[PBEffects::Attract] >= 0 ||
                               battler.opponent_side_has_function?(
            "DoublePowerIfTargetParalyzedCureTarget",  # Smelling Salts
            "DoublePowerIfTargetStatusProblem"         # Hex
          )
          if wants_status && !foe_prefers_status
            score += 20
            PBDebug.log_score_change(score - old_score, "curing #{logName}'s #{statusName} status")
          else
            score = Battle::AI::ITEM_USELESS_SCORE
            PBDebug.log_score_change(score - old_score, "useless because user wants #{logName} to keep #{statusName} status")
          end
        elsif battler.wants_status_problem?(:PARALYSIS) ||
              battler.has_active_item?(items) || battler.has_active_ability?(abils)
          score = Battle::AI::ITEM_USELESS_SCORE
          PBDebug.log_score_change(score - old_score, "useless because #{logName} doesn't mind the #{statusName} status")
        else
          score += 15
          if ai.trainer.medium_skill?
            score -= 20 if battler.has_active_ability?(:HYDRATION) && 
                        [:Rain, :HeavyRain].include?(battler.battler.effectiveWeather)
            score += 7 if battler.effects[PBEffects::Confusion] > 1
            score += 7 if battler.effects[PBEffects::Attract] >= 0
            score += 10 if ai.stat_raise_worthwhile?(battler, :SPEED, true)
            score -= 8 if battler.has_active_ability?([:NATURALCURE, :SHEDSKIN])
            score += 5 if battler.opponent_side_has_function?(
              "DoublePowerIfTargetParalyzedCureTarget",  # Smelling Salts
              "DoublePowerIfTargetStatusProblem"         # Hex
            )
            score -= 30 if battler.has_move_with_function?(
              "CureUserPartyStatus",                     # Heal Bell
              "GiveUserStatusToTarget",                  # Psycho Shift
              "HealUserFullyAndFallAsleep",              # Rest
              "CureUserBurnPoisonParalysis",             # Refresh
              "DoublePowerIfUserPoisonedBurnedParalyzed" # Facade
            )
            ai.each_same_side_battler(ai.trainer.side) do |b, i|
              score -= 8 if i != battler.index && b.has_active_ability?(:HEALER)
            end
          end
          PBDebug.log_score_change(score - old_score, "curing #{logName}'s #{statusName} status")
        end
      else
        if items.include?(pkmn.item_id) || abils.include?(pkmn.ability_id)
          score = Battle::AI::ITEM_USELESS_SCORE
          PBDebug.log_score_change(score - old_score, "useless because #{logName} doesn't mind the #{statusName} status")
        else
          score += 20
          if ai.trainer.medium_skill?
            score -= 4 if [:NATURALCURE, :SHEDSKIN].include?(pkmn.ability_id)
            score -= 10 if [:GUTS, :MARVELSCALE, :QUICKFEET].include?(pkmn.ability_id)
          end
          PBDebug.log_score_change(score - old_score, "curing #{logName}'s #{statusName} status")
        end
      end
    elsif !battler || !battler.opposes?(ai.trainer)
      score = Battle::AI::ITEM_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because #{logName} isn't paralyzed")
    end
    next score
  }
)

Battle::AI::Handlers::PokemonItemEffectScore.copy(:PARALYZEHEAL, :PARLYZHEAL, :CHERIBERRY)

#===============================================================================
# Freeze cure items (Ice Heal, Aspear Berry)
#===============================================================================
Battle::AI::Handlers::PokemonItemEffectScore.add(:ICEHEAL,
  proc { |item, score, pkmn, battler, move, ai, battle|
    old_score = score
    logName = (battler) ? battler.name : pkmn.name
    if [:FROZEN, :FROSTBITE].include?(pkmn.status)
      items = [:ASPEARBERRY, :LUMBERRY]
      abils = [:MAGMAARMOR]
      statusName = GameData::Status.get(pkmn.status).name
      if battler
        if battler.rough_end_of_round_damage >= battler.hp && battler.status == :FROZEN
          score = Battle::AI::ITEM_USELESS_SCORE
          PBDebug.log_score_change(score - old_score, "useless because #{logName} predicted to faint this round")
          next score
        end
        if battler.opposes?(ai.trainer)
          wants_status = battler.wants_status_problem?(pkmn.status)
          foe_prefers_status = (battler.status == :FROSTBITE && ai.stat_raise_worthwhile?(battler, :SPECIAL_ATTACK, true)) ||
                               battler.opponent_side_has_function?(
            "DoublePowerIfTargetStatusProblem"         # Hex
          )
          if wants_status && !foe_prefers_status
            score += 20
            PBDebug.log_score_change(score - old_score, "curing #{logName}'s #{statusName} status")
          else
            score = Battle::AI::ITEM_USELESS_SCORE
            PBDebug.log_score_change(score - old_score, "useless because user wants #{logName} to keep #{statusName} status")
          end
        elsif battler.wants_status_problem?(pkmn.status) ||
              battler.has_active_item?(items) || battler.has_active_ability?(abils)
          score = Battle::AI::ITEM_USELESS_SCORE
          PBDebug.log_score_change(score - old_score, "useless because #{logName} doesn't mind the #{statusName} status")
        else
          case pkmn.status
          when :FROZEN
            score += 25
          when :FROSTBITE
            score += 15
            if ai.trainer.has_skill_flag?("HPAware") && battler.battler.takesIndirectDamage?
              score += 10 if battler.hp < battler.totalhp / 2
            end
            score += 8 if battler.rough_end_of_round_damage >= battler.hp
            if ai.trainer.medium_skill?
              score += 10 if ai.stat_raise_worthwhile?(battler, :SPECIAL_ATTACK, true)
              score -= 30 if battler.has_move_with_function?(
                "CureUserPartyStatus",                     # Heal Bell
                "GiveUserStatusToTarget",                  # Psycho Shift
                "HealUserFullyAndFallAsleep",              # Rest
                "CureUserBurnPoisonParalysis",             # Refresh
                "DoublePowerIfUserPoisonedBurnedParalyzed" # Facade
              )
            end
          end
          if ai.trainer.medium_skill?
            score -= 20 if battler.has_active_ability?(:HYDRATION) && 
                        [:Rain, :HeavyRain].include?(battler.battler.effectiveWeather)
            score -= 8 if battler.has_active_ability?([:NATURALCURE, :SHEDSKIN])
            score += 5 if battler.opponent_side_has_function?(
              "DoublePowerIfTargetStatusProblem"         # Hex
            )
            ai.each_same_side_battler(ai.trainer.side) do |b, i|
              score -= 8 if i != battler.index && b.has_active_ability?(:HEALER)
            end
          end
          PBDebug.log_score_change(score - old_score, "curing #{logName}'s #{statusName} status")
        end
      else
        if items.include?(pkmn.item_id) || abils.include?(pkmn.ability_id)
          score = Battle::AI::ITEM_USELESS_SCORE
          PBDebug.log_score_change(score - old_score, "useless because #{logName} doesn't mind the #{statusName} status")
        else
          score += 20
          if pkmn.status == :FROZEN && ai.trainer.has_skill_flag?("HPAware")
            score += 10 if pkmn.hp >= pkmn.totalhp / 2
          end
          if ai.trainer.medium_skill?
            if pkmn.status == :FROSTBITE
              if ai.trainer.has_skill_flag?("HPAware")
                score += 10 if pkmn.hp < pkmn.totalhp / 2
              end
              score += 10 if pkmn.moves.any? { |m| m.category == 1 }
            end
            score -= 4 if [:NATURALCURE, :SHEDSKIN].include?(pkmn.ability_id)
          end
          PBDebug.log_score_change(score - old_score, "curing #{logName}'s #{statusName} status")
        end
      end
    elsif !battler || !battler.opposes?(ai.trainer)
      score = Battle::AI::ITEM_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because #{logName} isn't frozen")
    end
    next score
  }
)

Battle::AI::Handlers::PokemonItemEffectScore.copy(:ICEHEAL, :ASPEARBERRY)

#===============================================================================
# Full status cure items (Full Heal, Lum Berry, etc.)
#===============================================================================
Battle::AI::Handlers::PokemonItemEffectScore.add(:FULLHEAL,
  proc { |item, score, pkmn, battler, move, ai, battle|
    old_score = score
    tryItems = [] 
    tryScores = []
    case pkmn.status
    when :BURN               then tryItems.push(:BURNHEAL)
    when :POISON             then tryItems.push(:ANTIDOTE)
    when :PARALYSIS          then tryItems.push(:PARALYZEHEAL)
    when :SLEEP, :DROWSY     then tryItems.push(:AWAKENING)
    when :FROZEN, :FROSTBITE then tryItems.push(:ICEHEAL)
    end
    opposes = battler.opposes?(ai.trainer)
    logName = (battler) ? battler.name : pkmn.name
    tryItems.push(:PERSIMBERRY) if battler && battler.effects[PBEffects::Confusion] > 0
    if tryItems.empty?
      score = Battle::AI::ITEM_USELESS_SCORE
      PBDebug.log_score_change(score - old_score, "useless because #{logName} has no condition to heal")
    else
      items = battle.pbGetOwnerItems(ai.user.index)
      tryItems.each_with_index do |itm, i|
        itemData = GameData::Item.get(itm)
        if itm == :PERSIMBERRY
          tryScore = Battle::AI::Handlers.battler_item_score(itm, score, battler, ai, battle)
        else
          tryScore = Battle::AI::Handlers.pokemon_item_score(itm, score, pkmn, battler, move, ai, battle)
        end
        temp_score = tryScore
        if tryScore > Battle::AI::ITEM_USELESS_SCORE
          if !opposes && tryItems.length == 1 && items.include?(itm)
            tryScore -= 10
            PBDebug.log_score_change(tryScore - temp_score, "prefers to use #{itemData.name}")
          elsif i > 0
            (opposes) ? tryScore -= 10 : tryScore += 10
            PBDebug.log_score_change(tryScore - temp_score, "cures multiple conditions")
          end
        end
        tryScores.push(tryScore - old_score)
      end
      score += tryScores.sum
    end
    next score
  }
)

Battle::AI::Handlers::PokemonItemEffectScore.copy(:FULLHEAL, :LAVACOOKIE, :OLDGATEAU, :CASTELIACONE, :LUMIOSEGALETTE,
                                                  :SHALOURSABLE, :BIGMALASADA, :PEWTERCRUNCHIES, :LUMBERRY, :HEALPOWDER)

#===============================================================================
# Rage Candy Bar
#===============================================================================
Battle::AI::Handlers::PokemonItemEffectScore.add(:RAGECANDYBAR,
  proc { |item, score, pkmn, battler, move, ai, battle|
    item = (Settings::RAGE_CANDY_BAR_CURES_STATUS_PROBLEMS) ? :FULLHEAL : :POTION
    next Battle::AI::Handlers.pokemon_item_score(item, score, pkmn, battler, move, ai, battle)
  }
)

#===============================================================================
# Blue Flute
#===============================================================================
Battle::AI::Handlers::PokemonItemEffectScore.add(:BLUEFLUTE,
  proc { |item, score, pkmn, battler, move, ai, battle|
    if battler && battler.has_active_ability?(:SOUNDPROOF)
	  old_score = score
      score = Battle::AI::ITEM_FAIL_SCORE
	  PBDebug.log_score_change(score - old_score, "fails because #{battler.name} has the #{battler.battler.abilityName} ability")
      next score
    end
    next Battle::AI::Handlers.pokemon_item_score(:AWAKENING, score, pkmn, battler, move, ai, battle)
  }
)


################################################################################
#
# Full recovery items.
#
################################################################################

#===============================================================================
# Full Restore
#===============================================================================
Battle::AI::Handlers::PokemonItemEffectScore.add(:FULLRESTORE,
  proc { |item, score, pkmn, battler, move, ai, battle|
    old_score = score
    logName = (battler) ? battler.name : pkmn.name
    healScore = Battle::AI::Handlers.pokemon_item_score(:MAXPOTION, score, pkmn, battler, move, ai, battle)
    cureScore = Battle::AI::Handlers.pokemon_item_score(:FULLHEAL, score, pkmn, battler, move, ai, battle)
    if cureScore > Battle::AI::ITEM_USELESS_SCORE
      if healScore > Battle::AI::ITEM_USELESS_SCORE
        score = cureScore + healScore - old_score
        old_score = score
        score += 10
        PBDebug.log_score_change(score - old_score, "heals #{logName}'s HP and cures a condition")
      else
        score = Battle::AI::ITEM_USELESS_SCORE
        PBDebug.log_score_change(score - old_score, "useless because item isn't used to its full potential")
      end
    elsif healScore > Battle::AI::ITEM_USELESS_SCORE
      score = healScore
      if battle.pbHasHealingItem?(ai.user.index)
        old_score = score
        score -= 10
        PBDebug.log_score_change(score - old_score, "prefers basic healing items")
      end
    else
      score = ((healScore + cureScore) / 2).round.to_i
    end
    next score
  }
)


################################################################################
#
# Revival items.
#
################################################################################

#===============================================================================
# Revival items (Revive, Max Revive, etc.)
#===============================================================================
Battle::AI::Handlers::PokemonItemEffectScore.add(:REVIVE,
  proc { |item, score, pkmn, battler, move, ai, battle|
    old_score = score
    if pkmn.fainted?
      score += 20
      PBDebug.log_score_change(score - old_score, "reviving #{pkmn.name}")
      old_score = score
      allyCount = foeCount = 0
      2.times do |i|
        if ai.trainer.side == i
          allyCount = battle.pbAbleTeamCounts(i).length
        else
          foeCount = battle.pbAbleTeamCounts(i).length
        end
      end
      if foeCount > allyCount
        score += 10
        PBDebug.log_score_change(score - old_score, "the opposing team has more remaining Pokémon")
        old_score = score
      end
      value = Battle::AI::REVIVE_ITEMS[item] || 0
      bonus = (battle.pbTeamAbleNonActiveCount(ai.user.index) == 0) ? 5 : 1
      score += (value * bonus)
      PBDebug.log_score_change(score - old_score, "usefulness of the item")
      if ai.trainer.medium_skill?
        old_score = score
        pkmn.moves.each do |move|
          next if move.status_move?
          ai.each_foe_battler(ai.trainer.side) do |b|
            effectiveness = b.effectiveness_of_type_against_battler(move.type)
            if ai.pokemon_can_absorb_move?(b, move, move.type)
              score -= 8
            elsif Effectiveness.super_effective?(effectiveness)
              score += 7
              score += 5 if pkmn.ability_id == :NEUROFORCE
              score -= 5 if b.has_active_ability?([:FILTER, :SOLIDROCK, :PRISMARMOR])
            elsif Effectiveness.not_very_effective?(effectiveness)
              score -= 7
              score += 5 if pkmn.ability_id == :TINTEDLENS
            elsif Effectiveness.ineffective?(effectiveness)
              score -= 8
            end
          end
        end
        PBDebug.log_score_change(score - old_score, "usefulness of #{pkmn.name}'s moves against the opposing battlers")
      end
    else
      score = Battle::AI::ITEM_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because #{pkmn.name} isn't fainted")
    end
    next score
  }
)

Battle::AI::Handlers::PokemonItemEffectScore.copy(:REVIVE, :MAXREVIVE, :REVIVALHERB, :MAXHONEY)


################################################################################
#
# PP recovery items.
#
################################################################################

#===============================================================================
# Single move PP restoring items (Ether, Leppa Berry, etc.)
#===============================================================================
Battle::AI::Handlers::PokemonItemEffectScore.add(:ETHER,
  proc { |item, score, pkmn, battler, move, ai, battle|
    old_score = score
    logName = (battler) ? battler.name : pkmn.name
    if pkmn.able? && move && move >= 0
      opposes = battler && battler.opposes?(ai.trainer)
      move = pkmn.moves[move]
      if move.total_pp == 0 || move.pp == move.total_pp
        score = Battle::AI::ITEM_FAIL_SCORE
        PBDebug.log_score_change(score - old_score, "fails because #{logName}'s #{move.name} PP can't be restored")
        next score
      end
      if move.pp > 0
        score = Battle::AI::ITEM_USELESS_SCORE
        PBDebug.log_score_change(score - old_score, "useless because #{logName}'s #{move.name} PP isn't worth restoring")
        next score
      end
      heal_amt = Battle::AI::PP_HEAL_ITEMS[item] || 0
      if heal_amt >= 999
        score -= 5
        heal_amt = move.total_pp
      end
      if heal_amt <= 0
        score = Battle::AI::ITEM_FAIL_SCORE
        PBDebug.log_score_change(score - old_score, "fails because item doesn't heal any PP")
        next score
      end
      over_heal = (move.pp + heal_amt) - move.total_pp
      if ai.trainer.medium_skill?
        scorePP = 15 * (move.total_pp - move.pp) / move.total_pp
        scorePP += 15 * [heal_amt, move.total_pp - move.pp].min / move.total_pp
        scorePP -= 8 if move.category == 2
        (opposes) ? score -= scorePP : score += scorePP
        ppchange = sprintf("%d -> %d", move.pp, [move.pp + heal_amt, move.total_pp].min)
        PBDebug.log_score_change(score - old_score, "restoring #{heal_amt} PP on #{logName}'s #{move.name} (#{ppchange}) (#{[0, over_heal].max} over heal)")
        old_score = score
        if !opposes
          if pkmn.hp <= pkmn.totalhp / 2
            score -= 8 if battle.pbHasHealingItem?(ai.user.index)
            PBDebug.log_score_change(score - old_score, "prefers to heal HP")
            old_score = score
          end
          if over_heal > 0 && battle.pbHasHealingItem?(ai.user.index, heal_amt, :ether)
            score -= 10 * (over_heal / move.total_pp)
            PBDebug.log_score_change(score - old_score, "prefers a weaker PP restoring item in the inventory")
          end
        end
      end
    else
      score = Battle::AI::ITEM_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because #{logName}'s PP can't be restored")
    end
    next score
  }
)

Battle::AI::Handlers::PokemonItemEffectScore.copy(:ETHER, :MAXETHER, :LEPPABERRY, :HOPOBERRY)

#===============================================================================
# All move PP restoring items (Elixir, Max Elixir)
#===============================================================================
Battle::AI::Handlers::PokemonItemEffectScore.add(:ELIXIR,
  proc { |item, score, pkmn, battler, move, ai, battle|
    tryScores = []
    tryItem = (item == :MAXELIXIR) ? :MAXETHER : :ETHER
    old_score = score
    pkmn.moves.length.times do |i|
      tryScore = Battle::AI::Handlers.pokemon_item_score(tryItem, score, pkmn, battler, i, ai, battle)
      tryScores.push(tryScore - old_score) if tryScore > Battle::AI::ITEM_USELESS_SCORE
    end
    score = tryScores.sum
    next score
  }
)

Battle::AI::Handlers::PokemonItemEffectScore.copy(:ELIXIR, :MAXELIXIR)