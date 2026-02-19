class PokemonRegionMap_Scene
  def findUsableUI(image)
    if ThemePlugin
      # Use Current set Theme's UI Graphics
      return "#{Folder}UI/#{$PokemonSystem.pokegear}/#{image}"
    else
      folderUI = "UI/Region#{@region}/"
      bitmap = pbResolveBitmap("#{Folder}#{folderUI}#{image}")
      if bitmap && RegionUI
        # Use UI Graphics for the Current Region.
        return "#{Folder}#{folderUI}#{image}"
      else
        # Use Default UI Graphics.
        return "#{Folder}UI/#{UIFolder}/#{image}"
      end
    end
  end

  def getTimeOfDay
    path = "#{Folder}Regions/"
    return "#{path}#{@regionFile}" if !ARMSettings::TimeBasedRegionMap
    if PBDayNight.isDay?
      time = "Day"
    elsif PBDayNight.isNight?
      time = "Night"
    elsif PBDayNight.isMorning?
      time = "Morning"
    elsif PBDayNight.isAfternoon?
      time = "Afternoon"
    elsif PBDayNight.isEvening?
      time = "Evening"
    end
    file = @regionFile.chomp(".png") << time << ".png"
    bitmap = pbResolveBitmap("#{path}#{file}")
    unless bitmap
      case time
      when /Morning|Afternoon|Evening|Night/
        time = "Day"
      else
        Console.echoln_li _INTL("There was no file named '#{file}' found.")
        time = ""
      end
    end
    file = @regionFile.chomp(".png") << time << ".png"
    return "#{path}#{file}"
  end

  def locationShown?(point)
    return (point[5] == nil && point[1] > 0 && $game_switches[point[1]]) || point[5] if @wallmap
    return point[1] > 0 && $game_switches[point[1]]
  end

  def createObject
    object = {
      offsetX: 0,
      offsetY: 0,
      newX: 0,
      newY: 0,
      oldX: 0,
      oldY: 0
    }
    return object
  end

  def getMapFolderName(image)
    name = image[:name]
    case name
    when /Route/
      mapFolder = "Routes"
    else
      mapFolder = "Others"
    end
    return mapFolder
  end

  def adjustPosX(value, add = false, region = @region)
    return value += @regionData[region][:beginX] if add
    return value -= @regionData[region][:beginX]
  end

  def adjustPosY(value, add = false, region = @region)
    return value += @regionData[region][:beginY] if add
    return value -= @regionData[region][:beginY]
  end
end
