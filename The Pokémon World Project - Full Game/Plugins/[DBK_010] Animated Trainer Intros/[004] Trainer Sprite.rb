#===============================================================================
# Trainer sprite (used in battle)
#===============================================================================
class Battle::Scene::TrainerSprite < RPG::Sprite
  attr_reader   :name
  attr_reader   :tr_type
  attr_accessor :index
  attr_accessor :numTrainers

  def initialize(viewport, numTrainers, index, battleAnimations)
    super(viewport)
    @name             = ""
    @tr_type          = nil
    @numTrainers      = numTrainers
    @index            = index
    @battleAnimations = battleAnimations
    @_iconBitmap      = nil
    @shadowSprite     = Sprite.new(viewport)
  end
  
  def ox=(value)
    super
    @shadowSprite.ox = value
  end
  
  def oy=(value)
    super
    @shadowSprite.oy = value
  end
  
  def x=(value)
    super
    offset = GameData::TrainerType.get(@tr_type).shadow_xy[0]
    @shadowSprite.x = self.x + offset
  end
  
  def y=(value)
    super
    offset = GameData::TrainerType.get(@tr_type).shadow_xy[1]
    @shadowSprite.y = self.y + offset
  end
  
  def bitmap=(value)
    super
    @shadowSprite.bitmap = value
  end
  
  def mirror=(value)
    super
    @shadowSprite.mirror = value
  end
  
  def angle=(value)
    super
    @shadowSprite.angle = value
  end
  
  def opacity=(value)
    super
    @shadowSprite.opacity = self.opacity.clamp(0, 100)
  end
  
  def visible=(value)
    super
    value = false if !shows_shadow?
    @shadowSprite.visible = value
  end
  
  #-----------------------------------------------------------------------------
  # General utilities.
  #-----------------------------------------------------------------------------
  def dispose
    @_iconBitmap&.dispose
    @_iconBitmap = nil
    self.bitmap = nil if !self.disposed?
    @shadowSprite.bitmap = nil
    super
  end

  def width;  return (self.bitmap) ? self.bitmap.width : 0;  end
  def height; return (self.bitmap) ? self.bitmap.height : 0; end
  
  #-----------------------------------------------------------------------------
  # Related to animations and frames.
  #-----------------------------------------------------------------------------
  def animated?
    return !@_iconBitmap.nil? && @_iconBitmap.is_a?(TrainerBitmapWrapper)
  end
  
  def static?
    return true if !animated?
    return @_iconBitmap.length > 1
  end
  
  def finished?
    return true if !animated?
    return @_iconBitmap.finished?
  end
  
  def play
    return if !animated?
    @_iconBitmap.play
    self.bitmap = @_iconBitmap.bitmap
  end
  
  def deanimate
    return if !animated?
    @_iconBitmap.deanimate
    self.bitmap = @_iconBitmap.bitmap
  end
  
  def to_first_frame
    return if !animated?
    @_iconBitmap.to_frame(0)
    self.bitmap = @_iconBitmap.bitmap
  end
  
  def to_last_frame
    return if !animated?
    @_iconBitmap.to_frame("last")
    self.bitmap = @_iconBitmap.bitmap
  end
  
  def reversed?
    return false if !animated?
    return @_iconBitmap.reversed
  end
  
  def reversed=(value)
    return if !animated?
    @_iconBitmap.reversed = value
  end
  
  def hue=(value)
    return if !animated?
    return if @_iconBitmap.changedHue?
    value = 255 if value > 255
    value = -255 if value < -255
    @_iconBitmap.hue_change(value)
    self.bitmap = @_iconBitmap.bitmap
  end
  
  def iconBitmap; return @_iconBitmap; end
  
  def update; end # Purposefully left empty.
    
  def pbPlayIntroAnimation(pictureEx = nil)
  end
  
  #-----------------------------------------------------------------------------
  # Related to setting coordinates and position.
  #-----------------------------------------------------------------------------
  def pbSetPosition
    return if !@_iconBitmap
    self.ox = @_iconBitmap.width / 2
    self.oy = @_iconBitmap.height
    p = Battle::Scene.pbTrainerPosition(1, @index, @numTrainers)
    self.x = p[0]
    self.y = p[1]
    self.z = 10 - @index
    if shows_shadow?
      @shadowSprite.z = 7 - @index
      @shadowSprite.zoom_x = 1.1
      @shadowSprite.zoom_y = 0.25
      @shadowSprite.color = Color.black
      @shadowSprite.opacity = 100
    end
  end
  
  def shows_shadow?
    return false if !animated?
    data = GameData::TrainerType.try_get(@tr_type)
    return false if !data
    return data.shows_shadow?
  end
  
  #-----------------------------------------------------------------------------
  # Used to set the sprite or shadow of a particular trainer or trainer type.
  #-----------------------------------------------------------------------------
  def setTrainerBitmap(tr_type)
    @tr_type = tr_type
    @_iconBitmap&.dispose
    @name = GameData::TrainerType.front_sprite_filename(@tr_type)
    @_iconBitmap = GameData::TrainerType.front_sprite_bitmap(@tr_type)
    @_iconBitmap.setTrainer(@tr_type)
    self.bitmap = (@_iconBitmap) ? @_iconBitmap.bitmap : nil
    pbSetPosition
  end
  
  def name=(value)
    return if nil_or_empty?(value)
    split_file = value.split(/[\\\/]/)
    trType = split_file.pop.to_sym
    path = split_file.join("/") + "/"
    return if path != "Graphics/Trainers/"
    return if !GameData::TrainerType.exists?(trType)
    setTrainerBitmap(trType)
  end
