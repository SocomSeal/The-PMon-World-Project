# Braille [RegiCode] made by Spectator

module RC
  FOLDER_PATH     = "Graphics/UI/Regicode/"
  CHAR_WIDTH      = 18
  CHAR_HEIGHT     = 12
  LETTER_SPACING  = 2
  SPACE_WIDTH     = 12
  PADDING_X       = 8
  PADDING_Y       = 12
  SCALE_FACTOR    = 2.0
  MAX_LETTERS_PER_LINE = 11
  MAX_LINES       = 4
  MAX_LETTERS     = MAX_LETTERS_PER_LINE * MAX_LINES
  LINE_OFFSET_Y   = 107

  CHAR_MAP = {
    '.' => '+',
    '?' => '[',
    '-' => '-',
  }

  LINE_OFFSETS = {
    1 => { x: 35, y: 240 },
    2 => { x: 35, y: 196 },
    3 => { x: 35, y: 152 },
    4 => { x: 35, y: 108 }
  }

  def self.show(text)
    segments = text.upcase.split('\\')

    line_width_px = (CHAR_WIDTH + LETTER_SPACING) * MAX_LETTERS_PER_LINE * SCALE_FACTOR
    max_win_width = line_width_px + PADDING_X * 2 + 20
    line_height = (CHAR_HEIGHT + 10) * SCALE_FACTOR
    extra_height_per_line = 10

    viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    viewport.z = 1000

    segments.each_with_index do |segment, index|
      message = segment
      line_count = message.count('/') + 1
      lines_needed = [[line_count, 1].max, MAX_LINES].min

      win_width = max_win_width
      win_height = (line_height * lines_needed) + PADDING_Y * 2 + (lines_needed - 1) * extra_height_per_line
      win_height += 100 if lines_needed == 3

      win_x = (Graphics.width - win_width) / 2
      win_y = case lines_needed
              when 1 then Graphics.height - win_height - 110
              when 2 then (Graphics.height - win_height) / 2 + LINE_OFFSET_Y - 72
              when 3 then (Graphics.height - win_height) / 2 + LINE_OFFSET_Y - 46
              when 4 then (Graphics.height - win_height) / 2 + LINE_OFFSET_Y - 93
              end

      bg_sprite = Sprite.new(viewport)
      bg_sprite.bitmap = Bitmap.new("Graphics/UI/Regicode/Window_#{lines_needed}.png")
      bg_sprite.x = win_x
      bg_sprite.y = win_y
      bg_sprite.z = 998

      x = 0
      y = 0
      letters_in_line = 0
      sprites = []

      offset = LINE_OFFSETS[lines_needed] || { x: 10, y: 6 }

      message.each_char do |char|
        if char == '/'
          x = 0
          y += line_height
          letters_in_line = 0
          next
        end

        if char == '-'
          x += (CHAR_WIDTH + LETTER_SPACING) * SCALE_FACTOR
          letters_in_line += 1
          if letters_in_line >= MAX_LETTERS_PER_LINE
            x = 0
            y += line_height
            letters_in_line = 0
          end
          next
        end

        mapped_char = CHAR_MAP[char] || char
        path = FOLDER_PATH + "#{mapped_char}.png"
        resolved_path = pbResolveBitmap(path)
        next unless resolved_path

        if letters_in_line >= MAX_LETTERS_PER_LINE
          x = 0
          y += line_height
          letters_in_line = 0
        end

        sprite = Sprite.new(viewport)
        sprite.bitmap = Bitmap.new(resolved_path)
        sprite.x = x.to_i + offset[:x]
        sprite.y = y.to_i + offset[:y]
        sprite.zoom_x = SCALE_FACTOR
        sprite.zoom_y = SCALE_FACTOR
        sprite.z = 1001
        sprites << sprite

        x += (CHAR_WIDTH + LETTER_SPACING) * SCALE_FACTOR
        letters_in_line += 1
      end

      self.wait_for_input

      sprites.each(&:dispose) unless index == segments.size - 1
      bg_sprite.dispose
    end

		viewport.dispose if !viewport.disposed?

  end

  def self.wait_for_input
    loop do
      Graphics.update
      Input.update
      break if Input.trigger?(Input::C) || Input.trigger?(Input::B)
    end
    loop do
      Graphics.update
      Input.update
      break if !Input.press?(Input::C) && !Input.press?(Input::B)
    end
  end
end
