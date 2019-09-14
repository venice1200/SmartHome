#!/bin/tclsh
#
# =================================================
# epaper75.tcl, HB-Dis-EP-75BW script helper 
# Version 0.13
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
# Tested with Raspberrymatic 3.47.15.20190831
#
# The script need to be downloaded to /usr/local/addons on the CCU as the below CMD_EXEC command starts from there
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
#         !! Needs to be set at least with ' ' (one space)
#         !! Text with spaces needs to be between '' like 'text space'
#
# text2 : Line 2 possible mix with fixtext
#         !! Needs to be set at least with ' ' (one space)
#         !! Text with spaces needs to be between '' like 'space text'
#
# Specials:
# -Fixtexts @t:
# Add @t01..@t32 within the text for adding fixtexts 1..32 defined at device settings
#
# -Commands @c:
# Use @c00 as Text and existing Text Line will be cleared (see last example)
#
# Flags: Decimal value containing bits for bold & centererd text and right aligned icon
#         !! Flags needs to be set at least with the 0 value
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
# -Clear
# string displayCmd = "JPDISEP750 /7 0 @c254 @c254 0"
# Cell 7, clear Icon (0) and both text lines (@c00)
#
# =================================================

load tclrega.so

# Globals, just for debugging

# Submit to Display: 0 = no / 1 = yes
# set gSubmit 0
set gSubmit 1

# Debugging: 0 = no / 1 = yes to gDebugFile
set gDebug 0
# set gDebug 1
set gDebugFile "/media/usb1/debug75.log"


