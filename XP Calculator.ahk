#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
;MsgBox %A_AhkVersion%

#SingleInstance, force


;--------------------------------------------------------------------------------------------------
; history
;--------------------------------------------------------------------------------------------------
/*
July 19/25
->updated all locations of the text box/images
->updated background image to Mel's Lvl 1 card
->increased Width and decreased height of the Gui
->Finished aligning all adventures 
->Added Arcane Warwick & Asol
->Added Yasuo adventure
->Added Champion Adventure Icon to be aligned underneath the XP text boxes
->Added golden borders to all images
->Made Star icons have a black background instead of white
->Removed Legend Legend XP calculator as riot new events usually add a ton of LLXP as a reward
->Added input character protection
->if entering an XP amount greater than the target lvl, the target lvl will increase to be above the XP

Bugs:
->If entering too many invalid characters at the same time then will be able to be entered into the textbox
->For some reason the shift + number keys will just enter the number instead of special character (don't understand why this happens)

TODO: 
->Add better champ adventure icons
->I don't plan on adding 1.5* warwick to the list

Nov 8/24
->Updated Legend XP amounts for levels past 57
Oct 14/24 - Updated for patch 5.10 "Runeterror" Patch
->Updated Background image to related to current patch
->Updated location of boxes to show the background image better
->Updated max champ levels to 50
->Updated max legend level to 80
->Updated Legend XP per week to take into account the weekly nightmares and weekly quest
->WIP: Showing which boxes correlate to which adventure as there a few variations on XP amounts
->TBD: 
*/
;--------------------------------------------------------------------------------------------------
; Lookup Table Stuff
;--------------------------------------------------------------------------------------------------

;****************************************************************************************************************************************
;This LUT is used for quickly searching the XP amount per adventures in the UpdateRuns function in Macro & Functions
;				  <.5   1   1.5   2    2.5    3    3.5   GAL  Liss  Yasuo  Asol  Arcane WW   N5    N6   Arcane Asol  
StarXP       := [ 100, 305, 605, 985, 1425, 1925, 3015, 3100, 4360,  4470, 4505,    4840,   5230, 6030,   10670]

;LUT for the SubmitCurrentLegendXPString in Label Functions for Legends XP section 
;Amount of XP for each legend to level up to the next level from 1 to 80                                                                                                                         31     32    33         35                            40                            45                            50                            55          57               60           62                65                68            70                   73     74     75                    80
LegendXP     := [1000,2000,2500,3500,4000,4500,5000,5500,6000,7000,8000,9000,10000,11000,12000,13000,15000,17000,19000,21000,23000,25000,27000,29000,31000,33000,35000,37000,39000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000,45000,45000,45000,45000,45000,45000,60000,60000,60000,60000,60000,80000,80000,80000,80000,80000,80000,100000,100000,100000,100000,100000,100000,120000,120000,120000,120000,120000,120000,120000]

;Total Xp needed for each LL,  LUT for the SubmitCurrentLegendXPString function in Label Functions for Legends XP section
;				 1   2    3    4    5    6     7	  8    9	  10   11	 12	   13	 14	   15	16	    17	  18	  19	 20	   21	  22	 23	   24		25	  26     27     28      29    30     31      32    33     34     35     36     37    38      39     40     41     42      43     44     45    46      47    48      49     50      51 		52	   53       54     55       56      57      58      59      60     61       62      63      64      65      66      67     68       69      70      71      72      73      74      75     76      77       78      79      80                                                                                                                                      
LegendXPList := [0,1000,3000,5500,9000,13000,17500,22500,28000,34000,41000,49000,58000,68000,79000,91000,104000,119000,136000,155000,176000,199000,224000,251000,280000,311000,344000,379000,416000,455000,485000,515000,545000,575000,605000,635000,665000,695000,725000,755000,785000,815000,845000,875000,905000,935000,965000,995000,1025000,1055000,1115500,1160500,1205500,1250500,1295500,1340500,1400500,1460500,1520500,1580500,1640500,1720500,1800500,1880500,1960500,2040500,2120500,2220500,2320500,2420500,2520500,2620500,2720500,2840500,2960500,3080500,3200500,3320500,3440500,3560500]

;Total XP needed for champ level it takes from 1 to 50
;				 1  2  3   4   5   6   7     8   9    10	11	12	  13   14   15	16	  17    18	  19	20	  21	22	  23	24	  25	26	  27	28	  29	30	 31		32	  33	34	  35    36	   37	   38	  39	40	   41	 42      43     44    45       46	 47    48      49	  50
ChampXPList  := [0,50,150,300,500,800,1250,1750,2310,2980,3780,4710,5780,6990,8350,9870,11560,13420,15460,17680,20090,22700,25510,28530,31760,35210,38880,42780,46920,51290,57140,64070,72210,81890,93130,105990,120610,136660,155430,176530,200040,226190,255380,287910,323330,361400,402630,448180,497870,552670]
;****************************************************************************************************************************************

