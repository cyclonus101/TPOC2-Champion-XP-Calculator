SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
;MsgBox %A_AhkVersion%
;MsgBox %A_ScreenDPI%
#SingleInstance, force

;--------------------------------------------------------------------------------------------------
; history
;--------------------------------------------------------------------------------------------------
/*

Bugs:
->If entering too many invalid characters at the same time then will be able to be entered into the textbox
->For some reason the shift + number keys will just enter the number instead of special character (don't understand why this happens)

TODO:
-> I want to add adventures with odd XP rewards (1* WW), but it's difficult for spacing reasons
-> Update the lower star adventure icons to be like the others

July 2026
-> Updated for Patch 7.6
-> Added SB Nami
-> Added World + Nightmare Naga
-> Added Nightmare Zoe
-> Fixed bug where adding Naut/Zed adventure was adding the wrong XP

Feb 10/26
-> Updated for Patch 7.2
-> Updated SB Seraphine position so she's in the unique XP blocks rather than sharing with Galio/A Garen
-> Added drop down menu for bonus XP amounts
-> Added the ability to add an adventure's XP by clicking on that adventure, and subtract that by clicking on the stars

Nov 8/25
-> Updated for patch 6.11 (TFT)
-> Added MF/Cait/Lux/Nasus/Baron adventures XP
-> Nasus XP is currently bugged (gives 1925XP vs 5230)
-> Updated the majority of adventure icons to condense same region and XP rate adventures, and fix image quality
-> Updated code with more for loops to make my job easier

Octo 24/25
-> Updated for patch 6.10
-> Added Titans adventures with the icon to the profile pic
-> Adds Arcane logo to arcane adventures
-> Add SB Adventures (except Nami)
-> Changed background image to nasus lvl 3 artwork
-> Changed the layout to be a consistent grid
-> Added illaoi back in, some adventures don't match their reward XP with the difficulty rating, decided to just add them based on XP rewards

August 13/25
->Changed the program to swap between 2.5-3.5 adventures and 2< adventures with a button
->Fixed some bugs caused by bad alignments in the LUTs
->Added campaign icons to the adventure icons (world +nightmare only)
->Updated adventures to be in their appropriate XP columns
->Illaoi removed because her campaign offers weird XP
->Arcane Garen moved to Galio columns
->Grand Heist moved to 3* columns

July 24/25 
->Updated Adventure Icons
->Updated to auto detect DPI settings
->Cleaned up the updaterunstext code

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

*/
;--------------------------------------------------------------------------------------------------
; Lookup Table Stuff
;--------------------------------------------------------------------------------------------------

;****************************************************************************************************************************************
;This LUT is used for quickly searching the XP amount per adventures in the UpdateRuns function in Macro & Functions
;				  <.5   1   1.5   2    2.5    3  SBNAMI 3.5   GAL SBSERA Liss  Yasuo  Asol  Arcane WW ROG YI  N5    N6   Arcane Asol  NGTZOE
StarXP       := [ 100, 305, 605, 985, 1425, 1925, 2475, 3015, 3100, 3200, 4360,  4470, 4505,    4840,   5100, 5230, 6030,   10670,    11970]
;				   1    2    3    4     5     6     7    8      9    10    11     12    13        14      15   16    17	     18         19
;LUT for the SubmitCurrentLegendXPString in Label Functions for Legends XP section 
;Amount of XP for each legend to level up to the next level from 1 to 80                                                                                                                         31     32    33         35                            40                            45                            50                            55          57               60           62                65                68            70                   73     74     75                    80
LegendXP     := [1000,2000,2500,3500,4000,4500,5000,5500,6000,7000,8000,9000,10000,11000,12000,13000,15000,17000,19000,21000,23000,25000,27000,29000,31000,33000,35000,37000,39000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000,45000,45000,45000,45000,45000,45000,60000,60000,60000,60000,60000,80000,80000,80000,80000,80000,80000,100000,100000,100000,100000,100000,100000,120000,120000,120000,120000,120000,120000,120000]

;Total Xp needed for each LL,  LUT for the SubmitCurrentLegendXPString function in Label Functions for Legends XP section
;				 1   2    3    4    5    6     7	  8    9	  10   11	 12	   13	 14	   15	16	    17	  18	  19	 20	   21	  22	 23	   24		25	  26     27     28      29    30     31      32    33     34     35     36     37    38      39     40     41     42      43     44     45    46      47    48      49     50      51 		52	   53       54     55       56      57      58      59      60     61       62      63      64      65      66      67     68       69      70      71      72      73      74      75     76      77       78      79      80                                                                                                                                      
LegendXPList := [0,1000,3000,5500,9000,13000,17500,22500,28000,34000,41000,49000,58000,68000,79000,91000,104000,119000,136000,155000,176000,199000,224000,251000,280000,311000,344000,379000,416000,455000,485000,515000,545000,575000,605000,635000,665000,695000,725000,755000,785000,815000,845000,875000,905000,935000,965000,995000,1025000,1055000,1115500,1160500,1205500,1250500,1295500,1340500,1400500,1460500,1520500,1580500,1640500,1720500,1800500,1880500,1960500,2040500,2120500,2220500,2320500,2420500,2520500,2620500,2720500,2840500,2960500,3080500,3200500,3320500,3440500,3560500]

