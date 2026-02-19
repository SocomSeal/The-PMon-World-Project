#===============================================================================
# Overhauls the entire AI related to using items into a modular system.
#===============================================================================
class Battle::AI
  #-----------------------------------------------------------------------------
  # Used for AI scoring of the viability of items.
  #-----------------------------------------------------------------------------
  ITEM_FAIL_SCORE    = 20
  ITEM_USELESS_SCORE = 60
  ITEM_BASE_SCORE    = 100
  
  #-----------------------------------------------------------------------------
  # Tracks restorative amounts for items that restore PP.
  #-----------------------------------------------------------------------------
  PP_HEAL_ITEMS = {
    :ETHER      => 10,
    :LEPPABERRY => 10,
    :HOPOBERRY  => 10,
    :MAXETHER   => 999
  }
  
  ALL_MOVE_PP_HEAL_ITEMS = {
    :ELIXIR    => 10,
    :MAXELIXIR => 999
  }
  
  #-----------------------------------------------------------------------------
  # Rewritten for item AI overhaul.
  #-----------------------------------------------------------------------------
  def choose_item_to_use
    return nil if !@battle.internalBattle || @battle.noBag
    items = @battle.pbGetOwnerItems(@user.index)
    return nil if !items || items.length == 0
    if @battle.launcherBattle?
      return nil if !@battle.pbCanUseLauncher?(@user.index)
      return nil if @battle.allOwnedByTrainer(@user.index).any? { |b| @battle.choices[b.index][0] == :UseItem }
    end
    choices = []
    pkmn = @battle.pbParty(@user.side)[@user.party_index]
    battler = @battle.pbFindBattler(@user.party_index, @user.side)
    firstAction = @battle.pbIsFirstAction?(@user.index)
    predicted_to_faint = @user.rough_end_of_round_damage >= @user.hp
    items.each do |item|
      next if !@battle.pbCanUseItemOnPokemon?(item, pkmn, battler, @battle.scene, false)
      args = [firstAction, @battle, @battle.scene, false]
      args.push(@user.index) if @battle.launcherBattle?
      itemData = GameData::Item.get(item)
      useType = (@battle.launcherBattle?) ? itemData.launcher_use : itemData.battle_use
      case useType
      #-------------------------------------------------------------------------
      # Items used on a battler or party Pokemon.
      when 1, 2
	    next if useType == 2 && predicted_to_faint
        @battle.eachInTeamFromBattlerIndex(@user.index) do |p, idxParty|
          battler = @battle.pbFindBattler(idxParty, @user.side)
          ai_battler = (battler) ? @battlers[battler.index] : @user
          if useType == 2  # Items used on a move (Ether, Leppa Berry, etc.)
            p.moves.length.times do |idxMove|
              next if !ItemHandlers.triggerCanUseInBattle(item, p, battler, idxMove, *args)
              next if @battle.pbItemAlreadyInUse?(item, @user.index, idxParty, idxMove)
              next if @battle.pbAlreadyHealingTarget?(item, @user.index, idxParty)
              score = ITEM_BASE_SCORE
              moveName = p.moves[idxMove].name
              PBDebug.log_ai("#{@user.name} is considering using item #{itemData.name} on party #{p.name} (party index #{idxParty}) [#{moveName}]...")
              score = Battle::AI::Handlers.pokemon_item_score(item, score, p, ai_battler, idxMove, self, @battle)
              score = Battle::AI::Handlers.apply_general_item_score_modifiers(score, item, idxParty, idxMove, self, @battle)
              choices.push([score, item, idxParty, idxMove])
            end
          else
            next if !ItemHandlers.triggerCanUseInBattle(item, p, battler, nil, *args)
            next if @battle.pbItemAlreadyInUse?(item, @user.index, idxParty)
            next if @battle.pbAlreadyHealingTarget?(item, @user.index, idxParty)
            score = ITEM_BASE_SCORE
            PBDebug.log_ai("#{@user.name} is considering using item #{itemData.name} on party #{p.name} (party index #{idxParty})...")
            score = Battle::AI::Handlers.pokemon_item_score(item, score, p, ai_battler, nil, self, @battle)
            score = Battle::AI::Handlers.apply_general_item_score_modifiers(score, item, idxParty, nil, self, @battle)
            choices.push([score, item, idxParty])
          end
        end
      #-------------------------------------------------------------------------
      # Items used only on an active battler.
      when 3, 6
	    next if predicted_to_faint
        @battle.allBattlers.each do |b|
          if useType == 3 # X Items only usable on user's own battlers.
            next if @user.side != b.idxOwnSide
            next if @trainer.trainer_index != @battle.pbGetOwnerIndexFromBattlerIndex(b.index)
          end
          next if !ItemHandlers.triggerCanUseInBattle(item, @user, b, nil, *args)
          next if @battle.pbItemAlreadyInUse?(item, @user.index, b.index)
          next if @battle.pbAlreadyTargetedByItem?(item, @user.index, b.index)
          score = ITEM_BASE_SCORE
          PBDebug.log_ai("#{@user.name} is considering using item #{itemData.name} on battler #{@battlers[b.index].name}...")
          idxTarget = (useType == 3) ? b.pokemonIndex : b.index
          score = Battle::AI::Handlers.battler_item_score(item, score, @battlers[b.index], self, @battle)
          score = Battle::AI::Handlers.apply_general_item_score_modifiers(score, item, idxTarget, nil, self, @battle)
          choices.push([score, item, idxTarget])
        end
      #-------------------------------------------------------------------------
      # Items used directly in battle.
      when 4, 5
	    next if predicted_to_faint
        next if !ItemHandlers.triggerCanUseInBattle(item, pkmn, battler, nil, *args)
        next if @battle.pbItemAlreadyInUse?(item, @user.index, -1)
        score = ITEM_BASE_SCORE
        PBDebug.log_ai("#{@user.name} is considering using item #{itemData.name}...")
        score = Battle::AI::Handlers.item_score(item, score, @user, self, @battle, firstAction)
        score = Battle::AI::Handlers.apply_general_item_score_modifiers(score, item, nil, nil, self, @battle)
        choices.push([score, item, -1])
      end
    end
    @battle.lastUsedItems[@user.side][@trainer.trainer_index] = nil
    # Determines if any items are worth using.
    if choices.empty? || !choices.any? { |c| c[0] > ITEM_FAIL_SCORE }
      PBDebug.log_ai("#{@user.name} couldn't find any usable items")
      return nil
    end
    max_score = 0
    choices.each { |c| max_score = c[0] if max_score < c[0] }
    if @trainer.high_skill?
      badItems = false
      if max_score <= ITEM_USELESS_SCORE
        badItems = true
      elsif max_score < ITEM_BASE_SCORE * move_score_threshold
        badItems = true if pbAIRandom(100) < 80
      end
      if badItems
        PBDebug.log_ai("#{@user.name} doesn't want to use any items")
        return nil
      end
    end
    # Calculate a minimum score threshold and reduce all item scores by it.
    threshold = (max_score * move_score_threshold.to_f).floor
    choices.each { |c| c[4] = [c[0] - threshold, 0].max }
    total_score = choices.sum { |c| c[4] }
    # Log the available choices.
    if $INTERNAL
      PBDebug.log_ai("Item choices for #{@user.name}:")
      choices.each_with_index do |c, i|
	    item_data = GameData::Item.get(c[1])
        chance = sprintf("%5.1f", (c[4] > 0) ? 100.0 * c[4] / total_score : 0)
        log_msg = "   * #{chance}% to use #{item_data.name}"
        case item_data.battle_use
        when 1 then log_msg += " (party index #{c[2]})"
        when 2 then log_msg += " (party index #{c[2]}, move index #{c[3]})"
        else        log_msg += " (battler index #{c[2]})" if c[2] >= 0
        end
        log_msg += ": score #{c[0]}"
        PBDebug.log(log_msg)
      end
    end
    # Pick an item randomly from choices weighted by their scores and log the result.
    randNum = pbAIRandom(total_score)
    choices.each do |c|
      randNum -= c[4]
      next if randNum >= 0
      item_data = GameData::Item.get(c[1])
      log_msg = "   => will use #{item_data.name}"
      case item_data.battle_use
      when 1 then log_msg += " (party index #{c[2]})"
      when 2 then log_msg += " (party index #{c[2]}, move index #{c[3]})"
      else        log_msg += " (battler index #{c[2]})" if c[2] >= 0
      end
      PBDebug.log(log_msg)
      @battle.lastUsedItems[@user.side][@trainer.trainer_index] = c[1..3]
      return c[1], c[2], c[3]
    end
    return nil
  end
  
  #-----------------------------------------------------------------------------
  # Utility for scoring the use of items that change a battler's stat stages.
  #-----------------------------------------------------------------------------
  def get_item_score_for_target_stat_change(score, target, stat, increment, statUp = true)
    old_score = score
    if target.rough_end_of_round_damage >= target.hp
      score = ITEM_USELESS_SCORE
      PBDebug.log_score_change(score - old_score, "useless because #{target.name} predicted to faint this round")
      return score
    end
    if target.opponent_side_has_ability?(:UNAWARE) &&
       !target.has_move_with_function?("PowerHigherWithUserPositiveStatStages")
      score = ITEM_USELESS_SCORE
      PBDebug.log_score_change(score - old_score, "useless because #{target.name}'s foes have Unaware")
      return score
    end
    statName = GameData::Stat.get(stat).name
    increment *= 2 if target.has_active_ability?(:SIMPLE)
    increment = [increment, Battle::Battler::STAT_STAGE_MAXIMUM - target.stages[stat]].min
    statUp = !statUp if target.has_active_ability?(:CONTRARY)
    has_stat_loss_prevention = (
      target.pbOwnSide.effects[PBEffects::Mist] > 0 ||
      target.has_active_item?(:CLEARAMULET) ||
      target.has_active_ability?([:CLEARBODY, :WHITESMOKE, :FULLMETALBODY])
    )
    foe_can_punish_stat_change = target.opponent_side_has_function?(
      "ResetTargetStatStages",                  # Clear Smog
      "InvertTargetStatStages",                 # Topsy-Turvy
      "UserTargetSwapStatStages",               # Heart Swap
      "UserCopyTargetStatStages",               # Psych Up
      "ResetAllBattlersStatStages",             # Haze
      "UserStealTargetPositiveStatStages",      # Spectral Thief
      "PowerHigherWithTargetPositiveStatStages" # Punishment
    )
    if statUp
      desire_mult = (target.opposes?(@user)) ? -1 : 1
      if stat_raise_worthwhile?(target, stat)
        if @trainer.has_skill_flag?("HPAware")
          score += increment * desire_mult * ((100 * target.hp / target.totalhp) - 50) / 8
          old_score = score
        end
        if target.opposes?(@user) && Battle::AbilityEffects::OnStatGain[target.ability_id]
          score -= 20
          abilName = GameData::Ability.get(target.ability_id).name
          PBDebug.log_score_change(score - old_score, "prefers not to raise stats due to #{target.name}'s #{abilName} ability")
          old_score = score
        end
        if has_stat_loss_prevention
          score += 10 * desire_mult
          PBDebug.log_score_change(score - old_score, "#{target.name}'s stats are protected from being lowered")
          old_score = score
        end
        if foe_can_punish_stat_change
          score -= 20 * desire_mult
          PBDebug.log_score_change(score - old_score, "#{target.name}'s foes have moves that counters stat increases")
          old_score = score
        end
        if !target.opposes?(@user)
          target.moves.each do |m|
            next if m.pp == 0
            if m.is_a?(Battle::Move::StatUpMove)
              case stat
              when :ATTACK          then statFunction = "Attack"
              when :DEFENSE         then statFunction = "Defense"
              when :SPECIAL_ATTACK  then statFunction = "SpAtk"
              when :SPECIAL_DEFENSE then statFunction = "SpDef"
              when :SPEED           then statFunction = "Speed"
              when :ACCURACY        then statFunction = "Accuracy"
              when :EVASION         then statFunction = "Evasion"
              end
              (Battle::Battler::STAT_STAGE_MAXIMUM).downto(1).each do |i|
                next if !m.function_code.include?("RaiseUser" + statFunction + i.to_s)
                stage_score = (i >= increment) ? 30 : (increment - i) * 5
                stage_score *= 2 if m.statusMove? || m.addlEffect == 100
                score -= stage_score
                break
              end
              PBDebug.log_score_change(score - old_score, "move #{m.name} can already raise #{statName}") if score != old_score
            elsif m.is_a?(Battle::Move::MultiStatUpMove)
              score -= 30
              PBDebug.log_score_change(score - old_score, "move #{m.name} can raise multiple stats at once")
            end
            old_score = score
          end
        end
        score = (get_target_stat_raise_score_one(score, target, stat, increment, desire_mult)).round.to_i
        score = ITEM_USELESS_SCORE if target.opposes?(@user) && score < old_score
        PBDebug.log_score_change(score - old_score, "raising #{target.name}'s #{statName} stat")
        return score
      else
        score = ITEM_USELESS_SCORE
        PBDebug.log_score_change(score - old_score, "useless because raising #{target.name}'s #{statName} isn't worthwhile")
        return score
      end
    else
      desire_mult = (target.opposes?(@user)) ? 1 : -1
      if !has_stat_loss_prevention && stat_drop_worthwhile?(target, stat)
        if @trainer.has_skill_flag?("HPAware")
          score += increment * desire_mult * ((100 * target.hp / target.totalhp) - 50) / 8
          old_score = score
        end
        if target.opposes?(@user) && Battle::AbilityEffects::OnStatLoss[target.ability_id]
          score -= 20
          abilName = GameData::Ability.get(target.ability_id).name
          PBDebug.log_score_change(score - old_score, "prefers not to lower stats due to #{target.name}'s #{abilName} ability")
          old_score = score
        end
        if foe_can_punish_stat_change
          score -= 20 * desire_mult
          PBDebug.log_score_change(score - old_score, "#{target.name}'s foes have moves that don't want lowered stats")
          old_score = score
        end
        score = (get_target_stat_drop_score_one(score, target, stat, increment, desire_mult)).round.to_i
        score = ITEM_USELESS_SCORE if !target.opposes?(@user) && score < old_score
        PBDebug.log_score_change(score - old_score, "lowering #{target.name}'s #{statName} stat")
        return score
      else
        score = ITEM_USELESS_SCORE
        PBDebug.log_score_change(score - old_score, "useless because lowering #{target.name}'s #{statName} isn't worthwhile")
        return score
      end
    end
  end