; LUT for XP per battle won on an adventure
halfstarXP       := [ 20, 40,  60, 100]
onestarXP        := [ 10, 20, 110, 160, 205, 245  305]
oneandstarXP     := [ 15, 30, 215, 320, 410, 485, 605]
twostarXP        := [ 25, 50, 350, 520, 665, 790, 985]
twoandstarXP     := [ 35, 70, 565, 780, 960,1140,1425]
threestarXP		 := [ 50,100, 770,1060,1300,1540,1925]
threehalfstarXP	 := [ 75,150,1230,1695,2045,2395,3015]
GalioXP          := [ 75,150, 615, 965,1315,1780,2130,2480,3100]
ASolXP           := [ 95,190, 285, 700,2015,2280,2545,2810,3225,3490,3755,4505]
LissXP           := [110,220,1785,2345,2905,3465,4360]
YasuoXP 		 := [110,220,1785,2455,3015,3575,4470]
WarwickXP 		 := [130,260,1045,1700,2355,3140,3795,4840]
LongLissXP       := [110,220,1785,2345,3910,4470,5030,5925]
fivestarXP       := [130,260,2090,2875,3530,4185,5230]
sixnightmareXP   := [150,300,2410,3315,4070,4825,6030]
ArcaneAsolXP	 := [170,340, 510,1545,3955,4815,5675,6710,7570,8430,9290,10670]

;****************************************************************************************************************************************

;used to do some calculations
frac_adv     := 0
ctr          := 0
;Used for the Text Boxes and drop down menus
CurrentChampXP		:=0
TargetChamplvl      :=30
CurrentLegendXP     := 0
CurrentLegendlvl    := 1
TargetLegendlvl     := 50

;Hardcoded Definitions

MAX_CHAMP_LEVEL := 50
MAX_CHAMP_XP := 552670

MAX_LEGEND_LEVEL :=80
MAX_LEGEND_XP := 2360000

WEEKLY_LEGEND_XP := 27000

;XY Coordinate offsets for Images
XPTEXTOFFSETY := 50
STAROFFSETY   := 35

BOTTOMSTARY := 480
BOTTOMRUNY  := 445

BOTTOMADVY1 := 65
BOTTOMADVY2 := 140
BOTTOMADVY3 := 215
BOTTOMADVY4 := 290

;--------------------------------------------------------------------------------------------------
; GUI Stuff
;--------------------------------------------------------------------------------------------------
SetFormat, float, 6.1

;setup braum as as tray icon
Menu, Tray,  Icon, images\braum.ico

;GUI setup
Gui, -dpiscale ;needed to disable window DPI scaling
Gui, Add, Picture, x0 y-75, images\mel-1600x900.png ;y-75 to offset the black part of the card art
Gui, Font, Times New Roman, s30, cwhite

;Text Boxes - Adventures to Win
;Normal Adventures
Gui, add , Edit, vhalfstar         x0   y0  w75 ReadOnly
Gui, add , Edit, vonestar          x80  y0 w75 ReadOnly
Gui, add , Edit, voneandhalfstar   x160 y0  w65 ReadOnly
Gui, add , Edit, vtwostar          x230 y0  w65 ReadOnly
Gui, add , Edit, vtwoandhalfstar   x300 y0  w65 ReadOnly
Gui, add , Edit, vthreestar        x370 y0  w70 ReadOnly
Gui, add , Edit, vthreeandhalfstar x455 y0 w70 ReadOnly
;Special Adventures
Gui, add , Edit, vgaliostar        x545   y0 w75 ReadOnly
Gui, add , Edit, vlissStar         x665   y0  w70 ReadOnly
Gui, add , Edit, vyasuoStar        x795   y0  w70 ReadOnly
Gui, add , Edit, vasolstar         x910   y0  w75 ReadOnly
Gui, add , Edit, vwarwickstar      x1030  y0  w75 ReadOnly
Gui, add , Edit, vfivestar         x1170  y0  w70 ReadOnly
Gui, add , Edit, vsixstar          x1315  y0  w70 ReadOnly
Gui, add , Edit, vaasolstar        x1480  y0  w70 ReadOnly