;Total XP needed for champ level it takes from 1 to 50
;				 1  2  3   4   5   6   7     8   9    10	11	12	  13   14   15	16	  17    18	  19	20	  21	22	  23	24	  25	26	  27	28	  29	30	 31		32	  33	34	  35    36	   37	   38	  39	40	   41	 42      43     44    45       46	 47    48      49	  50
ChampXPList  := [0,50,150,300,500,800,1250,1750,2310,2980,3780,4710,5780,6990,8350,9870,11560,13420,15460,17680,20090,22700,25510,28530,31760,35210,38880,42780,46920,51290,57140,64070,72210,81890,93130,105990,120610,136660,155430,176530,200040,226190,255380,287910,323330,361400,402630,448180,497870,552670]

ADD_XP_LUT := {  TEEMO:StarXP[1], MF:StarXP[1]
    , GAREN:   StarXP[2],  LULU:     StarXP[2],  ILLAOI:  StarXP[2]
    , GP:      StarXP[3],  EZ:       StarXP[3]  
    , NAUTZED: StarXP[4],  DAR:      StarXP[4],  SETT:    StarXP[4], AZIR:    StarXP[4]
    , VIKDRAV: StarXP[5],  SBTEEMO1: StarXP[5],  SAMIRA:  StarXP[5], KALISTA: StarXP[5],  TFTCAIT:  StarXP[5]
	, THRKAI:  StarXP[6],  ELDHEI:   StarXP[6],  MORDE:   StarXP[6], NASUS:   StarXP[6]
	, SBNAMI:  StarXP[7],  WNAGA:    StarXP[7]
    , FIDDLE1: StarXP[8],  DIANA:    StarXP[8],  TFTMF:   StarXP[8]
	, GALIO:   StarXP[9],  AGAREN:   StarXP[9]  
	, SBSERA:  StarXP[10]
	, LISS:    StarXP[11]
	, YAS:     StarXP[12]
	, ASOL:    StarXP[13]
	, WW:      StarXP[14]
	, ROGUEYI: StarXP[15]
	, SWAIN:   StarXP[16], FIZZ:     StarXP[16], VOLINAUT:StarXP[16], TFHEIST:  StarXP[16], TFTLUX:   StarXP[16]
	, FIDVIE:  StarXP[17], AKARMA:   StarXP[17], TITELD:  StarXP[17], SBTEEMO2: StarXP[17], TFTBARON: StarXP[17]
	, AASOL:   StarXP[18]
	, NGTZOE:  StarXP[19] }
	
SUB_XP_LUT := { STAR1:StarXP[1], STAR2:StarXP[2], STAR3:StarXP[3], STAR4:StarXP[4], STAR5:StarXP[5],STAR6:StarXP[6],STAR7:StarXP[7],STAR8:StarXP[8],STAR9:StarXP[9],STAR10:StarXP[10],STAR11:StarXP[11],STAR12:StarXP[12],STAR13:StarXP[13],STAR14:StarXP[14],STAR15:StarXP[15],STAR16:StarXP[16],STAR17:StarXP[17],STAR18:StarXP[18],STAR19:StarXP[19]}

	
;****************************************************************************************************************************************
; Patch 7.5 - 19 types of battles
; There are more battles with different XP structure, decided not to include all of them
UNIQUE_ADVENTURE_XP_REWARDS = 19
; LUT for XP per battle won on an adventure
halfstarXP       := [ 20, 40,  60, 100] ;4
onestarXP        := [ 10, 20, 110, 160, 205, 245  305] ;7
oneandstarXP     := [ 15, 30, 215, 320, 410, 485, 605] ;7
twostarXP        := [ 25, 50, 350, 520, 665, 790, 985] ;7
twoandstarXP     := [ 35, 70, 565, 780, 960,1140,1425] ;7
threestarXP		 := [ 50,100, 770,1060,1300,1540,1925] ;7
SBNamiXP         := [ 60,120, 990,1360,1670,1980,2475] ; 7
threehalfstarXP	 := [ 75,150,1230,1695,2045,2395,3015] ;7
GalioXP          := [ 75,150, 615, 965,1315,1780,2130,2480,3100] ;9
SBSeraXP         := [ 95,190,1505,1920,2185,2450,3200]
LissXP           := [110,220,1785,2345,2905,3465,4360] ;7
YasuoXP 		 := [110,220,1785,2455,3015,3575,4470] ;7
WarwickXP 		 := [130,260,1045,1700,2355,3140,3795,4840] ;8
ASolXP           := [ 95,190, 285, 700,2015,2280,2545,2810,3225,3490,3755,4505] ;12
rogueyiXP        := [  0,130,1960,2745,3400,4055,5100]      ;7
fivestarXP       := [130,260,2090,2875,3530,4185,5230]      ;7
sixnightmareXP   := [150,300,2410,3315,4070,4825,6030]      ;7
ArcaneAsolXP	 := [170,340, 510,1545,3955,4815,5675,6710,7570,8430,9290,10670] ;12
NightmareZoeXP   := [130,260, 390,1390,1520,1650,2650,2780,2910,3910,4565, 5220,6220,6350,7005,7660,8660,9315,9970,11970] ; 20!
;                      1  2    3    4    5    6   7    8     9    10  11    12   13   14    15  16   17    18   19   20

