################################################################################
#
# General items used directly in battle.
#
################################################################################


#===============================================================================
# Guard Spec.
#===============================================================================
Battle::AI::Handlers::ItemEffectScore.add(:GUARDSPEC,
  proc { |item, score, user, ai, battle, firstAction|
    old_score = score
    if user.pbOwnSide.effects[PBEffects::Mist] == 0
      score += 10
      ai.each_same_side_battler(ai.trainer.side) do |b|
        score += 8 if b.battler.hasAlteredStatStages?
        score -= 10 if b.has_active_ability?([:DEFIANT, :COMPETITIVE])
      end
      if ai.trainer.has_skill_flag?("HPAware") && user.hp <= user.totalhp / 2
        score -= 8 if battle.pbHasHealingItem?(ai.user.index)
      end
      if ai.trainer.medium_skill?
        ai.each_foe_battler(ai.trainer.side) do |b|
          score += 5 if b.check_for_move { |m| 
            m.is_a?(Battle::Move::TargetStatDownMove) ||
            m.is_a?(Battle::Move::TargetMultiStatDownMove) || [
              "LowerPoisonedTargetAtkSpAtkSpd1",         # Venom Drench
              "PoisonTargetLowerTargetSpeed1",           # Toxic Thread
              "HealUserByTargetAttackLowerTargetAttack1" # Strength Sap
            ].include?(m.function_code) 
          }
        end
      end
      PBDebug.log_score_change(score - old_score, "applying Mist effect on #{user.name}'s side")
    else
      score = Battle::AI::ITEM_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because Mist effect already active on #{user.name}'s side")
    end
    next score
  }
)

#===============================================================================
# Poke Flute
#===============================================================================
Battle::AI::Handlers::ItemEffectScore.add(:POKEFLUTE,
  proc { |item, score, user, ai, battle, firstAction|
    battle.allBattlers.each do |b|
      battler = ai.battlers[b.index]
      score = Battle::AI::Handlers.pokemon_item_score(:BLUEFLUTE, score, b.pokemon, battler, nil, ai, battle)
    end
    next score
  }
)


################################################################################
#
# Plugin-exclusive items.
#
################################################################################

#===============================================================================
# Z-Booster
#===============================================================================
Battle::AI::Handlers::ItemEffectScore.add(:ZBOOSTER,
  proc { |item, score, battler, ai, battle, firstAction|
    old_score = score
    if firstAction
      if !battle.pbHasZRing?(battler.index)
        score = Battle::AI::ITEM_FAIL_SCORE
        PBDebug.log_score_change(score - old_score, "fails because trainer doesn't own an eligible Z-Ring")
        next score
      end
      itemName = battle.pbGetZRingName(battler.index) 
      if battle.zMove[ai.trainer.side][ai.trainer.trainer_index] == -1
        score = Battle::AI::ITEM_FAIL_SCORE
        PBDebug.log_score_change(score - old_score, "fails because trainer's #{itemName} is fully charged")
        next score
      end
      total_users = 0
      battle.eachInTeamFromBattlerIndex(ai.user.index) do |pkmn, i|
        total_users += 1 if pkmn.able? && pkmn.has_zmove?
      end
      if total_users > 0
        score += 5 * total_users
        owner = battle.pbGetOwnerName(battler.index)
        PBDebug.log_score_change(score, "recharging #{owner}'s #{itemName}")
      else
        score = Battle::AI::ITEM_FAIL_SCORE
        PBDebug.log_score_change(score - old_score, "fails because no remaining Pokemon can use a Z-Move")
      end
    else
      score = Battle::AI::ITEM_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because item only usable as the trainer's first action")
    end
    next score
  }
)

#===============================================================================
# Wishing Star
#===============================================================================
Battle::AI::Handlers::ItemEffectScore.add(:WISHINGSTAR,
  proc { |item, score, battler, ai, battle, firstAction|
    old_score = score
    if firstAction
      if !battle.pbHasDynamaxBand?(battler.index)
        score = Battle::AI::ITEM_FAIL_SCORE
        PBDebug.log_score_change(score - old_score, "fails because trainer doesn't own an eligible Dynamax Band")
        next score
      end
      itemName = battle.pbGetDynamaxBandName(battler.index) 
      if battle.dynamax[ai.trainer.side][ai.trainer.trainer_index] == -1
        score = Battle::AI::ITEM_FAIL_SCORE
        PBDebug.log_score_change(score - old_score, "fails because trainer's #{itemName} is fully charged")
        next score
      end
      total_users = 0
      battle.eachInTeamFromBattlerIndex(ai.user.index) do |pkmn, i|
        total_users += 1 if pkmn.able? && !pkmn.dynamax? && pkmn.dynamax_able?
      end
      if total_users > 0
        score += 5 * total_users
        owner = battle.pbGetOwnerName(battler.index)
        PBDebug.log_score_change(score, "recharging #{owner}'s #{itemName}")
      else
        score = Battle::AI::ITEM_FAIL_SCORE
        PBDebug.log_score_change(score - old_score, "fails because no remaining Pokemon can Dynamax")
      end
    else
      score = Battle::AI::ITEM_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because item only usable as the trainer's first action")
    end
    next score
  }
)

#===============================================================================
# Radiant Tera Jewel
#===============================================================================
Battle::AI::Handlers::ItemEffectScore.add(:RADIANTTERAJEWEL,
  proc { |item, score, battler, ai, battle, firstAction|
    old_score = score
    if firstAction
      if !battle.pbHasTeraOrb?(battler.index)
        score = Battle::AI::ITEM_FAIL_SCORE
        PBDebug.log_score_change(score - old_score, "fails because trainer doesn't own an eligible Tera Orb")
        next score
      end
      itemName = battle.pbGetTeraOrbName(battler.index) 
      if battle.terastallize[ai.trainer.side][ai.trainer.trainer_index] == -1
        score = Battle::AI::ITEM_FAIL_SCORE
        PBDebug.log_score_change(score - old_score, "fails because trainer's #{itemName} is fully charged")
        next score
      end
      total_users = 0
      battle.eachInTeamFromBattlerIndex(ai.user.index) do |pkmn, i|
        total_users += 1 if pkmn.able? && !pkmn.tera? && pkmn.terastal_able?
      end
      if total_users > 0
        score += 5 * total_users
        owner = battle.pbGetOwnerName(battler.index)
        PBDebug.log_score_change(score, "recharging #{owner}'s #{itemName}")
      else
        score = Battle::AI::ITEM_FAIL_SCORE
        PBDebug.log_score_change(score - old_score, "fails because no remaining Pokemon can Terastallize")
      end
    else
      score = Battle::AI::ITEM_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because item only usable as the trainer's first action")
    end
    next score
  }
)