end

#===============================================================================
# Adds utilities in the IconSprite class for animated trainer sprites.
#===============================================================================
class IconSprite < Sprite
  #-----------------------------------------------------------------------------
  # Aliased to set new trainer bitmap wrapper if the sprite is a trainer.
  #-----------------------------------------------------------------------------
  alias animtrainer_setBitmap setBitmap
  def setBitmap(file, hue = 0)
    if file
      split_file = file.split(/[\\\/]/)
      filename = split_file.pop
      path = split_file.join("/") + "/"
      if path == "Graphics/Trainers/" && !filename.include?("_back")
        if GameData::TrainerType.exists?(filename.to_sym)
          setTrainerBitmap(filename.to_sym, false)
          return
        else
          split_file = filename.split("_")
          split_file.pop
          trainer_type = split_file.join("_").to_sym
          setTrainerBitmap(trainer_type, false, true)
          return
        end
      end
      animtrainer_setBitmap(file, hue)
    else
      animtrainer_setBitmap(file, hue)
    end
  end  

  #-----------------------------------------------------------------------------
  # Used to set the sprite or shadow of a particular trainer type.
  #-----------------------------------------------------------------------------
  def setTrainerBitmap(trType, shadow = false, player_outfit = false)
    oldrc = self.src_rect
    clearBitmaps
    if player_outfit
      @name = GameData::TrainerType.player_front_sprite_filename(trType)
    else
      @name = GameData::TrainerType.front_sprite_filename(trType)
    end
    @name = "Graphics/Trainers/000" if !@name
    if GameData::TrainerType.exists?(trType)
      @_iconbitmap = GameData::TrainerType.front_sprite_bitmap(trType, @name)
      @_iconbitmap.setTrainer(trType)
      self.bitmap = @_iconbitmap ? @_iconbitmap.bitmap : nil
      self.src_rect = oldrc
      self.ox = @_iconbitmap.width / 2
      self.oy = @_iconbitmap.height
      if shadow
        self.zoom_x  = 1.1
        self.zoom_y  = 0.25
        self.color   = Color.black
        self.opacity = 100
      end
    else
      @_iconbitmap = nil
    end
  end
  
  #-----------------------------------------------------------------------------
  # Related to animations and frames.
  #-----------------------------------------------------------------------------
  def animated?
    return !@_iconbitmap.nil? && @_iconbitmap.is_a?(TrainerBitmapWrapper)
  end
  
  def static?
    return true if !animated?
    return @_iconbitmap.length > 1
  end
  
  def finished?
    return true if !animated?
    return @_iconbitmap.finished?
  end
  
  def play
    return if !animated?
    @_iconbitmap.play
    self.bitmap = @_iconbitmap.bitmap
  end
  
  def deanimate
    return if !animated?
    @_iconbitmap.deanimate
    self.bitmap = @_iconbitmap.bitmap
  end
  
  def to_first_frame
    return if !animated?
    @_iconbitmap.deanimate
    self.bitmap = @_iconbitmap.bitmap
  end
  
  def to_last_frame
    return if !animated?
    @_iconbitmap.to_frame("last")
    self.bitmap = @_iconbitmap.bitmap
  end
  
  def reversed?
    return false if !animated?
    return @_iconbitmap.reversed
  end
  
  def reversed=(value)
    return if !animated?
    @_iconbitmap.reversed = value
  end
  
  def hue=(value)
    return if !animated?
    return if @_iconbitmap.changedHue?
    value = 255 if value > 255
    value = -255 if value < -255
    @_iconbitmap.hue_change(value)
    self.bitmap = @_iconbitmap.bitmap
  end
  
  def iconBitmap; return @_iconbitmap; end
  
  def update
    return if animated?
    super
  end
end