end

#===============================================================================
# New AI item handlers for item usage.
#===============================================================================
module Battle::AI::Handlers
  GeneralItemScore       = HandlerHash.new
  ItemEffectScore        = ItemHandlerHash.new
  PokemonItemEffectScore = ItemHandlerHash.new
  BattlerItemEffectScore = ItemHandlerHash.new
  
  def self.apply_general_item_score_modifiers(score, *args)
    GeneralItemScore.each do |id, score_proc|
      new_score = score_proc.call(score, *args)
      score = new_score if new_score
    end
    return score
  end

  def self.item_score(item, score, *args)
    ret = ItemEffectScore.trigger(item, score, *args)
    return (ret.nil?) ? score : ret
  end

  def self.pokemon_item_score(item, score, *args)
    ret = PokemonItemEffectScore.trigger(item, score, *args)
    return (ret.nil?) ? score : ret
  end
  
  def self.battler_item_score(item, score, *args)
    ret = BattlerItemEffectScore.trigger(item, score, *args)
    return (ret.nil?) ? score : ret
  end
end

#-------------------------------------------------------------------------------
# General AI handler for considering inventory counts.
#-------------------------------------------------------------------------------
Battle::AI::Handlers::GeneralItemScore.add(:inventory_count,
  proc { |score, item, idxPkmn, idxMove, ai, battle|
    next score if battle.launcherBattle?
    count = -1
    old_score = score
    nonConsumable = false
    items = battle.pbGetOwnerItems(ai.user.index)
    items.each do |itm| 
      next if itm != item
      if GameData::Item.get(itm).consumed_after_use?
        count += 1
      else
      nonConsumable = true
      break
      end
    end
    if nonConsumable
      score += 10
      PBDebug.log_score_change(score - old_score, "prefers to use item because it isn't consumable")
    elsif count > 0
      score += 5 * count
      PBDebug.log_score_change(score - old_score, "prefers to use item because there's more in stock")
    else
      score -= 8
      PBDebug.log_score_change(score - old_score, "prefers not to use item because it's last in stock")
    end
    next score
  }
)