BonusXP_LUT := [100,175,200,250,275,300,325,375,400,475,500,550,575,600,625,675,700,775,1000,1200]

;didn't bother with it
LongLissXP       := [110,220,1785,2345,3910,4470,5030,5925] ;8

;LUT for Pointers to XP tables
AdventureXP_LUT :=   [halfstarXP, onestarXP,     oneandstarXP, twostarXP,     twoandstarXP,  threestarXP, SBNamiXP,   threehalfstarXP,     GalioXP, SBSeraXP,  LissXP,    YasuoXP,     ASolXP,     WarwickXP, rogueyiXP, fivestarXP, sixnightmareXP, ArcaneAsolXP, NightmareZoeXP]
;LUT for Pointers to the XP text boxs
;This needs to be quotes for the updaterunstext to work
AdventureText_LUT := ["halfstar","onestar" , "oneandhalfstar", "twostar", "twoandhalfstar",  "threestar", "sbnami", "threeandhalfstar", "galiostar","sbserastar", "lissStar","yasuoStar", "asolstar", "warwickstar", "rogueyistar", "fivestar",      "sixstar",  "aasolstar", "nightzoe"]       
;LUT for battles per adventure
               ;.5 1*  to    3.5,  Gal, SBSERA, Lis, Yas, ASOL,  WW,SBYI,5k, 6k, AASOL NGTZOE
BATTLES_LUT := [ 4,7,7,7,7,7,7,7,    9,    7,    7,   7,   12,   8,  7,   7,  7,  12,   20]
;****************************************************************************************************************************************
;lists for swapping between the low and mid tier adventures on the left side of the gui
;used by Show/HideControls functions

LowStarAdvList  := ["TEEMO","MF","GAREN","LULU","GP","EZ","ILLAOI","NAUTZED","DAR","SETT","AZIR"]
LowStarTextList := ["halfstar","onestar","oneandhalfstar","twostar"]
LowStarIconList := ["STAR1","STAR2","STAR3","STAR4"]

MidStarAdvList  := ["VIKDRAV","KALISTA","TFTCAIT","SBTEEMO1","SAMIRA","THRKAI","SBNAMI0","WNAGA","FIDDLE1","DIANA","TFTMF","ELDHEI","MORDE","NASUS"]
MidStarTextList := ["twoandhalfstar","threestar","threeandhalfstar","sbnami"]
MidStarIconList := ["STAR5","STAR6","STAR7","STAR8"]


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

ShowLowStar := 0


BonusXP := 100 ;this is a percentage
;Path Shortcuts************************************

STARS       := "images\stars"
PROFILE     := "images\Adventure Profile Pictures"

;Hardcoded Definitions************************************

MAX_CHAMP_LEVEL := 50
MAX_CHAMP_XP := 552670

MAX_LEGEND_LEVEL :=80
MAX_LEGEND_XP := 2360000

WEEKLY_LEGEND_XP := 27000


;Text Boxs X/Y Coord*****************************************
TEXTX0  :=   13  
TEXTX1  :=  113
TEXTX2  :=  213
TEXTX3  :=  313
TEXTX4  :=  413	
TEXTX5  :=  513
TEXTX6  :=  613
TEXTX7  :=  713
TEXTX8  :=  813
TEXTX9  :=  913
TEXTX10 := 1013
TEXTX11 := 1113

TEXTY1 := 50
TEXTY2 := 200 
TEXTY3 := 350 