;Images - Star picture locations**********************************************************
Gui, add, picture, x30 y%STAROFFSETY%   w13 h25 , images\halfstar.png
;1 star
Gui, add, picture, x105 y%STAROFFSETY%  w25 h25, images\wholestar.png
;1.5 star
Gui, add, picture, x170 y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x195 y%STAROFFSETY%  w13 h25, images\halfstar.png
; 2 star
Gui, add, picture, x235 y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x260 y%STAROFFSETY%  w25 h25, images\wholestar.png
; 2.5 star
Gui, add, picture, x300 y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x325 y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x350 y%STAROFFSETY%  w13 h25, images\halfstar.png
; 3 star
Gui, add, picture, x370 y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x395 y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x420 y%STAROFFSETY%  w25 h25, images\wholestar.png
;Fiddle/Heist
Gui, add, picture, x450 y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x475 y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x500 y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x525 y%STAROFFSETY%  w13 h25, images\halfstar.png
;Galio
Gui, add, picture, x545 y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x570 y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x595 y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x620 y%STAROFFSETY%  w13 h25, images\halfstar.png
;Liss
Gui, add, picture, x640 y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x665 y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x690 y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x715 y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x740 y%STAROFFSETY%  w25 h25, images\wholestar.png
;Yasuo
Gui, add, picture, x775  y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x800  y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x825  y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x850  y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x875  y%STAROFFSETY%  w13 h25, images\halfstar.png
;ASol
Gui, add, picture, x895  y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x920  y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x945  y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x970  y%STAROFFSETY%  w25 h25, images\wholestar.png
;Arcane Warwick
Gui, add, picture, x1010  y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x1035  y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x1060  y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x1085  y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x1110  y%STAROFFSETY%  w13 h25, images\halfstar.png

;Swain/Fizz
Gui, add, picture, x1140  y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x1165  y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x1190  y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x1215  y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x1240  y%STAROFFSETY%  w25 h25, images\wholestar.png

;Viego/Fiddle
Gui, add, picture, x1275  y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x1300  y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x1325  y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x1350  y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x1375  y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x1400  y%STAROFFSETY%  w25 h25, images\wholestar.png

;Arcane Asol
Gui, add, picture, x1435  y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x1460  y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x1485  y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x1510  y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x1535  y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x1560  y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x1585  y%STAROFFSETY%  w13 h25, images\halfstar.png

;********************************************************************************

;Images - Adventure Icons Cordinates
;0 or .5
Gui, add, picture, x0 y%BOTTOMADVY1%  w75 h75, images\adv-teemo.png
Gui, add, picture, x0 y%BOTTOMADVY2%  w75 h75, images\adv-mf.png
;1
Gui, add, picture, x75 y%BOTTOMADVY1% w75 h75, images\adv-garen.png
Gui, add, picture, x75 y%BOTTOMADVY2% w75 h75, images\adv-lulu.png
;Gui, add, picture, x75 y%BOTTOMADVY3% w75 h75, images\adv-ww.png
;1.5
Gui, add, picture, x150 y%BOTTOMADVY1%  w75 h75, images\adv-gp.png
Gui, add, picture, x150 y%BOTTOMADVY2%  w75 h75, images\adv-ez.png
Gui, add, picture, x150 y%BOTTOMADVY3%  w75 h75, images\adv-illaoi.png
;2
Gui, add, picture, x225 y%BOTTOMADVY1%  w75 h75, images\adv-zed.png
Gui, add, picture, x225 y%BOTTOMADVY2%  w75 h75, images\adv-naut.png
Gui, add, picture, x225 y%BOTTOMADVY3%  w75 h75, images\adv-darius.png
;2.5
Gui, add, picture, x300 y%BOTTOMADVY1%  w75 h75, images\adv-viktor.png
Gui, add, picture, x300 y%BOTTOMADVY2%  w75 h75, images\adv-draven.png
Gui, add, picture, x300 y%BOTTOMADVY3%  w75 h75, images\adv-azir.png
;3
Gui, add, picture, x375 y%BOTTOMADVY1%  w75 h75, images\adv-elder.png
Gui, add, picture, x375 y%BOTTOMADVY2%  w75 h75, images\adv-kaisa.png
Gui, add, picture, x375 y%BOTTOMADVY3%  w75 h75, images\adv-thresh.png
;3.5
Gui, add, picture, x450 y%BOTTOMADVY1%  w75 h75, images\adv-fiddle.png
Gui, add, picture, x450 y%BOTTOMADVY2%  w75 h75, images\adv-heist.png
Gui, add, picture, x450 y%BOTTOMADVY3%  w75 h75, images\adv-garen.png
;galio
Gui, add, picture, x550 y%BOTTOMADVY1%  w75 h75, images\adv-galio.png
;lissandra
Gui, add, picture, x670 y%BOTTOMADVY1%  w75 h75, images\adv-liss.png
;yasuo
Gui, add, picture, x800 y%BOTTOMADVY1%  w75 h75, images\adv-yasuo.png
;asol
Gui, add, picture, x910 y%BOTTOMADVY1%  w75 h75, images\adv-asol.png
;arcane warwick 
Gui, add, picture, x1035 y%BOTTOMADVY1%  w75 h75, images\adv-aww.png
;Swain
Gui, add, picture, x1170 y%BOTTOMADVY1%  w75 h75, images\adv-swain.png
Gui, add, picture, x1170 y%BOTTOMADVY2%  w75 h75, images\adv-fizz.png
;Viego/Fiddle
Gui, add, picture, x1320 y%BOTTOMADVY1%  w75 h75, images\adv-viego.png
Gui, add, picture, x1320 y%BOTTOMADVY2%  w75 h75, images\adv-nfiddle.png
Gui, add, picture, x1320 y%BOTTOMADVY3%  w75 h75, images\adv-karma.png
;arcane asol
Gui, add, picture, x1480 y%BOTTOMADVY1%  w75 h75, images\adv-asol.png

