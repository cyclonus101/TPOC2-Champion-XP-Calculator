#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
;MsgBox %A_AhkVersion%
;MsgBox %A_ScreenDPI%
#SingleInstance, force

profile100 := "images\profile\Pixels 100\"
profile75  := "images\profile\Pixels 75\"
;--------------------------------------------------------------------------------------------------
; history
;--------------------------------------------------------------------------------------------------
/*
August 15/25 
-Updated Adventure Icons
-Updated to auto detect DPI settings
-Cleaned up the updaterunstext code

Bugs:
->If entering too many invalid characters at the same time then will be able to be entered into the textbox
->For some reason the shift + number keys will just enter the number instead of special character (don't understand why this happens)

TODO: 
->I don't plan on adding 1.5* warwick to the list

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

halfstarXP       := [ 20, 40,  60, 100] ;4
onestarXP        := [ 10, 20, 110, 160, 205, 245  305] ;7
oneandstarXP     := [ 15, 30, 215, 320, 410, 485, 605] ;7
twostarXP        := [ 25, 50, 350, 520, 665, 790, 985] ;7
twoandstarXP     := [ 35, 70, 565, 780, 960,1140,1425] ;7
threestarXP		 := [ 50,100, 770,1060,1300,1540,1925] ;7
threehalfstarXP	 := [ 75,150,1230,1695,2045,2395,3015] ;7
GalioXP          := [ 75,150, 615, 965,1315,1780,2130,2480,3100] ;9
ASolXP           := [ 95,190, 285, 700,2015,2280,2545,2810,3225,3490,3755,4505] ;12
LissXP           := [110,220,1785,2345,2905,3465,4360] ;7
YasuoXP 		 := [110,220,1785,2455,3015,3575,4470] ;7
WarwickXP 		 := [130,260,1045,1700,2355,3140,3795,4840] ;8
fivestarXP       := [130,260,2090,2875,3530,4185,5230]      ;7
sixnightmareXP   := [150,300,2410,3315,4070,4825,6030]      ;7
ArcaneAsolXP	 := [170,340, 510,1545,3955,4815,5675,6710,7570,8430,9290,10670] ;12
; Patch 6.7 - 15 types of battles

;didn't bother adding it to the main calculator
LongLissXP       := [110,220,1785,2345,3910,4470,5030,5925] ;8

;LUT for pointers to the XP LUTs that are used by the updaterunstext functions
AdventureXP_LUT := [halfstarXP,onestarXP,oneandstarXP,twostarXP,twoandstarXP,threestarXP,threehalfstarXP,GalioXP,ASolXP,LissXP,YasuoXP,WarwickXP,fivestarXP,sixnightmareXP,ArcaneAsolXP]

;This is a lut for the names of the gui text boxes, these need to be quotes for the updaterunstext to work
AdventureText_LUT := ["halfstar","onestar","oneandhalfstar","twostar","twoandhalfstar","threestar","threeandhalfstar","galiostar","lissStar","yasuoStar","asolstar","warwickstar","fivestar","sixstar","aasolstar"]       

;LUT for amount of battles per adventure
               ;.5 1*  to  3.5 Gal ASOL Lis Yas, WW,5k,6k ASOL
BATTLES_LUT := [ 4,7,7,7,7,7,7,  9,  12, 7,   7,  8, 7, 7, 12]

;****************************************************************

;used to do some calculations
frac_adv     := 0
ctr          := 0
;Used for the Text Boxes and drop down menus
CurrentChampXP		:= 0
TargetChamplvl      := 30
CurrentLegendXP     := 0
CurrentLegendlvl    := 1
TargetLegendlvl     := 50

;Hardcoded Definitions

MAX_CHAMP_LEVEL := 50
MAX_CHAMP_XP := 552670

MAX_LEGEND_LEVEL :=80
MAX_LEGEND_XP := 2360000

WEEKLY_LEGEND_XP := 27000

MAX_UNIQUE_ADVENTURES_XP := 15

;****************************************************************

;XY Coordinate offsets for Images
XPTEXTOFFSETY := 44
STAROFFSETY   := 18
;TEXTFFSETY    := 3

BOTTOMSTARY := 480
BOTTOMRUNY  := 445

;This is for the 75x75 pics
BOTTOMADVY1 := 65
BOTTOMADVY2 := 140
BOTTOMADVY3 := 215
BOTTOMADVY4 := 290
;this for the 100x100 pics
BOTTOMADVY1x := 65
BOTTOMADVY2x := 165
BOTTOMADVY3x := 265
BOTTOMADVY4x := 360

;--------------------------------------------------------------------------------------------------
; Prechecks
;--------------------------------------------------------------------------------------------------
;Make sure all Images are included
CheckImages()

;--------------------------------------------------------------------------------------------------
; GUI Stuff
;--------------------------------------------------------------------------------------------------
SetFormat, float, 6.1

;setup braum as as tray icon
Menu, Tray,  Icon, images\braum.ico

;GUI background image setup
Gui, +dpiscale -alwaysontop ;enable dpi scaling

;handles background image placement
if(A_ScreenDPI >= 144)
Gui, Add, Picture, x-25 y-60, images\mel-2560x1440.png 

else if(A_ScreenDPI >= 120)
Gui, Add, Picture, x-180 y-100, images\mel-2560x1440.png 

else if(A_ScreenDPI >= 96)
Gui, Add, Picture, x-425 y-150, images\mel-2560x1440.png 

else
{
	MsgBox % DPI too low to display background image
	ExitApp
}

Gui, Font, Arial

;Debug TextBoxes
;Gui, add , Edit, x1500 y400 w50 ReadOnly vdpibox, %A_ScreenDPI%

;Text Boxes - Adventures to Win
;Normal Adventures
Gui, add , Edit, vhalfstar         x0   y%XPTEXTOFFSETY% w75 ReadOnly
Gui, add , Edit, vonestar          x75  y%XPTEXTOFFSETY% w75 ReadOnly
Gui, add , Edit, voneandhalfstar   x150 y%XPTEXTOFFSETY% w75 ReadOnly
Gui, add , Edit, vtwostar          x225 y%XPTEXTOFFSETY% w75 ReadOnly
Gui, add , Edit, vtwoandhalfstar   x300 y%XPTEXTOFFSETY% w75 ReadOnly
Gui, add , Edit, vthreestar        x375 y%XPTEXTOFFSETY% w75 ReadOnly
Gui, add , Edit, vthreeandhalfstar x450 y%XPTEXTOFFSETY% w75 ReadOnly
;Special Adventures
Gui, add , Edit, vgaliostar        x545   y%XPTEXTOFFSETY%  w75 ReadOnly
Gui, add , Edit, vlissStar         x670   y%XPTEXTOFFSETY%  w75 ReadOnly
Gui, add , Edit, vyasuoStar        x805   y%XPTEXTOFFSETY%  w75 ReadOnly
Gui, add , Edit, vasolstar         x918   y%XPTEXTOFFSETY%  w75 ReadOnly
Gui, add , Edit, vwarwickstar      x1042  y%XPTEXTOFFSETY%  w75 ReadOnly
Gui, add , Edit, vfivestar         x1165  y%XPTEXTOFFSETY%  w75 ReadOnly
Gui, add , Edit, vsixstar          x1313  y%XPTEXTOFFSETY%  w75 ReadOnly
Gui, add , Edit, vaasolstar        x1487  y%XPTEXTOFFSETY%  w75 ReadOnly

;Images - Star picture locations**********************************************************
Gui, add, picture, x30 y%STAROFFSETY%   w13 h25 , images\halfstar.png
;1 star
Gui, add, picture, x100 y%STAROFFSETY%  w25 h25, images\wholestar.png
;1.5 star
Gui, add, picture, x170 y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x195 y%STAROFFSETY%  w13 h25, images\halfstar.png
; 2 star
Gui, add, picture, x238 y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x263 y%STAROFFSETY%  w25 h25, images\wholestar.png
; 2.5 star
Gui, add, picture, x306 y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x331 y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x356 y%STAROFFSETY%  w13 h25, images\halfstar.png
; 3 star
Gui, add, picture, x375 y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x400 y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x425 y%STAROFFSETY%  w25 h25, images\wholestar.png
;Fiddle/Heist
Gui, add, picture, x452 y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x477 y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x502 y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x527 y%STAROFFSETY%  w13 h25, images\halfstar.png
;Galio
Gui, add, picture, x545 y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x570 y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x595 y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x620 y%STAROFFSETY%  w13 h25, images\halfstar.png
;Liss
Gui, add, picture, x645 y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x670 y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x695 y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x720 y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x745 y%STAROFFSETY%  w25 h25, images\wholestar.png
;Yasuo
Gui, add, picture, x780  y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x805  y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x830  y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x855  y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x880  y%STAROFFSETY%  w13 h25, images\halfstar.png
;ASol
Gui, add, picture, x905  y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x930  y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x955  y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x980  y%STAROFFSETY%  w25 h25, images\wholestar.png

;Arcane Warwick
Gui, add, picture, x1017  y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x1042  y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x1067  y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x1092  y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x1117  y%STAROFFSETY%  w13 h25, images\halfstar.png

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
Gui, add, picture, x1437  y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x1462  y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x1487  y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x1512  y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x1537  y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x1562  y%STAROFFSETY%  w25 h25, images\wholestar.png
Gui, add, picture, x1587  y%STAROFFSETY%  w13 h25, images\halfstar.png

;********************************************************************************

;Images - Adventure Icons Cordinates
;0 or .5
Gui, add, picture, x0 y%BOTTOMADVY1%  w75 h75, %profile75%\teemo-profile-75x75-border.png
Gui, add, picture, x0 y%BOTTOMADVY2%  w75 h75, %profile75%\mf-profile-75x75-border.png
;1
Gui, add, picture, x75 y%BOTTOMADVY1% w75 h75, %profile75%\garen-profile-75x75-border.png
Gui, add, picture, x75 y%BOTTOMADVY2% w75 h75, %profile75%\lulu-profile-75x75-border.png
;1.5
Gui, add, picture, x150 y%BOTTOMADVY1%  w75 h75, %profile75%\gp-profile-75x75-border.png
Gui, add, picture, x150 y%BOTTOMADVY2%  w75 h75, %profile75%\ezreal-profile-75x75-border.png
Gui, add, picture, x150 y%BOTTOMADVY3%  w75 h75, %profile75%\illaoi-profile-75x75-border.png
;2
Gui, add, picture, x225 y%BOTTOMADVY1%  w75 h75, %profile75%\zed-profile-75x75-border.png
Gui, add, picture, x225 y%BOTTOMADVY2%  w75 h75, %profile75%\naut-profile-75x75-border.png
Gui, add, picture, x225 y%BOTTOMADVY3%  w75 h75, %profile75%\darius-profile-75x75-border.png
;2.5
Gui, add, picture, x300 y%BOTTOMADVY1%  w75 h75, %profile75%\viktor-profile-75x75-border.png
Gui, add, picture, x300 y%BOTTOMADVY2%  w75 h75, %profile75%\draven-profile-75x75-border.png
Gui, add, picture, x300 y%BOTTOMADVY3%  w75 h75, %profile75%\azir-profile-75x75-border.png
;3
Gui, add, picture, x375 y%BOTTOMADVY1%  w75 h75, %profile75%\elder-profile-75x75-border.png
Gui, add, picture, x375 y%BOTTOMADVY2%  w75 h75, %profile75%\kaisa-profile-75x75-border.png
Gui, add, picture, x375 y%BOTTOMADVY3%  w75 h75, %profile75%\thresh-profile-75x75-border.png
;3.5
Gui, add, picture, x450 y%BOTTOMADVY1%  w75 h75, %profile75%\fiddle1-profile-75x75-border.png
Gui, add, picture, x450 y%BOTTOMADVY2%  w75 h75, %profile75%\heist-profile-75x75-border.png
Gui, add, picture, x450 y%BOTTOMADVY3%  w75 h75, %profile75%\garen-profile-75x75-border.png
;galio
Gui, add, picture, x545 y%BOTTOMADVY1x%  w100 h100, %profile100%\galio-profile-100x100-border.png
;lissandra
Gui, add, picture, x658 y%BOTTOMADVY1x%  w100 h100, %profile100%\liss-profile-100x100-border.png
;yasuo
Gui, add, picture, x793 y%BOTTOMADVY1x%  w100 h100, %profile100%\yasuo-profile-100x100-border.png
;asol
Gui, add, picture, x905 y%BOTTOMADVY1x% w100 h100, %profile100%\asol-profile-100x100-border.png
;arcane warwick 
Gui, add, picture, x1030 y%BOTTOMADVY1x%  w100 h100, %profile100%\warwick-profile-100x100-border.png
;Swain
Gui, add, picture, x1153 y%BOTTOMADVY1x%  w100 h100, %profile100%\swain-profile-100x100-border.png
Gui, add, picture, x1153 y%BOTTOMADVY2x%  w100 h100, %profile100%\fizz-profile-100x100-border.png
;Viego/Fiddle
Gui, add, picture, x1300 y%BOTTOMADVY1x%  w100 h100, %profile100%\viego-profile-100x100-border.png
Gui, add, picture, x1300 y%BOTTOMADVY2x%  w100 h100, %profile100%\fiddle2-profile-100x100-border.png
Gui, add, picture, x1300 y%BOTTOMADVY3x%  w100 h100, %profile100%\karma-profile-100x100-border.png

;arcane asol
Gui, add, picture, x1475 y%BOTTOMADVY1% w100 h100, %profile100%\asol-profile-100x100-border.png

;Testing

;********************************************************************************

;CurrentChampXP
Gui, add , Edit, limit6 vCurrentChampXPString gSubmitCurrentChampXPString x0 y405 w70 
Gui, add , DropDownList, x80 y405 w65  vTargetChamplvl gSubmitTargetChamplvl, 1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30||31|32|33|34|35|36|37|38|39|40|41|42|43|44|45|46|47|48|49|50
;
Gui, add , Edit, x0 y365 ReadOnly vfriendlytext1, Enter your champion's XP in the box below 
Gui, add , Edit, x150 y405 ReadOnly vfriendlytext2, Select your target level from the drop down menu

;increase font size if the DPI is too high
if(A_ScreenDPI >= 144)
Gui, Font, s12, Arial

Gui, add , Edit, x0 y310 w485 h50 ReadOnly vfriendlytext3 -vscroll, The numbers above show how many times you need to beat that adventure plus any additional battles to reach your target level

;********************************************************************************

;Legends XP part - currently removed because it's not that relevent
;Gui, add , Edit, limit5 vCurrentLegendXPString gSubmitCurrentLegendXPString xm+778 y350 w70 h28
;Gui, add , DropDownList, xm+850  y350 w65  vCurrentLegendlvl gSubmitCurrentLegendlvl , 1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33|35|36|37|38|39|40|41|42|43|44|45|46|47|48|49|50||51|52|53|54|55|56|57|58|59|60|61|62|63|64|65|66|67|68|69|70|71|71|72|73|74|75|76|77|78|79|80
;Gui, add , DropDownList, xm+850  y380 w65  vTargetLegendlvl  gSubmitTargetLegendlvl  , 1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33|35|36|37|38|39|40|41|42|43|44|45|46|47|48|49|50|51|52|53|54|55|56|57|58|59|60|61|62|63|64|65|66|67|68|69|70|71|71|72|73|74|75|76|77|78|79|80||
;Gui, add , Edit, vamountsofweeks xm+723 y380 w125 h28 ReadOnly, Weeks 
;Gui, add, Picture, x750 y325, images\legend_icon.png

;********************************************************************************

;Start the GUI
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
		;reset the cursor to position it was at when the invalid character was removed
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
	;This is to increase the level from drop down menu to be above the XP amount entered
	if(CurrentChampXPString>ChampXPList[TargetChamplvl])
	{
	
		while(CurrentChampXPString>ChampXPList[++TargetChamplvl])
		{
		;debug msgbox
		;Msgbox % CurrentChampXPString " " ChampXPList[TargetChamplvl] " " TargetChamplvl
		}
		
		GuiControl,choose,TargetChamplvl,%TargetChamplvl%
	}
		
	;Update text boxes
	UpdateRuns()
	
	;Will clear text boxes if invalid XP amount if present
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
	}
		
	return
}

UpdateRuns()
{
	global	

	loop := 1 
	; MAX_UNIQUE_ADVENTURES_XP is currently the total number of adventures that provide unique XP
	; This excludes special conditions like longer or shorter adventures  and 1* WW
	while ( loop <= MAX_UNIQUE_ADVENTURES_XP )
	{	
		; Update the Amount of adventures and battles ctr by inputing the loop# which acts as an index
		; to pointers of LUTs that provide the values for amounts of battles and XP amounts
		UpdateRunText(loop, BATTLES_LUT[loop], AdventureXP_LUT[loop])
		
		; I need to get the Text_LUT text and Battles_LUT like this to make it a string for the GuiControl
		controlName := AdventureText_LUT[loop]
		battleNum := BATTLES_LUT[loop]
		
		; Update the GUI text dynamically
		GuiControl, Text, %controlName%, %AmountofAdventures%+%ctr%/%battleNum%
		
		loop++
	}
	
	return
}	

UpdateRunText(Adventure, MaxCtr, ByRef AdventureLUT)
{
	global	
	
	ctr := 0
	
	frac_adv := mod( (ChampXPList[TargetChamplvl] - CurrentChampXPString),StarXP[Adventure])
	while frac_adv>AdventureLUT[++ctr] && ctr<MaxCtr
	{}	
	
	AmountofAdventures := floor((ChampXPList[TargetChamplvl] - CurrentChampXPString) / StarXP[Adventure])

	if(ctr = MaxCtr)
	{
		AmountofAdventures++
		ctr := 0
	}
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

CheckImages()
{
	FileRead, files, images\filelist.txt
	missing := ""

	Loop, Parse, files, `n, `r
	{
		f := Trim(A_LoopField)
		if (f = "")
        continue
		if !FileExist("images\" . f)
        missing .= f . "`n"
	}

	if (missing = "")
	{
		;MsgBox All files found!
		return
	}
	
	else	
	{
		MsgBox Missing files:`n`n%missing%
		;ExitApp
	}
	
	return
}

^x::ExitApp