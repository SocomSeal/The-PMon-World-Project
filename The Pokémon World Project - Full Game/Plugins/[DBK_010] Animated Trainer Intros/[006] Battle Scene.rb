#===============================================================================
# Additions to the Battle::Scene class.
#===============================================================================
class Battle::Scene
  #-----------------------------------------------------------------------------
  # Rewritten to set new trainer bitmaps for front sprites.
  #-----------------------------------------------------------------------------
  def pbCreateTrainerFrontSprite(idxTrainer, trainerType, numTrainers = 1)
    trSprite = TrainerSprite.new(@viewport, numTrainers, idxTrainer, @animations)
    trSprite.setTrainerBitmap(trainerType)
    @sprites["trainer_#{idxTrainer + 1}"] = trSprite
  end
  
  #-----------------------------------------------------------------------------
  # Aliased to set hues on trainer back sprites.
  #-----------------------------------------------------------------------------
  alias animtrainer_pbCreateTrainerBackSprite pbCreateTrainerBackSprite
  def pbCreateTrainerBackSprite(idxTrainer, trainerType, numTrainers = 1)
    animtrainer_pbCreateTrainerBackSprite(idxTrainer, trainerType, numTrainers)
    hue = GameData::TrainerType.get(trainerType).trainer_sprite_hue
    @sprites["player_#{idxTrainer + 1}"].bitmap.hue_change(hue) if hue != 0
  end
  
  #-----------------------------------------------------------------------------
  # Utility for animating all trainer intros at the start of battle.
  #-----------------------------------------------------------------------------
  def pbAnimateTrainerIntros
    return if !@battle.opponent
    idxTrainers = []
    @battle.opponent.length.times do |i|
      sprite = @sprites["trainer_#{i + 1}"]
      next if !sprite || !sprite.visible || !sprite.bitmap || sprite.finished?
      idxTrainers.push(i + 1)
    end
    return if idxTrainers.empty?
    anims_done = 0
    loop do 
      pbUpdate
      idxTrainers.each do |i|
        next if @sprites["trainer_#{i}"].finished?
        @sprites["trainer_#{i}"]&.play
        anims_done += 1 if @sprites["trainer_#{i}"].finished?
      end
      break if anims_done == idxTrainers.length
    end
  end
  
  #---------------------------------------------------------------------------
  # Midbattle speech utilities.
  #---------------------------------------------------------------------------
  def pbShowAnimatedSpeaker(idxBattler, idxTarget = nil, reversed = false, params = nil)
    params = pbConvertBattlerIndex(idxBattler, idxTarget, params)
    params = idxBattler if !params
    pbUpdateSpeaker(*params)
    return if !@showSpeaker
    speaker = @sprites["midbattle_speaker"]
    if reversed
      speaker.to_last_frame
      speaker.reversed = true
    else
      speaker.to_first_frame
    end
    appearAnim = Animation::SlideSpriteAppear.new(@sprites, @viewport, @battle)
    @animations.push(appearAnim)
    while inPartyAnimation?
      pbUpdate
    end
    loop do 
      pbUpdate
      break if speaker.finished?
      speaker&.play
    end
  end
  
  def pbHideAnimatedSpeaker(reversed = false)
    speaker = @sprites["midbattle_speaker"]
    return if !speaker.visible
    if reversed == :Reversed
      speaker.to_last_frame
      speaker.reversed = true
    else
      speaker.to_first_frame
    end
    pbHideSpeakerWindows
    loop do 
      pbUpdate
      break if speaker.finished?
      speaker&.play
    end
    hideAnim = Animation::SlideSpriteDisappear.new(@sprites, @viewport, @battle, @battle.decision > 0)
    @animations.push(hideAnim)
    while inPartyAnimation?
      pbUpdate
    end
  end
end

#===============================================================================
# Midbattle triggers.
#===============================================================================

#-------------------------------------------------------------------------------
# Slides a new speaker on screen and animates them prior to displaying text.
#-------------------------------------------------------------------------------
MidbattleHandlers.add(:midbattle_triggers, "setAnimSpeaker",
  proc { |battle, idxBattler, idxTarget, params|
    reversed = false
    if params.is_a?(Array) && params.last == :Reversed
      params = params[0..params.length - 2]
      reversed = true
    end
    if !battle.scene.pbInCinematicSpeech?
      battle.scene.pbToggleDataboxes 
      battle.scene.pbToggleBlackBars(true)
    end
    battle.scene.pbHideSpeaker
    battle.scene.pbShowAnimatedSpeaker(idxBattler, idxTarget, reversed, params)
    speaker = battle.scene.pbGetSpeaker
    battle.scene.pbShowSpeakerWindows(speaker)
    PBDebug.log("     'setAnimSpeaker': showing new speaker with animation (#{speaker.name})")
  }
)

#-------------------------------------------------------------------------------
# Animates a speaker prior to sliding them off screen.
#-------------------------------------------------------------------------------
MidbattleHandlers.add(:midbattle_triggers, "hideAnimSpeaker",
  proc { |battle, idxBattler, idxTarget, params|
    next if !battle.scene.sprites["midbattle_speaker"].visible
    battle.scene.pbHideAnimatedSpeaker(params)
    PBDebug.log("     'endSpeech': hiding active speaker after animation")
  }
)