;For Star Icons X/Y Coord************************************************

STARY := 0
STARY0 := 25
STARY1 := 175
STARY2 := 325
STARY3 := 475

STARX0 := 113
STARX1 := 213
STARX2 := 313
STARX3 := 413
STARX4 := 513
STARX5 := 600
STARX6 := 700
STARX7 := 800
STARX8 := 900
STARX9 := 1013
STARX10 := 1100

;For Adventure Icons X/Y Coord*******************************************

ICONSLOTY0 := 0
ICONSLOTY1 := 75
ICONSLOTY2 := 200
ICONSLOTY3 := 325
ICONSLOTY4 := 450
ICONSLOTY5 := 575

ICONSLOTY22 := 225
ICONSLOTY33 := 375
ICONSLOTY44 := 525
 
ICONSLOTX0  :=   0
ICONSLOTX1  := 100
ICONSLOTX2  := 200
ICONSLOTX3  := 300
ICONSLOTX4  := 400
ICONSLOTX5  := 500
ICONSLOTX6  := 600
ICONSLOTX7  := 700
ICONSLOTX8  := 800
ICONSLOTX9  := 900
ICONSLOTX10 := 1000
ICONSLOTX11 := 1100

ICONSLOTY1 := 75
ICONSLOTY2 := 175
ICONSLOTY3 := 275
ICONSLOTY4 := 375
ICONSLOTY5 := 475
ICONSLOTY6 := 575

zoom := 1.1
imgW := 2048 * zoom
imgH := 1024 * zoom
xOffset := -350
yOffset := -050
;--------------------------------------------------------------------------------------------------
; Prechecks
;--------------------------------------------------------------------------------------------------

;Make sure all Images are included
;CheckImages()

;--------------------------------------------------------------------------------------------------
; GUI Stuff
;--------------------------------------------------------------------------------------------------
SetFormat, float, 6.1

;setup braum as as tray icon
Menu, Tray,  Icon, images\braum.ico

;GUI background image setup
Gui, +dpiscale -alwaysontop ;enable dpi scaling

Gui, Font, s12, Arial 

Gui, Add, Picture, x%xOffset% y%yOffset% w%imgW% h%imgH%, images\naga-2048-1024.png 


;Debug TextBoxes
;Gui, add , Edit, x1500 y400 w50 ReadOnly vdpibox, %A_ScreenDPI%
;************************************************************************
;Text Boxes - Adventures to Win
;Normal Adventures
Gui, add , Edit, vhalfstar         x%TEXTX2% y%TEXTY1% w75 h25 ReadOnly
Gui, add , Edit, vonestar          x%TEXTX3% y%TEXTY1% w75 h25 ReadOnly
Gui, add , Edit, voneandhalfstar   x%TEXTX4% y%TEXTY1% w75 h25 ReadOnly
Gui, add , Edit, vtwostar          x%TEXTX5% y%TEXTY1% w75 h25 ReadOnly
;by default 2.5*+ adventures are show, so hide low star images												  
HideControls(LowStarTextList)

Gui, add , Edit, vtwoandhalfstar   x%TEXTX2% y%TEXTY1% w75 h25 ReadOnly
Gui, add , Edit, vthreestar        x%TEXTX3% y%TEXTY1% w75 h25 ReadOnly
Gui, add , Edit, vsbnami           x%TEXTX4% y%TEXTY1% w75 h25 ReadOnly
Gui, add , Edit, vthreeandhalfstar x%TEXTX5% y%TEXTY1% w75 h25 ReadOnly

;Special Adventures
Gui, add , Edit, vgaliostar        x%TEXTX6%  y%TEXTY1%  w75 h25 ReadOnly


Gui, add , Edit, vlissStar         x%TEXTX7%  y%TEXTY3%  w75 h25 ReadOnly
Gui, add , Edit, vasolstar         x%TEXTX7%  y%TEXTY2%  w75 h25 ReadOnly
Gui, add , Edit, vsbserastar       x%TEXTX7%  y%TEXTY1%  w75 h25 ReadOnly

Gui, add , Edit, vyasuoStar        x%TEXTX8%  y%TEXTY1%  w75 h25 ReadOnly
Gui, add , Edit, vwarwickstar      x%TEXTX8%  y%TEXTY2%  w75 h25 ReadOnly
Gui, add , Edit, vrogueyistar      x%TEXTX8%  y%TEXTY3%  w75 h25 ReadOnly