# -------------------------------------
proc main { argc argv } {

	if { $argc < 3 } {
		return
	}

	debugLog "-<Start>----------------------------------------------------------------"

	# Get Global
	global gSubmit
	debugLog "Submitting to Display: $gSubmit"

	for { set i 0 }  { $i <= 18 }  { incr i } {
		set DISPLAY($i) ""
	}

	set SERIAL [lindex $argv 0]
	debugLog "Serial: <$SERIAL>"

	set i 0
	foreach subCmd [split $argv "/"] {
		if { $i > 0 && $i <= 18 } {
			debugLog "------------------------------------------------------------------------"
			set CELL [lindex $subCmd 0]
			set ICON [lindex $subCmd 1]
			set TEXT1 [lindex $subCmd 2]
			set TEXT2 [lindex $subCmd 3]
			set FLAGS [lindex $subCmd 4]
			debugLog "Cell:$CELL  Icon:$ICON  Text1:$TEXT1  Text2:$TEXT2  Flags:$FLAGS"

			set txtOut ""

			#Calculate Flags
			set T1B [expr ($FLAGS >> 0) & 1]
			set T2B [expr ($FLAGS >> 1) & 1]
			set T1C [expr ($FLAGS >> 2) & 1]
			set T2C [expr ($FLAGS >> 3) & 1]
			set ICR [expr ($FLAGS >> 4) & 1]
			set  B5 [expr ($FLAGS >> 5) & 1]
			set  B6 [expr ($FLAGS >> 6) & 1]
			set  B7 [expr ($FLAGS >> 7) & 1]
			debugLog "Flags T1B:$T1B T2B:$T2B T1C:$T1C T2C:$T2C ICR:$ICR B5:$B5 B6:$B6 B7:$B7"

			#Calculate Icon Position + possible Offset for right alignment
			set iconDec [expr 128 + ($CELL -1) + ($ICR * 64)]
			#...to Hex
			set iconHex [format %x $iconDec]
			#Debug iconPosition
			debugLog "Icon Position  Dec: $iconDec / Hex: $iconHex"
			
			#Calculate Text 1 Position + possible Offset for Text Center Mode
			set text1Dec [expr 128 + (($CELL -1) *2) + ($T1C * 64)]
			#...to Hex
			set text1Hex [format %x $text1Dec]
			#Debug iconPosition
			debugLog "Text1 Position Dec: $text1Dec / Hex: $text1Hex"

			#Calculate Text 2 Position + possible Offset for Text Center Mode
			set text2Dec [expr 128 + (($CELL -1) *2 +1) + ($T2C * 64)]
			#...to Hex
			set text2Hex [format %x $text2Dec]
			#Debug iconPosition
			debugLog "Text2 Position Dec: $text2Dec / Hex: $text2Hex"

			#Process each display line
			if { $CELL >= 1 && $CELL <= 18 && [string length $TEXT1] > 0 } {
				#Reset CELL string
				set txtOut ""
				#Process Icon
				append txtOut "0x18,"
				append txtOut "0x$iconHex,"
				if { $ICON == 0 } {
					# Icon No. 0 => Dec 254 => 0xFE => MSG_CLR_KEY
					set iconDec 254
					debugLog "Found Icon No.0 => add 0xFE => MSG_CLR_KEY/Clear Icon"
				}
				if { $ICON >= 1 } {
					# Icon No. > 0 = Regular Icons
					set iconDec [expr 127 + $ICON]
					debugLog "Found Icon No. $ICON => $iconDec => 0x$iconHex"
				} 
				set iconHex [format %x $iconDec]
				append txtOut "0x$iconHex,"

				# Text 1
				# fixed or variable text, can be combined in one line
				# Bold or Normal
				if { $T1B == 0 } {
					append txtOut "0x11,"
				} else {
					append txtOut "0x12,"
				}
      			append txtOut "0x$text1Hex,"
				for { set n 0 } { $n < [string length $TEXT1] } { incr n } {
				  set char [string index $TEXT1 $n]
				  set nextchar [string index $TEXT1 [expr $n + 1]]
				  scan $char "%c" numDec
				  set numHex [format %x $numDec]
				  #check for fixed text code @txx, 2 digits required!
				  #pass thru all other @yxx codes!
					#@ = AscII 64
					if { ($numDec == 64) && (($nextchar == "t") || ($nextchar == "c")) } {
					  debugLog "T1: Found @ (Special)"
					  set numberStr [string range $TEXT1 [expr $n + 2] [expr $n + 3]]
						debugLog "T1: Found Special numberStr: $numberStr"
						if { [string length $numberStr] == 2 } {
							#this scan here is required to extract numbers like 08 or 09 correctly, otherwise the number is treated as octal which will result in errors
							scan $numberStr "%d" number
							debugLog "T1: Found @ Number: $number"
							switch $nextchar {
								"t" {
									if { ($number >= 1) && ($number <= 32) } {
										#@t01..@t32
										set textDec [expr 127 + $number]
										set textHex [format %x $textDec]
										append txtOut "0x$textHex,"
										debugLog "T1: Found FixText Number: $number => $textDec => 0x$textHex"
									}
								}
								"c" {
									if {$number == 0} {
										#@c00 => 0xFE => MSG_CLR_KEY
										append txtOut "0xfe,"
										debugLog "T1: Found @c00, add 0xFE => MSG_CLR_KEY/Clear Text"
									}
								}
							}
							incr n 3
							continue
						}
					}
					#variable text, hex 30..5A, 61..7A
					if { ($numDec >= 48 && $numDec <= 90) ||
					($numDec >= 97 && $numDec <= 122) } {
						append txtOut "0x$numHex,"
					} else {
						append txtOut "0x[encodeSpecialChar $numHex],"
					}
				}
				
				# Text 2
				# fixed or variable text, can be combined in one line
				# Bold or Normal
				if { $T2B == 0 } {
					append txtOut "0x11,"
				} else {
					append txtOut "0x12,"
				}
				append txtOut "0x$text2Hex,"
				for { set n 0 } { $n < [string length $TEXT2] } { incr n } {
					set char [string index $TEXT2 $n]
					set nextchar [string index $TEXT2 [expr $n + 1]]
					scan $char "%c" numDec
					set numHex [format %x $numDec]
					#check for fixed text code @txx, 2 digits required!
					#pass thru all other @yxx codes!
					#@ = AscII 64
					if { ($numDec == 64) && (($nextchar == "t") || ($nextchar == "c")) } {
						debugLog "T2: Found @ (Special)"
						set numberStr [string range $TEXT2 [expr $n + 2] [expr $n + 3]]
						debugLog "T2: Found Special numberStr: $numberStr"
						if { [string length $numberStr] == 2 } {
							#this scan here is required to extract numbers like 08 or 09 correctly, otherwise the number is treated as octal which will result in errors
							scan $numberStr "%d" number
							debugLog "T2: Found @ Number: $number"
							switch $nextchar {
								"t" {
									if { ($number >= 1) && ($number <= 32) } {
										#@t01..@t32
										set textDec [expr 127 + $number]
										set textHex [format %x $textDec]
										append txtOut "0x$textHex,"
										debugLog "T2: Found FixText Number: $number => $textDec => 0x$textHex"
									}
								}
								"c" {
									if {$number == 0} {
										#@c00 => 0xFE => MSG_CLR_KEY
										append txtOut "0xfe,"
										debugLog "T2: Found @c00, add 0xFE => MSG_CLR_KEY/Clear Text"
									}
								}
							}
							incr n 3
							continue
						}
					}
					#variable text, hex 30..5A, 61..7A
					if { ($numDec >= 48 && $numDec <= 90) ||
						($numDec >= 97 && $numDec <= 122) } {
						append txtOut "0x$numHex,"
					} else {
						append txtOut "0x[encodeSpecialChar $numHex],"
					}
				}
				#Store CELL String
				set DISPLAY($CELL) $txtOut
			}
		}
		incr i
	}
	#Build complete Display Command
	#Add Command Start
	set displayCmd "0x02,"
	for { set i 1 } { $i <= 18 } { incr i } {
		if { [string length $DISPLAY($i)] > 0 } {
			append displayCmd $DISPLAY($i)
		}
	}
	#Add Command End
	append displayCmd "0x03"

	debugLog "-<Hex Code>-------------------------------------------------------------"
	#Debug Display Command
	debugLog $displayCmd
	debugLog "-<End>------------------------------------------------------------------"

	#Process Rega Command
	if ($gSubmit) {
		set rega_cmd ""
		append rega_cmd "dom.GetObject('BidCos-RF.$SERIAL:9.SUBMIT').State('$displayCmd');"
		array set regaRet [rega_script $rega_cmd]
	}

}

# -------------------------------------
proc encodeSpecialChar { numHex } {
	switch $numHex {

	20	{ return "20" }		# space
	21	{ return "21" }		# !
	25	{ return "25" }		# %
	27	{ return "27" }		# =
	28	{ return "28" }		# (
	29	{ return "29" }		# )
	2a	{ return "2a" }		# *
	2b	{ return "2b" }		# +
	2c	{ return "2b" }		# ,
	2d	{ return "2d" }		# -
	2e	{ return "2e" }		# .
	b0	{ return "b0" }		# °
	5f	{ return "5f" }		# _
	c4	{ return "5b" }		# Ä
	d6	{ return "23" }		# Ö
	dc	{ return "24" }		# Ü
	e4	{ return "7b" }		# ä
	f6	{ return "7c" }		# ö
	fc	{ return "7d" }		# ü
	df	{ return "7e" }		# ß

		default {
			#debugLog "Unknown: $numHex"
			return "2E" 
		}
	}
}

# -------------------------------------
proc debugLog { text } {
	# Get Globals
	global gDebug
	global gDebugFile
	if ($gDebug) {
		set	fileId [open $gDebugFile "a+"]
		puts $fileId $text
		close $fileId
	}
}

main $argc $argv