;********************************************************************************

;CurrentChampXP
Gui, add , Edit, limit6 vCurrentChampXPString gSubmitCurrentChampXPString x0 y405 w70 
Gui, add , DropDownList, x80 y405 w65  vTargetChamplvl gSubmitTargetChamplvl, 1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30||31|32|33|34|35|36|37|38|39|40|41|42|43|44|45|46|47|48|49|50
;
Gui, add , Edit, x0 y365 ReadOnly vfriendlytext1, Enter your champion's XP in the box below 
Gui, add , Edit, x150 y405 ReadOnly vfriendlytext2, Select your target level from the drop down menu
Gui, add , Edit, x0 y310 w485 h50 ReadOnly vfriendlytext3 -vscroll, The numbers above show how many times you need to beat that adventure plus any additional battles to reach your target level

;Gui, add , DropDownList, x680 y405 w65  vGetLevelXp gSubmitGetLevelXp, 1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30||31|32|33|34|35|36|37|38|39|40|41|42|43|44|45|46|47|48|49|50

;********************************************************************************

; Legends XP part - currently removed because it's not that relevant
;Gui, add , Edit, limit5 vCurrentLegendXPString gSubmitCurrentLegendXPString xm+778 y350 w70 h28
;Gui, add , DropDownList, xm+850  y350 w65  vCurrentLegendlvl gSubmitCurrentLegendlvl , 1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33|35|36|37|38|39|40|41|42|43|44|45|46|47|48|49|50||51|52|53|54|55|56|57|58|59|60|61|62|63|64|65|66|67|68|69|70|71|71|72|73|74|75|76|77|78|79|80
;Gui, add , DropDownList, xm+850  y380 w65  vTargetLegendlvl  gSubmitTargetLegendlvl  , 1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33|35|36|37|38|39|40|41|42|43|44|45|46|47|48|49|50|51|52|53|54|55|56|57|58|59|60|61|62|63|64|65|66|67|68|69|70|71|71|72|73|74|75|76|77|78|79|80||
;Gui, add , Edit, vamountsofweeks xm+723 y380 w125 h28 ReadOnly, Weeks 
;Gui, add, Picture, x750 y325, images\legend_icon.png


;********************************************************************************

;Start the GUI
Gui, -alwaysontop
;Gui, Color, E1E1E1
Gui, Show, w1600 h450, Path of Champions XP Calculator Patch 6.7

;--------------------------------------------------------------------------------------------------
; Label Functions for Champ XP 
;--------------------------------------------------------------------------------------------------