Gui, add , Edit, vfivestar         x%TEXTX9%  y%TEXTY1%  w75 h25 ReadOnly
Gui, add , Edit, vsixstar          x%TEXTX10%  y%TEXTY1%  w75 h25 ReadOnly
Gui, add , Edit, vaasolstar        x%TEXTX11%  y%TEXTY1%  w75 h25 ReadOnly
Gui, add , Edit, vnightzoe         x%TEXTX11%  y%TEXTY2%  w75 h25 ReadOnly

;Images - Star picture locations**********************************************************

; .5 star
Gui, add, picture, vSTAR1 x%STARX1% y%STARY0%  w12 h25 gSubXP, %STARS%\0HALFSTAR.png
; 1 star           
Gui, add, picture, vSTAR2 x%STARX2% y%STARY0%  w25 h25 gSubXP, %STARS%\1STAR.png
; 1.5 star      
Gui, add, picture, vSTAR3 x%STARX3% y%STARY0%  w37 h25 gSubXP, %STARS%\1HALFSTAR.png
; 2 star
Gui, add, picture, vSTAR4 x%STARX4% y%STARY0%  w50 h25 gSubXP, %STARS%\2STAR.png

;by default 2.5*+ adventures are show, so hide low star images
HideControls(LowStarIconList)

; 2.5 star
Gui, add, picture, vSTAR5 x%STARX1% y%STARY0% w62 h25 gSubXP, %STARS%\2HALFSTAR.png
; 3 star           
Gui, add, picture, vSTAR6 x%STARX2% y%STARY0% w75 h25 gSubXP, %STARS%\3STAR.png

; SB Nami / Naga           
Gui, add, picture, vSTAR7 x%STARX3% y%STARY0% w75 h25 gSubXP, %STARS%\3STAR.png
;Fiddle/Heist      
Gui, add, picture, vSTAR8 x%STARX4% y%STARY0%  w87 h25 gSubXP, %STARS%\3HALFSTAR.png
;Galio
Gui, add, picture, vSTAR9 x%STARX5% y%STARY0%  w87 h25 gSubXP, %STARS%\3HALFSTAR.png
;SBSERA
Gui, add, picture, vSTAR10 x%STARX6%  y%STARY0%  w100 h25 gSubXP, %STARS%\4STAR.png
;Liss
Gui, add, picture, vSTAR11 x%STARX6%  y%STARY2%  w100 h25 gSubXP, %STARS%\5STAR.png   
;ASol
Gui, add, picture, vSTAR13 x%STARX6%  y%STARY1%  w100 h25 gSubXP, %STARS%\4STAR.png 
;Yasuo
Gui, add, picture, vSTAR12 x%STARX7%  y%STARY0%  w100 h25 gSubXP, %STARS%\4HALFSTAR.png          
;Arcane Warwick
Gui, add, picture, vSTAR14 x%STARX7%  y%STARY1%  w100 h25 gSubXP,  %STARS%\4HALFSTAR.png
;SB Master YI
Gui, add, picture, vSTAR15 x%STARX7%  y%STARY2%  w100 h25 gSubXP,  %STARS%\4HALFSTAR.png
;Swain/Fizz
Gui, add, picture, vSTAR16 x%STARX8%  y%STARY0%  w100 h25 gSubXP, %STARS%\5STAR.png
;Viego/Fiddle/ Arcane Karma
Gui, add, picture, vSTAR17 x%STARX9%  y%STARY%  w75 h50 gSubXP, %STARS%\6STARVERT.png
;Arcane Asol
Gui, add, picture, vSTAR18 x%STARX10%  y%STARY%  w87 h50 gSubXP, %STARS%\6HALFSTARVERT.png
;Nightmare Zoe
Gui, add, picture, vSTAR19 x%STARX10%  y%STARY1%  w100 h25 gSubXP, %STARS%\10STAR.png


;********************************************************************************

;Images - Adventure Icons Cordinates
;0 or .5
Gui, add, picture, vTEEMO  x%ICONSLOTX2% y%ICONSLOTY1%  w100 h100 gAddXP, %PROFILE%\World 125 Teemo.png
Gui, add, picture, vMF     x%ICONSLOTX2% y%ICONSLOTY2%  w100 h100 gAddXP, %PROFILE%\World 125 MF.png
;1
Gui, add, picture, vGAREN  x%ICONSLOTX3% y%ICONSLOTY1% w100 h100 gAddXP, %PROFILE%\World 150 Garen.png
Gui, add, picture, vLULU   x%ICONSLOTX3% y%ICONSLOTY2% w100 h100 gAddXP, %PROFILE%\World 125 Lulu.png
Gui, add, picture, vILLAOI x%ICONSLOTX3% y%ICONSLOTY3% w100 h100 gAddXP, %PROFILE%\Arcane 150 Illaoi.png
;1.5
Gui, add, picture, vGP     x%ICONSLOTX4% y%ICONSLOTY1%  w100 h100 gAddXP, %PROFILE%\World 125 Gangplank.png
Gui, add, picture, vEZ     x%ICONSLOTX4% y%ICONSLOTY2%  w100 h100 gAddXP, %PROFILE%\World 125 Ezreal.png

