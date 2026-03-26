#===============================================================================
# Battle utilities for new item AI.
#===============================================================================
class Battle
  attr_accessor :lastUsedItems
  
  alias itemAI_initialize initialize
  def initialize(*args)
    itemAI_initialize(*args)
    @lastUsedItems = [[], []]
  end
  
  #-----------------------------------------------------------------------------
  # Utilities for checking for certain types of items.
  #-----------------------------------------------------------------------------
  def pbItemRevivesFainted?(item)
    return Battle::AI::REVIVE_ITEMS.keys.include?(item)
  end
  
  def pbItemRaisesStats?(item, oneStat = false)
    return true if Battle::AI::ONE_STAT_RAISE_ITEMS.keys.include?(item)
    return true if !oneStat && Battle::AI::ALL_STATS_RAISE_ITEMS.include?(item)
    return false
  end
  
  def pbItemHealsHP?(item, onlyHP = false)
    return true if Battle::AI::HP_HEAL_ITEMS.keys.include?(item)
    return true if !onlyHP && Battle::AI::FULL_RESTORE_ITEMS.include?(item)
    return false
  end
  
  def pbItemRestoresPP?(item, mode = 0)
    return true if mode <= 1 && Battle::AI::PP_HEAL_ITEMS.keys.include?(item)
    return true if mode != 1 && Battle::AI::ALL_MOVE_PP_HEAL_ITEMS.keys.include?(item)
    return false
  end
  
  def pbItemCuresStatus?(item, oneStatus = false)
    return true if Battle::AI::ONE_STATUS_CURE_ITEMS.include?(item)
    return true if !oneStatus && Battle::AI::ALL_STATUS_CURE_ITEMS.include?(item)
    return true if !oneStatus && Battle::AI::FULL_RESTORE_ITEMS.include?(item)
    return false
  end
  
  #-----------------------------------------------------------------------------
  # Returns the value of certain items based on the type of item it is.
  #-----------------------------------------------------------------------------
  def pbGetItemValue(item, itemType)
    ret = nil
    case itemType
    when :revive then ret = Battle::AI::REVIVE_ITEMS[item]
    when :potion then ret = Battle::AI::HP_HEAL_ITEMS[item]
    when :ether  then ret = Battle::AI::PP_HEAL_ITEMS[item]
    when :elixir then ret = Battle::AI::ALL_MOVE_PP_HEAL_ITEMS[item]
    when :stats  then ret = Battle::AI::ONE_STAT_RAISE_ITEMS[item]
    end
    return ret
  end

  #-----------------------------------------------------------------------------
  # Utility for determining if a trainer has made any command selections yet.
  #-----------------------------------------------------------------------------
  def pbIsFirstAction?(idxBattler)
    return !allOwnedByTrainer(idxBattler).any? { |b| @choices[b.index][0] != :None }
  end
  
  #-----------------------------------------------------------------------------
  # Utility for determining if an item is already selected to be used by a trainer.
  #-----------------------------------------------------------------------------
  def pbItemAlreadyInUse?(item, idxBattler, idxTarget = nil, idxMove = nil)
    eachSameSideBattler(idxBattler) do |b|
      choices = @choices[b.index]
      return true if choices == [:UseItem, item, idxTarget, idxMove]
    end
    return false
  end
  
  #-----------------------------------------------------------------------------
  # Utility for determining if a trainer has a weaker healing item to use.
  #-----------------------------------------------------------------------------
  def pbHasHealingItem?(idxBattler, healAmt = 1000, itemType = :potion)
    items = pbGetOwnerItems(idxBattler)
    side = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    items.each do |itm|
      if launcherBattle?
        itemPoints = GameData::Item.get(itm).launcher_points
        next if @launcherPoints[side][owner] < itemPoints
      end
      case itemType
      when :potion then next if !pbItemHealsHP?(itm, true)
      when :ether  then next if !pbItemRestoresPP?(itm, 1)
      when :elixir then next if !pbItemRestoresPP?(itm, 2)
      end
      return true if pbGetItemValue(itm, itemType) < healAmt
    end
    return false
  end
  
  #-----------------------------------------------------------------------------
  # Utility for determining if a Pokemon is already selected to be healed by an item.
  #-----------------------------------------------------------------------------
  def pbAlreadyHealingTarget?(item, idxBattler, idxTarget)
    eachSameSideBattler(idxBattler) do |b|
      ch = @choices[b.index]
      if ch[0] == :UseItem && ch[2] == idxTarget
        if pbItemHealsHP?(item)
          return true if pbItemHealsHP?(ch[1])
        elsif pbItemCuresStatus?(item)
          return true if pbItemCuresStatus?(ch[1])
        elsif pbItemRestoresPP?(item)
          return true if pbItemRestoresPP?(ch[1])
        end
      end
    end
    return false
  end
  
  #-----------------------------------------------------------------------------
  # Utility for determining if a battler is already selected to be targeted by an item.
  #-----------------------------------------------------------------------------
  def pbAlreadyTargetedByItem?(item, idxBattler, idxTarget)
    eachSameSideBattler(idxBattler) do |b|
      ch = @choices[b.index]
      if ch[0] == :UseItem && ch[2] == idxTarget
        return true if ch[1] == item
        return true if pbItemRaisesStats?(item) && pbItemRaisesStats?(ch[1])
      end
    end
    return false
  end
end