SubmitCurrentChampXPString:
	
	Gui,+OwnDialogs
	Gui,Submit,NoHide	
	
	;try to clean input
	;Look for non digit characters, then fix it
	GuiControlGet, CurrentText,, CurrentChampXPString	
	CleanText := RegExReplace(CurrentChampXPString, "[^\d]", "")
    if (CleanText != CurrentText)
	{
		CurrentChampXPString := CleanText		
        GuiControl,, CurrentChampXPString, %CleanText%
		;MsgBox % CurrentChampXPString
		PosCor := GetCursorCorrection(CurrentChampXPString)
		;MsgBox % PosCor
		Send, {Right %PosCor%}		
		return
	}
	
	
	;if above the MAX_CHAMP_XP, then set to MAX_CHAMP_XP
	if(CurrentChampXPString>MAX_CHAMP_XP)
	{
		CurrentChampXPString := MAX_CHAMP_XP
		GuiControl,Text, CurrentChampXPString, %CurrentChampXPString%
	}
	
	;This will fail infinitely if its bigger than MAX_CHAMP_LVL
	if(CurrentChampXPString>ChampXPList[TargetChamplvl])
	{
	
		while(CurrentChampXPString>ChampXPList[++TargetChamplvl])
		{
		;debug msgbox
		;Msgbox % CurrentChampXPString " " ChampXPList[TargetChamplvl] " " TargetChamplvl
		}
		
		GuiControl,choose,TargetChamplvl,%TargetChamplvl%
		
		;CurrentChampXPString := ChampXPList[TargetChamplvl]
		;GuiControl,Text, CurrentChampXPString, %CurrentChampXPString%
	}
		

	;Update text boxes
	UpdateRuns()
	
	;Will clear text boxes if 0 or above max xp is entered 
	ClearRuns()
	
	;Extra code in case of unexpected bugs
	if(AmountofAdventures<0)
	{
		ForceZero()		
	}

return
;********************************************************************************
SubmitTargetChamplvl:
	Gui,+OwnDialogs
	Gui,Submit,NoHide
	
	;MsgBox  % ChampXPList[TargetChamplvl]	
	
	if(CurrentChampXPString>552670)
	{
		CurrentChampXPString := 552670
		GuiControl,Text, CurrentChampXPString, %CurrentChampXPString%
	}
	
	if(CurrentChampXPString > ChampXPList[TargetChamplvl])
	{
		CurrentChampXPString := ChampXPList[TargetChamplvl]		
		GuiControl,Text, CurrentChampXPString, %CurrentChampXPString%
		ForceZero()		
	}
	
	UpdateRuns()
	
	;if input is max, 0, or null then clear lines
	ClearRuns()	
	
	if(AmountofAdventures<0)
	{
		ForceZero()		
	}
	
return	
;********************************************************************************
;For future release, problem is that I can't get it to sync with the target level drop down menu
;SubmitGetLevelXp:
;	Gui,+OwnDialogs
;	Gui,Submit,NoHide
;	CurrentChampXPString := ChampXPList[GetLevelXp]	
;	GuiControl,Text, CurrentChampXPString, %CurrentChampXPString%
;return	

;--------------------------------------------------------------------------------------------------
; Label Functions for Legends XP 
;--------------------------------------------------------------------------------------------------
SubmitCurrentLegendXPString:
	Gui,+OwnDialogs
	Gui,Submit,NoHide
	
	
	if ( CurrentLegendXPString > LegendXP[CurrentLegendlvl] )
	{
	    CurrentLegendXPString := LegendXP[CurrentLegendlvl]	
		GuiControl, text, CurrentLegendXPString, %CurrentLegendXPString%		
	}		
	
	WeekstoLegends := (LegendXPList[TargetLegendlvl] - CurrentLegendXPString - LegendXPList[CurrentLegendlvl])  / WEEKLY_LEGEND_XP
	WeekstoLegends = %WeekstoLegends%
	GuiControl,Text, amountsofweeks,%WeekstoLegends% Weeks
	
return
;********************************************************************************
SubmitCurrentLegendlvl:
	Gui,+OwnDialogs
	Gui,Submit,NoHide
		
	
	if( CurrentLegendlvl>=TargetLegendlvl)
	{
		TargetLegendlvl := CurrentLegendlvl 
		GuiControl,choose, TargetLegendlvl,%TargetLegendlvl%		
	}
	
	if ( CurrentLegendXPString > LegendXP[CurrentLegendlvl] )
	{
	    CurrentLegendXPString := LegendXP[CurrentLegendlvl]	
		GuiControl, text, CurrentLegendXPString, %CurrentLegendXPString%		
	}	
	
	if(CurrentLegendXPString> LegendXPList[TargetLegendlvl])
	{
			CurrentLegendXPString := 0
			GuiControl,Text, amountsofweeks, Weeks
	}
	
	else
	{
	WeekstoLegends := (LegendXPList[TargetLegendlvl] - CurrentLegendXPString - LegendXPList[CurrentLegendlvl])  / WEEKLY_LEGEND_XP
	WeekstoLegends = %WeekstoLegends%
	GuiControl,Text, amountsofweeks,%WeekstoLegends% Weeks
	}
	