;2
Gui, add, picture, vNAUTZED x%ICONSLOTX5% y%ICONSLOTY1%  w100 h100 gAddXP, %PROFILE%\World 150 Naut Zed.png
Gui, add, picture, vDAR     x%ICONSLOTX5% y%ICONSLOTY2%  w100 h100 gAddXP, %PROFILE%\World 125 Darius.png
Gui, add, picture, vSETT    x%ICONSLOTX5% y%ICONSLOTY3%  w100 h100 gAddXP, %PROFILE%\Titans 150 Sett.png
Gui, add, picture, vAZIR    x%ICONSLOTX5% y%ICONSLOTY4%  w100 h100 gAddXP, %PROFILE%\Arcane 150 Azir.png

;hide low star adventure
HideControls(LowStarAdvList)

;2.5
Gui, add, picture, vVIKDRAV  x%ICONSLOTX2% y%ICONSLOTY1%  w100 h100 gAddXP, %PROFILE%\World 150 Viktor Draven.png
Gui, add, picture, vSBTEEMO1 x%ICONSLOTX2% y%ICONSLOTY2%  w100 h100 gAddXP, %PROFILE%\World 150 SB Teemo.png
Gui, add, picture, vSAMIRA   x%ICONSLOTX2% y%ICONSLOTY3%  w100 h100 gAddXP, %PROFILE%\Rogues 150 Samira.png
Gui, add, picture, vKALISTA  x%ICONSLOTX2% y%ICONSLOTY4%  w100 h100 gAddXP, %PROFILE%\SB 150 Kalista.png
Gui, add, picture, vTFTCAIT  x%ICONSLOTX2% y%ICONSLOTY5%  w100 h100 gAddXP, %PROFILE%\TFT 150 Caitlyn.png

;3
Gui, add, picture, vTHRKAI  x%ICONSLOTX3% y%ICONSLOTY1%  w100 h100 gAddXP, %PROFILE%\World 150 Thresh Kaisa.png
Gui, add, picture, vELDHEI  x%ICONSLOTX3% y%ICONSLOTY2%  w100 h100 gAddXP, %PROFILE%\World 150 Heist Elder.png
Gui, add, picture, vMORDE   x%ICONSLOTX3% y%ICONSLOTY3%  w100 h100 gAddXP, %PROFILE%\Titans 150 Mordekaiser.png
Gui, add, picture, vNASUS   x%ICONSLOTX3% y%ICONSLOTY4%  w100 h100 gAddXP, %PROFILE%\TFT 150 Nasus.png

;3 / 2475
Gui, add, picture, vWNAGA    x%ICONSLOTX4% y%ICONSLOTY1%  w100 h100 gAddXP, %PROFILE%\World 150 Naga.png
Gui, add, picture, vSBNAMI0  x%ICONSLOTX4% y%ICONSLOTY2%  w100 h100 gAddXP, %PROFILE%\SB 150 Nami.png

;3.5 / 3015 XP rewards
Gui, add, picture, vFIDDLE1 x%ICONSLOTX5% y%ICONSLOTY1%  w100 h100 gAddXP, %PROFILE%\World 150 Fiddle.png
Gui, add, picture, vDIANA   x%ICONSLOTX5% y%ICONSLOTY2%  w100 h100 gAddXP, %PROFILE%\Rogues 150 Diana.png
Gui, add, picture, vTFTMF   x%ICONSLOTX5% y%ICONSLOTY3%  w100 h100 gAddXP, %PROFILE%\TFT 150 MF.png

															                  
;3100-3200 xp rewards
Gui, add, picture, vGALIO   x%ICONSLOTX6% y%ICONSLOTY1%  w100 h100 gAddXP, %PROFILE%\World 150 Galio.png
Gui, add, picture, vAGAREN  x%ICONSLOTX6% y%ICONSLOTY2%  w100 h100 gAddXP, %PROFILE%\Arcane 150 Garen.png

;********************************************************************************
;SBSERAPHINE
Gui, add, picture, vSBSERA  x%ICONSLOTX7% y%ICONSLOTY1%  w100 h100 gAddXP, %PROFILE%\SB 150 Seraphine.png
;asol
Gui, add, picture, vASOL    x%ICONSLOTX7% y%ICONSLOTY22%  w100 h100 gAddXP, %PROFILE%\World 150 Aurelion Sol.png
;lissandra
Gui, add, picture, vLISS    x%ICONSLOTX7% y%ICONSLOTY33%  w100 h100 gAddXP, %PROFILE%\World 150 Lissandra.png

