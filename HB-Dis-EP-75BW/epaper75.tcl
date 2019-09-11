#!/bin/tclsh
#
# =================================================
# epaper75.tcl 
# based on epaper42.tcl by Tom Major 2019/05  (Creative Commons)
#
# HB-Dis-EP-75BW script helper 
# Version 0.1
# 2019-09-11 lame (Creative Commons)
# https://creativecommons.org/licenses/by-nc-sa/4.0/
# You are free to Share & Adapt under the following terms:
# Give Credit, NonCommercial, ShareAlike

# Many many Thanks to Jérôme, Tom Major & PaPa
#
# It'y my first TCL script (modification), please help to make it better and easier
# Tested with Raspberrymatic 3.47.15.20190831
# The script need to be downloaded to /usr/local/addons on the CCU
#
# Usage from comand line:
# tclsh epaper75.tcl <serial> /<cell> <icon> <text1> <text2> <flags> /<next cell> <next icon> <next text1> <next text2> <next flags>/<next...
# serial: Display Device Serial
# cell  : 1..18 (Column 1: 1..6, Column 2: 7..12, Column 3: 13..18)
# icon  : 1..30 as defined 
#         !! Needs to be set at least with the 0 value  
# text1 : Line 1 possible mix with fixtext
#         !! Needs to be set at least with ' ' (one space)
#         !! Text with spaces needs to be between '' like 'space text'
# text2 : Line 2 possible mix with fixtext
#         !! Needs to be set at least with ' ' (one space)
#         !! Text with spaces needs to be between '' like 'space text'
# Fixtexts
# add @t01..@t32 for the fixtexts 1..32 defined with the device settings
#
# Flags: Decimal value containing bits for bold & centererd text and right sided icon
#         !! Needs to be set at least with the 0 value
# Decimal Value which stands for
# Bit 4 3 2 1 0
#     | | | | \-> if set Text Line 1 = bold
#     | | | \---> if set Text Line 2 = bold 
#     | | \-----> if set Text Line 1 = centered
#     | \-------> if set Text Line 2 = centered
#     \---------> if set Icon & Text right aligned
#
# Examples
# Simple Text
# string displayCmd = "JPDISEP750 /10 15 Text1 Text2 0"
# Cell 10 = Column 2, Row 4 with Icon 15
# Text Line 1 = Text1
# Text Line 2 = Text2
# Flags = 0, Icon and both Texts left sided, nothing bold
# 
# Mix of fixtext and simple text, centered and bold text
# string displayCmd = "JPDISEP750 /8 30 @t31 'Text Feld 8' 30"
# Cell 8 = Column 2, Row 2 with Icon No. 30
# Text Line 1 = @t31 (FixText No. 31) 
# Text Line 2 = 'Text Feld 8' (Text with spaces so use '')
# Flags = 30, Icon on the right, both lines centered, second line bold
#
# Run with the CUxD script command
# dom.GetObject("CUxD.CUX2801001:1.CMD_EXEC").State("tclsh /usr/local/addons/epaper75.tcl " # displayCmd);
#
#
# =================================================

load tclrega.so

# -------------------------------------
proc main { argc argv } {
    
    if { $argc < 3 } {
        return
    }
    
	#set txtOut ""
	
    for { set i 0 }  { $i <= 18 }  { incr i } {
        set DISPLAY($i) ""
    }
    
	debugLog "-<Start>----------------------------------------------------------------"
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
            debugLog "C:$CELL I:$ICON T1:$TEXT1 T2:$TEXT2 F:$FLAGS"

			set txtOut ""
			
			# Reset Flags
			set T1B 0
			set T2B 0
			set T1C 0
			set T2C 0
			set ICR 0
			
			# Define Flags
			if { ($FLAGS & 1) == 1 } {
		      set T1B 1
		    }
			if { ($FLAGS & 2) == 2 } {
			  set T2B 1
			}
			if { ($FLAGS & 4) == 4 } {
			  set T1C 1
			}
			if { ($FLAGS & 8) == 8 } {
			  set T2C 1
			}
			if { ($FLAGS & 16) == 16 } {
			  set ICR 1
			}
            debugLog "T1B:$T1B T2B:$T2B T1C:$T1C T2C:$T2C ICR:$ICR"
			
			#Calculate Icon Position
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
                if { $ICON >= 1 && $ICON <= 50 } {
                    append txtOut "0x18,"
					append txtOut "0x$iconHex,"
                    set iconDec [expr 127 + $ICON]
                    set iconHex [format %x $iconDec]
                    append txtOut "0x$iconHex,"
                }
				
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
                    if { ($numDec == 64) && ($nextchar == "t") } {
						debugLog "Found FixText @t"
                        set numberStr [string range $TEXT1 [expr $n + 2] [expr $n + 3]]
						debugLog "Found FixText numberStr: $numberStr"
                        if { [string length $numberStr] == 2 } {
                            #this scan here is required to extract numbers like 08 or 09 correctly, otherwise the number is treated as octal which will result in errors
                            scan $numberStr "%d" number
							debugLog "Found FixText Number: $number"
                            if { ($nextchar == "t") && ($number >= 1) && ($number <= 32) } {
                                #@t01..@t32
                                set textDec [expr 127 + $number]
                                set textHex [format %x $textDec]
                                append txtOut "0x$textHex,"
                                incr n 3
                                continue
                            } 
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
                    if { ($numDec == 64) && ($nextchar == "t") } {
						debugLog "Found FixText @t"
                        set numberStr [string range $TEXT2 [expr $n + 2] [expr $n + 3]]
						debugLog "Found FixText numberStr: $numberStr"
                        if { [string length $numberStr] == 2 } {
                            #this scan here is required to extract numbers like 08 or 09 correctly, otherwise the number is treated as octal which will result in errors
                            scan $numberStr "%d" number
							debugLog "Found FixText Number: $number"
                            if { ($nextchar == "t") && ($number >= 1) && ($number <= 32) } {
                                #@t01..@t32
                                set textDec [expr 127 + $number]
                                set textHex [format %x $textDec]
                                append txtOut "0x$textHex,"
                                incr n 3
                                continue
                            } 
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
    debugLog "------------------------------------------------------------------------"
	
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
	
    #Debug Display Command
	debugLog $displayCmd
	debugLog "-<End>------------------------------------------------------------------"
	
	#Process Rega Command
	set rega_cmd ""
    append rega_cmd "dom.GetObject('BidCos-RF.$SERIAL:9.SUBMIT').State('$displayCmd');"
    array set regaRet [rega_script $rega_cmd]

}

# -------------------------------------
proc encodeSpecialChar { numHex } {
	switch $numHex {
    
        20      { return "20" }     # space
        21      { return "21" }     # !
        25      { return "25" }     # %
        27      { return "27" }     # =
        28      { return "28" }     # (
        29      { return "29" }     # )
        2a      { return "2A" }     # *
        2b      { return "2B" }     # +
        2c      { return "2C" }     # ,
        2d      { return "2D" }     # -
        2e      { return "2E" }     # .
        b0      { return "B0" }     # °
        5f      { return "5F" }     # _

        c4      { return "5B" }     # Ä
        d6      { return "23" }     # Ö
        dc      { return "24" }     # Ü
        e4      { return "7B" }     # ä
        f6      { return "7C" }     # ö
        fc      { return "7D" }     # ü
        df      { return "7E" }     # ß

    	default {
            #debugLog "Unknown: $numHex"
            return "2E" 
        }
	}
}

# -------------------------------------
proc debugLog { text } {
    set fileId [open "/media/usb1/debug75.log" "a+"]
    puts $fileId $text
	close $fileId
}

main $argc $argv
