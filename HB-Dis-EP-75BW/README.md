## Script Helper für Jérôme's 7.5" ePaper Display Projekt [HB-Dis-EP-75BW](https://github.com/jp112sdl/HB-Dis-EP-75BW)

Mit dem Script Helper kann man aus HomeMatic Skripten heraus Texte an das Display senden.<br>
<br>
- Installation:
```
Download via SSH auf die CCU in den Ordner /usr/local/addons mit dem Befehl:
wget -O /usr/local/addons/epaper75.tcl https://raw.githubusercontent.com/venice1200/SmartHome/master/HB-Dis-EP-75BW/epaper75.tcl  
```
**Info**<br>
Es gibt (noch) keinerlei Bereichsprüfungen innerhalb des TCL Skripts.<br>
Deshalb kann es durchaus passieren das was schief geht :-) falls falsche Werte übergeben werden.<br>
<br>
Auszug aus dem Script:<br>
```
# =================================================
# epaper75.tcl, HB-Dis-EP-75BW script helper 
# Version 0.15
# 2019-09-11 lame (Creative Commons)
# https://creativecommons.org/licenses/by-nc-sa/4.0/
# You are free to Share & Adapt under the following terms:
# Give Credit, NonCommercial, ShareAlike
#
# Based on epaper42.tcl by Tom Major 2019/05  (Creative Commons)
# See https://github.com/TomMajor/SmartHome/tree/master/HB-Dis-EP-42BW/Script_Helper
#
# Many many Thanks to Jérôme, Tom Major, pa-pa & the Community
#
# It'y my first TCL script (modification), please help me to make it better and easier
# Tested with Raspberrymatic 3.47.x
#
# The script needs to be downloaded to /usr/local/addons on the CCU as the below CMD_EXEC command starts from there
# wget -O /usr/local/addons/epaper75.tcl https://raw.githubusercontent.com/venice1200/SmartHome/master/HB-Dis-EP-75BW/epaper75.tcl
#
# Debugging Options are on the Top of the Script
# If you like to enable submitting to the display choose "gSubmit 1"
# If you like to disable submitting to the display choose "gSubmit 0"
#
# If you like to disbale debugging choose "gDebug" 0
# If you like to enable debugging to file "gDebugFile" choose "gDebug" 1
#
#
# Put the Display Content in an Variable, here "displayCMD", and run the helper script with CUxD Exec to send the data to the Display
# dom.GetObject("CUxD.CUX2801001:1.CMD_EXEC").State("tclsh /usr/local/addons/epaper75.tcl " # displayCmd);
#
# You can test it directly from the command line running
# tclsh epaper75.tcl <serial> /<cell> <icon> <text1> <text2> <flags> /<next cell> <next icon> <next text1> <next text2> <next flags>/<next...
# See below for examples
#
# serial: Display Device Serial, here "JPDISEP750"
# cell  : 1..18 (Column 1: 1..6, Column 2: 7..12, Column 3: 13..18)
#
#              /--------------------\
#              |   1  |   7  |  13  |
#              |   2  |   8  |  14  |
#              |   3  |   9  |  15  |
#              |   4  |  10  |  16  |
#              |   5  |  11  |  17  |
#              |   6  |  12  |  18  |
#              \--------------------/
#
# icon  : 1..30 as defined within Sketch
#         !! Needs to be set at least with the 0 value
#         !! If you set the Icon to 0 an existing icon we be cleared
#
# text1 : Line 1 possible mix with fixtext
#         !! Needs to be set at least with ' ' (one space) or @c00 (empty line)
#         !! Text with spaces needs to be between '' like 'text space'
#
# text2 : Line 2 possible mix with fixtext
#         !! Needs to be set at least with ' ' (one space) or @c00 (empty line)
#         !! Text with spaces needs to be between '' like 'space text'
#
# Specials:
# -Fixtexts @t[NUM]:
#  Add @t01..@t32 within the text for adding fixtexts 1..32 defined at device settings
#
# -Commands @c[NUM]:
#  Use @c00 as Text and existing Text Line will be cleared (see last example)
#  Use @c01 as Text and a Slash (0x2f) will be added
#
# Flags: 
# Decimal value containing bits for bold & centererd text and right aligned icon
# !! Flags needs to be set at least with the 0 value
#
# The Bits are standing for:
# Bit 0 Value 1:   If set to 1 Text Line 1 = bold, if set to 0 text is normal
# Bit 1 Value 2:   If set to 1 Text Line 2 = bold, if set to 0 text is normal
# Bit 2 Value 4:   If set to 1 Text Line 1 = centered, if set to 0 aligned like the icon
# Bit 3 Value 8:   If set to 1 Text Line 2 = centered, if set to 0 aligned like the icon
# Bit 4 Value 16:  If set to 1 Icon & Text right aligned, if set to 0 left aligned
#
# Bit 5 Value 32:  Free to use
# Bit 6 Value 64:  Free to use
# Bit 7 Value 128: Free to use
#
# Examples
# -Simple Text
# string displayCmd = "JPDISEP750 /10 15 Text1 Text2 0"
# Cell 10 with Icon No.15
# Text Line 1 = Text1
# Text Line 2 = Text2
# Flags = 0, Icon and both Texts left sided, nothing bold
# 
# -Mix of fixtext and simple text, centered and bold text
# string displayCmd = "JPDISEP750 /8 30 @t31 'Text Feld 8' 30"
# Cell 8 with Icon No.30
# Text Line 1 = @t31 (FixText No. 31) 
# Text Line 2 = 'Text Feld 8' (Text with spaces so use '')
# Flags = 30 = 16+8+4+2 = Icon on the right, both lines centered, second line bold
#
# -Show Time
# string displayCmd = "JPDISEP750 /7 23 'Update Zeit' " # "'" # system.Date("%H:%M") # "'" # " 14";
# Cell 7 with Icon No.23 (0x9c)
# Text Line 1 = 'Update Zeit'
# Text Line 2 = "'" # system.Date("%H:%M") # "'"
# Flags = 14 = 8+4+2 = both lines centered, second line bold
#
# -Clearing
# string displayCmd = "JPDISEP750 /7 0 @c00 @c00 0"
# Cell 7, clear Icon (0) and both text lines (@c00)
#
# -Show "/" (Slash)
# string displayCmd = "JPDISEP750 /10 15 Temp@c01Humi 12.3°C@c0145% 0"
# Cell 10 with Icon No.15
# Text Line 1 = Temp/Humi
# Text Line 2 = 12.3°C/45%
# Flags = 0, Icon and both Texts left sided, nothing bold
#
# =================================================
```