;4k-5k XP rewards
Gui, add, picture, vYAS     x%ICONSLOTX8% y%ICONSLOTY1%   w100 h100 gAddXP, %PROFILE%\World 150 Yasuo.png
Gui, add, picture, vWW      x%ICONSLOTX8% y%ICONSLOTY22%  w100 h100 gAddXP, %PROFILE%\Arcane 150 Warwick.png
Gui, add, picture, vROGUEYI x%ICONSLOTX8% y%ICONSLOTY33%  w100 h100 gAddXP, %PROFILE%\Rogues 150 Master Yi.png

;5230 XP rewards
Gui, add, picture, vSWAIN    x%ICONSLOTX9% y%ICONSLOTY1%  w100 h100 gAddXP, %PROFILE%\World 150 Swain.png
Gui, add, picture, vFIZZ     x%ICONSLOTX9% y%ICONSLOTY2%  w100 h100 gAddXP, %PROFILE%\Nightmare 150 Fizz.png
Gui, add, picture, vVOLINAUT x%ICONSLOTX9% y%ICONSLOTY3%  w100 h100 gAddXP, %PROFILE%\Titans 150 Voli Naut.png
Gui, add, picture, vTFHEIST  x%ICONSLOTX9% y%ICONSLOTY4%  w100 h100 gAddXP, %PROFILE%\Rogues 150 TF Heist.png
Gui, add, picture, vTFTLUX   x%ICONSLOTX9% y%ICONSLOTY5%  w100 h100 gAddXP, %PROFILE%\TFT 150 Lux.png

;6030 XP rewards
Gui, add, picture, vFIDVIE   x%ICONSLOTX10% y%ICONSLOTY1%  w100 h100 gAddXP, %PROFILE%\Nightmare 150 Fiddle Viego.png
Gui, add, picture, vAKARMA   x%ICONSLOTX10% y%ICONSLOTY2%  w100 h100 gAddXP, %PROFILE%\Arcane 150 Karma.png
Gui, add, picture, vTITELD   x%ICONSLOTX10% y%ICONSLOTY3%  w100 h100 gAddXP, %PROFILE%\Titans 150 Elder.png
Gui, add, picture, vSBTEEMO2 x%ICONSLOTX10% y%ICONSLOTY4%  w100 h100 gAddXP, %PROFILE%\SB 150 Teemo J4.png
Gui, add, picture, vTFTBARON x%ICONSLOTX10% y%ICONSLOTY5%  w100 h100 gAddXP, %PROFILE%\TFT 150 Baron.png

;Arcane Asol
Gui, add, picture, vAASOL  x%ICONSLOTX11% y%ICONSLOTY1% w100 h100 gAddXP, %PROFILE%\Arcane 150 Aurelion Sol.png
Gui, add, picture, vNGTZOE x%ICONSLOTX11% y%ICONSLOTY22% w100 h100 gAddXP, %PROFILE%\Nightmare 150 Zoe.png

;********************************************************************************
;CurrentChampXP
Gui, add , Edit, limit6 vCurrentChampXPString gSubmitCurrentChampXPString x55 y145 w70, 0 
Gui, add , DropDownList, x%ICONSLOTX0% y%ICONSLOTY2% w65  vTargetChamplvl gSubmitTargetChamplvl, 1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30||31|32|33|34|35|36|37|38|39|40|41|42|43|44|45|46|47|48|49|50
;Bonus Xp
Gui, add , DropDownList, x%ICONSLOTX1% y%ICONSLOTY2% w65  vBonusXPString gSubmitBonusXPString, 100||175|200|250|275|300|325|375|400|475|500|550|575|600|625|675|700|775|1000|1200
Gui, add , Edit, x%ICONSLOTX1% y200  w100 ReadOnly vfriendlytext6 -vscroll,
(
Select your bonus XP
)

;Toggle
Gui, Add, Button, x%ICONSLOTX2% y%ICONSLOTY0% gTogglePanel, Show Low Star Adventures

Gui, Font, s8.5, Arial
Gui, add , Edit, x1015 x%ICONSLOTX0% y200 w100 ReadOnly vfriendlytext1 -vscroll,
(
Select your target level 
from the drop down menu
)
Gui, add , Edit, x%ICONSLOTX0% y%ICONSLOTY3% w200 ReadOnly vfriendlytext2 Multi -vscroll,
(
The numbers above show how 
many times you need to beat 
that adventure plus any additional battles to reach your target level 
)
Gui, add , Edit, x%ICONSLOTX0% y%ICONSLOTY1% w100 ReadOnly vfriendlytext7 Multi -vscroll,
(
Enter your champion's XP in the box below 
)
Gui, add , Edit, x%ICONSLOTX0% y%ICONSLOTY5% w100 ReadOnly vfriendlytext3 Multi -vscroll,
(
Created By:
Cyclonus101
With help from:
CaptSarah
Grimm
LoR wiki
)

