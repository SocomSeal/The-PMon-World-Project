#=====================================================================
# Regicode by Spectator
#=====================================================================

Introduction:
This plugin allows you to display braille-style messages similar to those used in Pokémon RSE, FRLG, and ORAS.
By using a script command (see Usage), the plugin will display Regi-style code using graphics from:
Graphics/UI/Regicode.

Usage:
To display a braille message, use the following script command in an event:
    RC.show("[message]")

Commands:
- Use `/` to start a new row (line).
- Use `\\` to end the current message block and begin a new one.
- Use `-` to create a space between words.  
  Example: `Hello-stranger` will show "HELLO STRANGER".

Note:
- A maximum of **11 characters per row** is supported. Characters beyond this will be rendered out of frame.
- You can display up to **4 rows per message block**. Additional rows will be shown out of frame.
- This plugin is plug-and-play — no manual configuration is needed.
