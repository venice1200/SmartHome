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
epaper75.tcl 

based on epaper42.tcl by Tom Major 2019/05  (Creative Commons)
HB-Dis-EP-75BW script helper 
Version 0.1
2019-09-11 lame (Creative Commons)
https://creativecommons.org/licenses/by-nc-sa/4.0/
You are free to Share & Adapt under the following terms:
Give Credit, NonCommercial, ShareAlike

Many many Thanks to Jérôme, Tom Major & PaPa

It'y my first TCL script, please help to me make it better and easier
Tested with Raspberrymatic 3.47.15.20190831

The script need to be downloaded to /usr/local/addons on the CCU

Usage from comand line:
tclsh epaper75.tcl <serial> /<cell> <icon> <text1> <text2> <flags> /<next cell> <next icon> <next text1> <next text2> <next flags>/<next...
serial: Display Device Serial
cell  : 1..18 (Column 1: 1..6, Column 2: 7..12, Column 3: 13..18)
icon  : 1..30 as defined 
        !! Needs to be set at least with the 0 value  
text1 : Line 1 possible mix with fixtext
        !! Needs to be set at least with ' ' (one space)
        !! Text with spaces needs to be between '' like 'space text'
text2 : Line 2 possible mix with fixtext
        !! Needs to be set at least with ' ' (one space)
        !! Text with spaces needs to be between '' like 'space text'
Fixtexts
Add @t01..@t32 for the fixtexts 1..32 defined with the device settings

Flags: Decimal value containing bits for bold & centererd text and right sided icon
        !! Needs to be set at least with the 0 value
Decimal Value which stands for
Bit 4 3 2 1 0
    | | | | \-> if set Text Line 1 = bold
    | | | \---> if set Text Line 2 = bold 
    | | \-----> if set Text Line 1 = centered
    | \-------> if set Text Line 2 = centered
    \---------> if set Icon & Text right aligned

Examples
Simple Text
string displayCmd = "JPDISEP750 /10 15 Text1 Text2 0"
Cell 10 = Column 2, Row 4 with Icon 15
Text Line 1 = Text1
Text Line 2 = Text2
Flags = 0, Icon and both Texts left sided, nothing bold
 
Mix of fixtext and simple text, centered and bold text
string displayCmd = "JPDISEP750 /8 30 @t31 'Text Feld 8' 30"
Cell 8 = Column 2, Row 2 with Icon No. 30
Text Line 1 = @t31 (FixText No. 31) 
Text Line 2 = 'Text Feld 8' (Text with spaces so use '')
Flags = 30, Icon on the right, both lines centered, second line bold

Run with the CUxD script command
dom.GetObject("CUxD.CUX2801001:1.CMD_EXEC").State("tclsh /usr/local/addons/epaper75.tcl " # displayCmd);
```