Gui, add , Edit, x%ICONSLOTX1% y%ICONSLOTY0% w100 ReadOnly vfriendlytext4 -vscroll,
(
Click the stars to subtract that adventure's XP
)
Gui, add , Edit, x%ICONSLOTX1% y%ICONSLOTY1% w100 ReadOnly vfriendlytext5 -vscroll,
(
Click the adventure 
icon to add that adventure's XP
)

;Start the GUI**************************************************************
Gui, Show, w1200 h575, Path of Champions XP Calculator Patch 7.6 Illaoi Constellation Patch
return
;--------------------------------------------------------------------------------------------------
; Label Functions for Champ XP 
;--------------------------------------------------------------------------------------------------

AddXP:
    GuiControlGet, temp,, CurrentChampXPString
    temp += ADD_XP_LUT[A_GuiControl]
    GuiControl,, CurrentChampXPString, %temp%
return

SubXP:
    GuiControlGet, temp,, CurrentChampXPString
	if(temp>SUB_XP_LUT[A_GuiControl])
    temp -= SUB_XP_LUT[A_GuiControl]
	else
	temp := 0
	
    GuiControl,, CurrentChampXPString, %temp%
return

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
	;This is increase the level from drop down menu to be above the XP amount entered
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

SubmitBonusXPString:
	
	;BonusXP := BonusXPString
	;BonusXP_LUT[BonusXPString]
	
	GuiControlGet, BonusXP,, BonusXPString	
	;MsgBox %BonusXP%
	UpdateRuns()
	
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
		
		SetAllTextBoxes(AdventureText_LUT,0)
		
		return
}

SetAllTextBoxes(TextList, textValue) {
    for _, text in TextList
    GuiControl, Text, %Text%, %textValue%
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
	; UNIQUE_ADVENTURE_XP_REWARDS is currently the total number of adventures that provide unique XP
	;msgbox %UNIQUE_ADVENTURE_XP_REWARDS%
	while ( loop <= UNIQUE_ADVENTURE_XP_REWARDS  )
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
	AdjustedXP := Floor( (ChampXPList[TargetChamplvl] - CurrentChampXPString) / (BonusXP / 100))
	
	frac_adv := mod(AdjustedXP,StarXP[Adventure])
	ADVXP := StarXP[Adventure]
	
	;if(adventure==19)
	;msgbox Remainder XP %frac_adv% %AdjustedXP% %ADVXP% %MaxCtr%
	
	while frac_adv>AdventureLUT[++ctr] && ctr<MaxCtr
	{}	
	
	AmountofAdventures := floor((ChampXPList[TargetChamplvl] - CurrentChampXPString) / StarXP[Adventure])

	if(ctr = MaxCtr)
	{
		AmountofAdventures++
		ctr := 0
	}
	AmountofAdventures := Floor(AmountofAdventures / (BonusXP / 100))
	
}	

;this a simple function used to set the cursor position if an invalid char is entered
GetCursorCorrection(input)
{
	;test := NumGet(CurrentChampXPString) 
	
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
		ExitApp
	}
	
	return
}

ShowControls(ctrlList) {

    for _, ctrl in ctrlList
        GuiControl, Show, %ctrl%
}

HideControls(ctrlList) {
    for _, ctrl in ctrlList
        GuiControl, Hide, %ctrl%
}

TogglePanel:
	;toggle showing lower star adventures
	ShowLowStar ^= 1
	
	if(ShowLowStar)
	{
		;Hide Text Boxes,Adv,Icons for mid tiers
		HideControls(MidStarAdvList)
		HideControls(MidStarTextList)
		HideControls(MidStarIconList)
		;Show Text Boxes,Adv,Icons for low tiers
		ShowControls(LowStarAdvList)
		ShowControls(LowStarTextList)
		ShowControls(LowStarIconList)
	}
	
	else
	{
		;Hide Text Boxes,Adv,Icons for low tiers
		HideControls(LowStarAdvList)
		HideControls(LowStarTextList)
		HideControls(LowStarIconList)
		;Show Text Boxes,Adv,Icons for mid tiers
		ShowControls(MidStarAdvList)
		ShowControls(MidStarTextList)
		ShowControls(MidStarIconList)
	}


return

^x::ExitApp