#-------------------------------------------------------------------------------
# General AI handler for discouraging successive item use.
#-------------------------------------------------------------------------------
Battle::AI::Handlers::GeneralItemScore.add(:discourage_successive_use,
  proc { |score, item, idxPkmn, idxMove, ai, battle|
    old_score = score
    lastItem = battle.lastUsedItems[ai.user.side][ai.trainer.trainer_index]
    next score if !lastItem
    if ai.trainer.high_skill?
      score -= 60
    elsif ai.trainer.medium_skill?
      score -= 50
    else
      score -= 40
    end
    PBDebug.log_score_change(score - old_score, "prefers not to use items on successive turns")
    if idxPkmn && idxPkmn == lastItem[1] && battle.pbAbleCount(ai.user.side) > 1
      old_score = score
      if battle.pbItemHealsHP?(item) && battle.pbItemHealsHP?(lastItem[0])
        score -= 20
        PBDebug.log_score_change(score - old_score, "prefers not to use HP-restoring items repeatedly on the same Pokemon")
      elsif battle.pbItemRestoresPP?(item) && battle.pbItemRestoresPP?(lastItem[0])
        score -= 30
        PBDebug.log_score_change(score - old_score, "prefers not to use PP-restoring items repeatedly on the same Pokemon")
      elsif battle.pbItemRaisesStats?(item) && battle.pbItemRaisesStats?(lastItem[0])
        score -= 20
        PBDebug.log_score_change(score - old_score, "prefers not to use stat-boosting items repeatedly on the same Pokemon")
      end
    end
    next score
  }
)