return
;********************************************************************************
SubmitTargetLegendlvl:
	Gui,+OwnDialogs
	Gui,Submit,NoHide
	
	if (CurrentLegendlvl>=TargetLegendlvl)
	{
	
		CurrentLegendlvl := TargetLegendlvl-1			

		GuiControl,choose, CurrentLegendlvl,%CurrentLegendlvl%	
		
		CurrentLegendXPString := 0
		GuiControl, Text, CurrentLegendXPString, %CurrentLegendXPString%	
		GuiControl, Text, amountsofweeks, fuck Weeks		
	}	
	
	else
	{	
		WeekstoLegends := (LegendXPList[TargetLegendlvl] - CurrentLegendXPString - LegendXPList[CurrentLegendlvl])  / WEEKLY_LEGEND_XP
		WeekstoLegends = %WeekstoLegends%
		GuiControl,Text, amountsofweeks, %WeekstoLegends% Weeks
	}
	
return

;---------------------------------------------------------
;Macro & Functions
;---------------------------------------------------------

ForceZero()
{
		global
		
		GuiControl,Text, halfstar, 0
		GuiControl,Text, onestar, 0
		GuiControl,Text, oneandhalfstar, 0
		GuiControl,Text, twostar, 0
		GuiControl,Text, twoandhalfstar, 0
		GuiControl,Text, threestar, 0
		GuiControl,Text, threeandhalfstar, 0
		GuiControl,Text, galiostar, 0
		GuiControl,Text, lissstar, 0
		GuiControl,Text, yasuostar, 0
		GuiControl,Text, asolstar, 0
		GuiControl,Text, warwickstar, 0
		GuiControl,Text, fivestar, 0
		GuiControl,Text, sixstar, 0
		GuiControl,Text, aasolstar, 0
		
		return
}

ClearRuns()
{
	global
	
	if(CurrentChampXPString = "" || CurrentChampXPString >= MAX_CHAMP_XP || CurrentChampXPString = 0)
	{
		ForceZero()
		;GuiControl,Text, halfstar, 0
		;GuiControl,Text, onestar, 0
		;GuiControl,Text, oneandhalfstar, 0
		;GuiControl,Text, twostar, 0
		;GuiControl,Text, twoandhalfstar, 0
		;GuiControl,Text, threestar, 0
		;GuiControl,Text, threeandhalfstar, 0
		;GuiControl,Text, galiostar, 0
		;GuiControl,Text, lissstar, 0
		;GuiControl,Text, yasuostar, 0
		;GuiControl,Text, asolstar, 0
		;GuiControl,Text, warwickstar, 0
		;GuiControl,Text, fivestar, 0
		;GuiControl,Text, sixstar, 0
		;GuiControl,Text, aasolstar, 0 
	}
		
	return
}

UpdateRuns()
{
	global
	
	;	<.5   1   1.5   2    2.5    3    3.5   GAL  Liss  Yasuo  Asol   N5    N6
	;1 - .5*---------------------------------------------------------------------------------------

	ctr := 0
	
	frac_adv := mod( (ChampXPList[TargetChamplvl] - CurrentChampXPString),StarXP[1])
	;MsgBox % frac_adv
	while frac_adv>halfstarXP[++ctr] && ctr<4
	{}	
	
	AmountofAdventures := floor((ChampXPList[TargetChamplvl] - CurrentChampXPString) / StarXP[1])
	GuiControl,Text, halfstar, %AmountofAdventures%+%ctr%/4
	
	if(ctr = 4)
	{
		AmountofAdventures++
		GuiControl,Text, halfstar, %AmountofAdventures%
	}
	
	;2 - 1*---------------------------------------------------------------------------------------
	
	ctr := 0
	
	frac_adv := mod( (ChampXPList[TargetChamplvl] - CurrentChampXPString),StarXP[2])
	;MsgBox % frac_adv
	while frac_adv>onestarXP[++ctr] && ctr<7
	{}	
	
	AmountofAdventures := floor((ChampXPList[TargetChamplvl] - CurrentChampXPString) / StarXP[2])
	GuiControl,Text, onestar, %AmountofAdventures%+%ctr%/7
	
	if(ctr = 7)
	{
		AmountofAdventures++
		GuiControl,Text, onestar, %AmountofAdventures%
	}
	
	;3 - 1.5*---------------------------------------------------------------------------------------
	
	ctr := 0
	
	frac_adv := mod( (ChampXPList[TargetChamplvl] - CurrentChampXPString),StarXP[3])
	;MsgBox % frac_adv
	while frac_adv>oneandstarXP[++ctr] && ctr<7
	{}	
	
	AmountofAdventures := floor((ChampXPList[TargetChamplvl] - CurrentChampXPString) / StarXP[3])
	GuiControl,Text, oneandhalfstar, %AmountofAdventures%+%ctr%/7
	
	if(ctr = 7)
	{
		AmountofAdventures++
		GuiControl,Text, oneandhalfstar, %AmountofAdventures%
	}
	
	
	;4 - 2*---------------------------------------------------------------------------------------

	
	ctr := 0
	
	frac_adv := mod( (ChampXPList[TargetChamplvl] - CurrentChampXPString),StarXP[4])
	;MsgBox % frac_adv
	while frac_adv>twostarXP[++ctr] && ctr<7
	{}	
	
	AmountofAdventures := floor((ChampXPList[TargetChamplvl] - CurrentChampXPString) / StarXP[4])
	GuiControl,Text, twostar, %AmountofAdventures%+%ctr%/7
	
	if(ctr = 7)
	{
		AmountofAdventures++
		GuiControl,Text, twostar, %AmountofAdventures%
	}
	
	;5 - 2.5*--------------------------------------------------------------------------------------
	ctr := 0
	
	frac_adv := mod( (ChampXPList[TargetChamplvl] - CurrentChampXPString),StarXP[5])
	;MsgBox % frac_adv
	while frac_adv>twoandstarXP[++ctr] && ctr<7
	{}	
	
	AmountofAdventures := floor((ChampXPList[TargetChamplvl] - CurrentChampXPString) / StarXP[5])
	GuiControl,Text, twoandhalfstar, %AmountofAdventures%+%ctr%/7
	
	if(ctr = 7)
	{
	AmountofAdventures++
	GuiControl,Text, twoandhalfstar, %AmountofAdventures%
	}
	
	;if (CurrentChampXPString == 0 )
	;GuiControl,Text, twoandhalfstar, 
	
	;6 - 3*--------------------------------------------------------------------------------------------
	ctr := 0
	
	frac_adv := mod( (ChampXPList[TargetChamplvl] - CurrentChampXPString),StarXP[6])
	;MsgBox % frac_adv
	while frac_adv>threestarXP[++ctr] && ctr<7
	{}	
	
	AmountofAdventures := floor((ChampXPList[TargetChamplvl] - CurrentChampXPString) / StarXP[6])
	GuiControl,Text, threestar, %AmountofAdventures%+%ctr%/7
	
	if(ctr = 7)
	{
	AmountofAdventures++
	GuiControl,Text, threestar, %AmountofAdventures%
	}
	;7 - 3.5*------------------------------------------------------------------------------------------
	ctr := 0
	
	frac_adv := mod( (ChampXPList[TargetChamplvl] - CurrentChampXPString),StarXP[7])
	;MsgBox % frac_adv
	while frac_adv>threehalfstarXP[++ctr] && ctr<7
	{}	
	
	AmountofAdventures := floor((ChampXPList[TargetChamplvl] - CurrentChampXPString) / StarXP[7])
	GuiControl,Text, threeandhalfstar, %AmountofAdventures%+%ctr%/7
	
	if(ctr = 9)
	{
	AmountofAdventures++
	GuiControl,Text, threeandhalfstar, %AmountofAdventures%
	}
	
	;8 - galio------------------------------------------------------------------------------------------
	ctr := 0
	
	frac_adv := mod( (ChampXPList[TargetChamplvl] - CurrentChampXPString),StarXP[8])
	;MsgBox % frac_adv
	while frac_adv>GalioXP[++ctr] && ctr<9
	{}	
	
	AmountofAdventures := floor((ChampXPList[TargetChamplvl] - CurrentChampXPString) / StarXP[8])
	GuiControl,Text, galiostar, %AmountofAdventures%+%ctr%/9
	
	if(ctr = 9)
	{
	AmountofAdventures++
	GuiControl,Text, galiostar, %AmountofAdventures%
	}
	
	;9 - Liss--------------------------------------------------------------------------------------------
	ctr := 0
	
	frac_adv := mod( (ChampXPList[TargetChamplvl] - CurrentChampXPString),StarXP[9])
	;MsgBox % frac_adv
	while frac_adv>lissXP [++ctr] && ctr<7
	{}	
	
	AmountofAdventures := floor((ChampXPList[TargetChamplvl] - CurrentChampXPString) / StarXP[9])
	GuiControl,Text, lissstar, %AmountofAdventures%+%ctr%/7
	
	if(ctr = 7)
	{
	AmountofAdventures++
	GuiControl,Text, lissstar, %AmountofAdventures%
	}
	
	;10 - Yasuo*-------------------------------------------------------------
	ctr := 0
	
	frac_adv := mod( (ChampXPList[TargetChamplvl] - CurrentChampXPString),StarXP[10])
	;MsgBox % frac_adv	
	
	while frac_adv>yasuoXP[++ctr] && ctr<7
	{}
	
	AmountofAdventures := floor( (ChampXPList[TargetChamplvl] - CurrentChampXPString) / StarXP[10] )
	GuiControl,Text, yasuostar, %AmountofAdventures%+%ctr%/7
	
	if(ctr = 7)
	{
	AmountofAdventures++
	GuiControl,Text, yasuostar, %AmountofAdventures%
	}
	
	;11 - Asol--------------------------------------------------------------------------------------------
	ctr := 0
	
	frac_adv := mod( (ChampXPList[TargetChamplvl] - CurrentChampXPString),StarXP[11])
	;MsgBox % frac_adv
	while frac_adv>asolXP [++ctr] && ctr<12
	{}	
	
	AmountofAdventures := floor((ChampXPList[TargetChamplvl] - CurrentChampXPString) / StarXP[11])
	GuiControl,Text, asolstar, %AmountofAdventures%+%ctr%/12
	
	if(ctr = 12)
	{
	AmountofAdventures++
	GuiControl,Text, asolstar, %AmountofAdventures%
	}
	
	;12 - Warwick*-------------------------------------------------------------
	ctr := 0
	
	frac_adv := mod( (ChampXPList[TargetChamplvl] - CurrentChampXPString),StarXP[12])
	;MsgBox % frac_adv	
	
	while frac_adv>WarwickXP[++ctr] && ctr<8
	{}
	
	AmountofAdventures := floor( (ChampXPList[TargetChamplvl] - CurrentChampXPString) / StarXP[12] )
	GuiControl,Text, warwickstar, %AmountofAdventures%+%ctr%/8
	
	if(ctr = 8)
	{
	AmountofAdventures++
	GuiControl,Text, warwickstar, %AmountofAdventures%
	}
	
	;13 - 5*-------------------------------------------------------------
	ctr := 0
	
	frac_adv := mod( (ChampXPList[TargetChamplvl] - CurrentChampXPString),StarXP[13])
	;MsgBox % frac_adv
	while frac_adv>fivestarXP[++ctr] && ctr<7
	{}	
	
	AmountofAdventures := floor((ChampXPList[TargetChamplvl] - CurrentChampXPString) / StarXP[13])
	GuiControl,Text, fivestar, %AmountofAdventures%+%ctr%/7
	
	if(ctr = 7)
	{
	AmountofAdventures++
	GuiControl,Text, fivestar, %AmountofAdventures%
	}
	;14 - 6*-------------------------------------------------------------
	ctr := 0
	
	frac_adv := mod( (ChampXPList[TargetChamplvl] - CurrentChampXPString),StarXP[14])
	;MsgBox % frac_adv
	while frac_adv>sixnightmareXP[++ctr] && ctr<7
	{}	
	
	AmountofAdventures := floor((ChampXPList[TargetChamplvl] - CurrentChampXPString) / StarXP[14])
	GuiControl,Text, sixstar, %AmountofAdventures%+%ctr%/7
	
	if(ctr = 7)
	{
	AmountofAdventures++
	GuiControl,Text, sixstar, %AmountofAdventures%
	}
	;15 - 6.5*--------------------------------------------------------------------------
	ctr := 0
	
	frac_adv := mod( (ChampXPList[TargetChamplvl] - CurrentChampXPString),StarXP[15])
	;MsgBox % frac_adv
	while frac_adv>ArcaneAsolXP[++ctr] && ctr<12
	{}	
	
	AmountofAdventures := floor((ChampXPList[TargetChamplvl] - CurrentChampXPString) / StarXP[15])
	GuiControl,Text, aasolstar, %AmountofAdventures%+%ctr%/12
	
	if(ctr = 12)
	{
	AmountofAdventures++
	GuiControl,Text, aasolstar, %AmountofAdventures%
	}
	
	;	<.5   1   1.5   2    2.5    3    3.5   GAL  Liss  Yasuo  Asol   N5    N6
	
	return
}	


;this a simple function used to set the cursor position if an invalid char is entered
GetCursorCorrection(input)
{
	;test := NumGet(CurrentChampXPString) 
	
	;if(input>99999)
	;return 6
	if(input>9999)
	return 5
	else if(input>999)
	return 4
	else if(input>99)
	return 3
	else if(input>9)
	return 2	
	else
	return 1

}
;prevent non-numbers
;WM_CHAR(wParam, lParam)
;{	
;	If(A_GuiControl = %CurrentChampXPString% and !RegExMatch(Chr(wParam), "^[0-9]*$")) ;
;	{
;		Return false
;	}
;}

;Don't remember why I have this
OnMessage(0x102, "WM_CHAR")
return	


^x::ExitApp
