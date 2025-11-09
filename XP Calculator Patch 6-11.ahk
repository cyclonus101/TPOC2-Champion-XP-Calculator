#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
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
-> I want to add adventures with odd XP rewards (1* WW and SB Nami), but it's difficult for spacing reasons
-> Update TFT MF/CAIT/LUX/BARON icons to be like the others
-> Update the lower star adventure icons to be like the others

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
;				  <.5   1   1.5   2    2.5    3    3.5   GAL  Liss  Yasuo  Asol  Arcane WW ROG YI  N5    N6   Arcane Asol  
StarXP       := [ 100, 305, 605, 985, 1425, 1925, 3015, 3100, 4360,  4470, 4505,    4840,   5100, 5230, 6030,   10670]

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
; Patch 6.11 - 16 types of battles
; There are more battles with different XP structure, decided not to include all of them
UNIQUE_ADVENTURE_XP_REWARDS = 16
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
rogueyiXP        := [  0,130,1960,2745,3400,4055,5100]      ;7
fivestarXP       := [130,260,2090,2875,3530,4185,5230]      ;7
sixnightmareXP   := [150,300,2410,3315,4070,4825,6030]      ;7
ArcaneAsolXP	 := [170,340, 510,1545,3955,4815,5675,6710,7570,8430,9290,10670] ;12


;didn't bother with it
LongLissXP       := [110,220,1785,2345,3910,4470,5030,5925] ;8

;LUT for Pointers to XP tables
AdventureXP_LUT :=   [halfstarXP, onestarXP,     oneandstarXP, twostarXP,     twoandstarXP,  threestarXP,    threehalfstarXP,     GalioXP,     LissXP,    YasuoXP,     ASolXP,     WarwickXP, rogueyiXP, fivestarXP, sixnightmareXP, ArcaneAsolXP]
;LUT for Pointers to the XP text boxs
;This needs to be quotes for the updaterunstext to work
AdventureText_LUT := ["halfstar","onestar" , "oneandhalfstar", "twostar", "twoandhalfstar",  "threestar", "threeandhalfstar", "galiostar", "lissStar","yasuoStar", "asolstar", "warwickstar", "rogueyistar", "fivestar",      "sixstar",  "aasolstar"]       
;LUT for battles per adventure
               ;.5 1*  to  3.5,  Gal, Lis, Yas, ASOL,  WW,SBYI,5k, 6k, ASOL
BATTLES_LUT := [ 4,7,7,7,7,7,7,    9,   7,   7,   12,   8,  7,   7,  7,   12]
;****************************************************************************************************************************************
;lists for swapping between the low and mid tier adventures on the left side of the gui
;used by Show/HideControls functions

LowStarAdvList  := ["TEEMO","MF","GAREN","LULU","GP","EZ","ILLAOI","NAUTZED","DAR","SETT","AZIR"]
LowStarTextList := ["halfstar","onestar","oneandhalfstar","twostar"]
LowStarIconList := ["STAR1","STAR2","STAR3","STAR4"]

MidStarAdvList  := ["VIKDRAV","KALISTA","TFTCAIT","SBTEEMO","SAMIRA","THRKAI","FIDDLE1","DIANA","TFTMF","ELDHEI","MORDE","NASUS","AGAREN","GALIO","SBSERAPHINE"]
MidStarTextList := ["twoandhalfstar","threestar","threeandhalfstar","galiostar"]
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
TEXTX0S :=  13  
TEXTX1S := 113
TEXTX2S := 213
TEXTX3S := 313
TEXTX4S := 413	
TEXTX5S := 513
TEXTX6S := 613
TEXTX7S := 713
TEXTX8S := 813

;below was for when I was 125pix icons
TEXTX0 :=  30 
TEXTX1 := 150
TEXTX2 := 275
TEXTX3 := 425 
TEXTX4 := 425

TEXTX5 := 550 
TEXTX6 := 850
TEXTX7 := 1013

TEXTX8 := 875
TEXTX9 := 1000
TEXTX10 := 1125

TEXTY1 := 50
TEXTY2 := 200 
TEXTY3 := 350 

;For Star Icons X/Y Coord************************************************

;STARY0 := 25
;STARY1 := 200

STARY := 0
STARY0 := 25
STARY1 := 175
STARY2 := 325
STARY3 := 475

STARX0 :=  13
STARX1 := 113
STARX2 := 213
STARX3 := 313
STARX4 := 413
STARX5 := 525

STARX8 := 850
STARX9 := 1000
STARX10 := 1125

;For Adventure Icons X/Y Coord*******************************************
ICONSLOTX1 :=0 
ICONSLOTX2 :=125 
ICONSLOTX3 :=250 
ICONSLOTX4 :=400 

ICONSLOTX5 :=525 
ICONSLOTX6 :=650
ICONSLOTX7 :=725 
ICONSLOTX8 :=850
ICONSLOTX9 :=975
ICONSLOTX10 :=1100

ICONSLOTX6L :=700
ICONSLOTX7L :=825 
ICONSLOTX8L :=987
ICONSLOTX9L :=1150 

ICONSLOTY1 := 75
ICONSLOTY2 := 200
ICONSLOTY3 := 325
ICONSLOTY4 := 450
ICONSLOTY5 := 575

ICONSLOTY22 := 225
ICONSLOTY33 := 375
ICONSLOTY44 := 525
 
ICONSLOTX0S :=   0
ICONSLOTX1S := 100
ICONSLOTX2S := 200
ICONSLOTX3S := 300
ICONSLOTX4S := 400
ICONSLOTX5S := 500
ICONSLOTX6S := 600
ICONSLOTX7S := 700
ICONSLOTX8S := 800
ICONSLOTX9S := 900

ICONSLOTY1S := 75
ICONSLOTY2S := 175
ICONSLOTY3S := 275
ICONSLOTY4S := 375
ICONSLOTY5S := 475
ICONSLOTY6S := 575
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

Gui, Add, Picture, x0-20 y0, images\baron-2048-1024.png 


;Debug TextBoxes
;Gui, add , Edit, x1500 y400 w50 ReadOnly vdpibox, %A_ScreenDPI%
;************************************************************************
;Text Boxes - Adventures to Win
;Normal Adventures
Gui, add , Edit, vhalfstar         x%TEXTX0S% y%TEXTY1% w75 h25 ReadOnly
Gui, add , Edit, vonestar          x%TEXTX1S% y%TEXTY1% w75 h25 ReadOnly
Gui, add , Edit, voneandhalfstar   x%TEXTX2S% y%TEXTY1% w75 h25 ReadOnly
Gui, add , Edit, vtwostar          x%TEXTX3S% y%TEXTY1% w75 h25 ReadOnly
;by default 2.5*+ adventures are show, so hide low star images												  
HideControls(LowStarTextList)

Gui, add , Edit, vtwoandhalfstar   x%TEXTX0S% y%TEXTY1% w75 h25 ReadOnly
Gui, add , Edit, vthreestar        x%TEXTX1S% y%TEXTY1% w75 h25 ReadOnly
Gui, add , Edit, vthreeandhalfstar x%TEXTX2S% y%TEXTY1% w75 h25 ReadOnly

;Special Adventures
Gui, add , Edit, vgaliostar        x%TEXTX3S%  y%TEXTY1%  w75 h25 ReadOnly

Gui, add , Edit, vlissStar         x%TEXTX4S%  y%TEXTY2%  w75 h25 ReadOnly
Gui, add , Edit, vasolstar         x%TEXTX4S%  y%TEXTY1%  w75 h25 ReadOnly

Gui, add , Edit, vyasuoStar        x%TEXTX5S%  y%TEXTY1%  w75 h25 ReadOnly
Gui, add , Edit, vwarwickstar      x%TEXTX5S%  y%TEXTY2%  w75 h25 ReadOnly
Gui, add , Edit, vrogueyistar      x%TEXTX5S%  y%TEXTY3%  w75 h25 ReadOnly

Gui, add , Edit, vfivestar         x%TEXTX6S%  y%TEXTY1%  w75 h25 ReadOnly
Gui, add , Edit, vsixstar          x%TEXTX7S%  y%TEXTY1%  w75 h25 ReadOnly
Gui, add , Edit, vaasolstar        x%TEXTX8S%  y%TEXTY1%  w75 h25 ReadOnly

;Images - Star picture locations**********************************************************

; .5 star
Gui, add, picture, vSTAR1 x%STARX0% y%STARY0%  w12 h25, %STARS%\0HALFSTAR.png
; 1 star           
Gui, add, picture, vSTAR2 x%STARX1% y%STARY0%  w25 h25, %STARS%\1STAR.png
; 1.5 star      
Gui, add, picture, vSTAR3 x%STARX2% y%STARY0%  w37 h25, %STARS%\1HALFSTAR.png
; 2 star
Gui, add, picture, vSTAR4 x%STARX3% y%STARY0%  w50 h25, %STARS%\2STAR.png

;by default 2.5*+ adventures are show, so hide low star images
HideControls(LowStarIconList)

; 2.5 star
Gui, add, picture, vSTAR5 x%STARX0% y%STARY0% w62 h25, %STARS%\2HALFSTAR.png
; 3 star           
Gui, add, picture, vSTAR6 x%STARX1% y%STARY0% w75 h25, %STARS%\3STAR.png
;Fiddle/Heist      
Gui, add, picture, vSTAR7 x%STARX2% y%STARY0%  w87 h25, %STARS%\3HALFSTAR.png
;Galio
Gui, add, picture, vSTAR8 x%STARX3% y%STARY0%  w87 h25, %STARS%\3HALFSTAR.png

;ASol
Gui, add, picture, x%ICONSLOTX4S%  y%STARY0%  w100 h25, %STARS%\4STAR.png
;Liss
Gui, add, picture, x%ICONSLOTX4S%  y%STARY1%  w100 h25, %STARS%\5STAR.png
;Yasuo
Gui, add, picture, x%ICONSLOTX5S%  y%STARY0%  w100 h25, %STARS%\4HALFSTAR.png              
;Arcane Warwick
Gui, add, picture, x%ICONSLOTX5S%  y%STARY1%  w100 h25,  %STARS%\4HALFSTAR.png
;SB Master YI
Gui, add, picture, x%ICONSLOTX5S%  y%STARY2%  w100 h25,  %STARS%\4HALFSTAR.png
;Swain/Fizz
Gui, add, picture, x%ICONSLOTX6S%  y%STARY0%  w100 h25, %STARS%\5STAR.png
;Viego/Fiddle/ Arcane Karma
Gui, add, picture, x%TEXTX7S%  y%STARY%  w75 h50, %STARS%\6STARVERT.png
;Arcane Asol
Gui, add, picture, x%TEXTX8S%  y%STARY%  w87 h50, %STARS%\6HALFSTARVERT.png


;********************************************************************************

;Images - Adventure Icons Cordinates
;0 or .5
Gui, add, picture, vTEEMO  x%ICONSLOTX0S% y%ICONSLOTY1S%  w100 h100, %PROFILE%\World 125 Teemo.png
Gui, add, picture, vMF     x%ICONSLOTX0S% y%ICONSLOTY2S%  w100 h100, %PROFILE%\World 125 MF.png
;1
Gui, add, picture, vGAREN  x%ICONSLOTX1S% y%ICONSLOTY1S% w100 h100, %PROFILE%\World 150 Garen.png
Gui, add, picture, vLULU   x%ICONSLOTX1S% y%ICONSLOTY2S% w100 h100, %PROFILE%\World 125 Lulu.png
Gui, add, picture, vILLAOI x%ICONSLOTX1S% y%ICONSLOTY3S%  w100 h100, %PROFILE%\Arcane 150 Illaoi.png
;1.5
Gui, add, picture, vGP     x%ICONSLOTX2S% y%ICONSLOTY1S%  w100 h100, %PROFILE%\World 125 Gangplank.png
Gui, add, picture, vEZ     x%ICONSLOTX2S% y%ICONSLOTY2S%  w100 h100, %PROFILE%\World 125 Ezreal.png

;2
Gui, add, picture, vNAUTZED x%ICONSLOTX3S% y%ICONSLOTY1S%  w100 h100, %PROFILE%\World 150 Naut Zed.png
Gui, add, picture, vDAR     x%ICONSLOTX3S% y%ICONSLOTY2S%  w100 h100, %PROFILE%\World 125 Darius.png
Gui, add, picture, vSETT    x%ICONSLOTX3S% y%ICONSLOTY3S%  w100 h100, %PROFILE%\Titans 150 Sett.png
Gui, add, picture, vAZIR    x%ICONSLOTX3S% y%ICONSLOTY4S%  w100 h100, %PROFILE%\Arcane 150 Azir.png

;hide low star adventure
HideControls(LowStarAdvList)

;2.5
Gui, add, picture, vVIKDRAV x%ICONSLOTX0S% y%ICONSLOTY1S%  w100 h100, %PROFILE%\World 150 Viktor Draven.png
Gui, add, picture, vSBTEEMO x%ICONSLOTX0S% y%ICONSLOTY2S%  w100 h100, %PROFILE%\World 150 SB Teemo.png
Gui, add, picture, vSAMIRA  x%ICONSLOTX0S% y%ICONSLOTY3S%  w100 h100, %PROFILE%\Rogues 150 Samira.png
Gui, add, picture, vKALISTA x%ICONSLOTX0S% y%ICONSLOTY4S%  w100 h100, %PROFILE%\SB 150 Kalista.png
Gui, add, picture, vTFTCAIT x%ICONSLOTX0S% y%ICONSLOTY5S%  w100 h100, %PROFILE%\TFT 150 Caitlyn.png

;3
Gui, add, picture, vTHRKAI  x%ICONSLOTX1S% y%ICONSLOTY1S%  w100 h100, %PROFILE%\World 150 Thresh Kaisa.png
Gui, add, picture, vELDHEI  x%ICONSLOTX1S% y%ICONSLOTY2S%  w100 h100, %PROFILE%\World 150 Heist Elder.png
Gui, add, picture, vMORDE   x%ICONSLOTX1S% y%ICONSLOTY3S%  w100 h100, %PROFILE%\Titans 150 Mordekaiser.png
Gui, add, picture, vNASUS   x%ICONSLOTX1S% y%ICONSLOTY4S%  w100 h100, %PROFILE%\TFT 150 Nasus.png


;3.5 / 3015 XP rewards
Gui, add, picture, vFIDDLE1 x%ICONSLOTX2S% y%ICONSLOTY1S%  w100 h100, %PROFILE%\World 150 Fiddle.png
Gui, add, picture, vDIANA   x%ICONSLOTX2S% y%ICONSLOTY2S%  w100 h100, %PROFILE%\Rogues 150 Diana.png
Gui, add, picture, vTFTMF   x%ICONSLOTX2S% y%ICONSLOTY3S%  w100 h100, %PROFILE%\TFT 150 MF.png
															                  
;3100-3200 xp rewards
Gui, add, picture, vGALIO       x%ICONSLOTX3S% y%ICONSLOTY1S%  w100 h100, %PROFILE%\World 150 Galio.png
Gui, add, picture, vAGAREN      x%ICONSLOTX3S% y%ICONSLOTY2S%  w100 h100, %PROFILE%\Arcane 150 Garen.png
Gui, add, picture, vSBSERAPHINE x%ICONSLOTX3S% y%ICONSLOTY3S%  w100 h100, %PROFILE%\SB 150 Seraphine.png
;********************************************************************************
;asol
Gui, add, picture, x%ICONSLOTX4S% y%ICONSLOTY1%  w100 h100, %PROFILE%\World 150 Aurelion Sol.png

;lissandra
Gui, add, picture, x%ICONSLOTX4S% y%ICONSLOTY22% w100 h100, %PROFILE%\World 150 Lissandra.png

;4k-5k XP rewards
Gui, add, picture, x%ICONSLOTX5S% y%ICONSLOTY1%  w100 h100, %PROFILE%\World 150 Yasuo.png
Gui, add, picture, x%ICONSLOTX5S% y%ICONSLOTY22%  w100 h100, %PROFILE%\Arcane 150 Warwick.png
Gui, add, picture, x%ICONSLOTX5S% y%ICONSLOTY33%  w100 h100, %PROFILE%\Rogues 150 Master Yi.png

;5230 XP rewards
Gui, add, picture, x%ICONSLOTX6S% y%ICONSLOTY1S%  w100 h100, %PROFILE%\World 150 Swain.png
Gui, add, picture, x%ICONSLOTX6S% y%ICONSLOTY2S%  w100 h100, %PROFILE%\Nightmare 150 Fizz.png
Gui, add, picture, x%ICONSLOTX6S% y%ICONSLOTY3S%  w100 h100, %PROFILE%\Titans 150 Voli Naut.png
Gui, add, picture, x%ICONSLOTX6S% y%ICONSLOTY4S%  w100 h100, %PROFILE%\Rogues 150 TF Heist.png
Gui, add, picture, x%ICONSLOTX6S% y%ICONSLOTY5S%  w100 h100, %PROFILE%\TFT 150 Lux.png

;6030 XP rewards
Gui, add, picture, x%ICONSLOTX7S% y%ICONSLOTY1S%  w100 h100, %PROFILE%\Nightmare 150 Fiddle Viego.png
Gui, add, picture, x%ICONSLOTX7S% y%ICONSLOTY2S%  w100 h100, %PROFILE%\Arcane 150 Karma.png
Gui, add, picture, x%ICONSLOTX7S% y%ICONSLOTY3S%  w100 h100, %PROFILE%\Titans 150 Elder.png
Gui, add, picture, x%ICONSLOTX7S% y%ICONSLOTY4S%  w100 h100, %PROFILE%\SB 150 Teemo J4.png
Gui, add, picture, x%ICONSLOTX7S% y%ICONSLOTY5S%  w100 h100, %PROFILE%\TFT 150 Baron.png

;Arcane Asol
Gui, add, picture, x%ICONSLOTX8S% y%ICONSLOTY1S% w100 h100, %PROFILE%\Arcane 150 Aurelion Sol.png

;********************************************************************************
;CurrentChampXP
Gui, add , Edit, limit6 vCurrentChampXPString gSubmitCurrentChampXPString x860 y530 w70 
Gui, add , DropDownList, x935 y530 w65  vTargetChamplvl gSubmitTargetChamplvl, 1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30||31|32|33|34|35|36|37|38|39|40|41|42|43|44|45|46|47|48|49|50

Gui, Font, s9.5, Arial
Gui, add , Edit, x1015 y530 w160 ReadOnly vfriendlytext1 -vscroll,
(
Select your target level 
from the drop down menu
)
Gui, Font, s11, Arial
Gui, add , Edit, x860 y%ICONSLOTY4% w315 ReadOnly vfriendlytext2 Multi -vscroll,
(
The numbers above show how many times 
you need to beat that adventure plus any 
additional battles to reach your target level 
Enter your champion's XP in the box below 
)

Gui, add , Edit, x%ICONSLOTX1S% y%ICONSLOTY5S% w115 ReadOnly vfriendlytext3 Multi -vscroll,
(
Created By:
Cyclonus101
With help from:
CaptSarah
Grimm
LoR wiki
)


;********************************************************************************

;Legends XP part - currently removed because it's not that relevent
;Gui, add , Edit, limit5 vCurrentLegendXPString gSubmitCurrentLegendXPString xm+778 y350 w70 h28
;Gui, add , DropDownList, xm+850  y350 w65  vCurrentLegendlvl gSubmitCurrentLegendlvl , 1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33|35|36|37|38|39|40|41|42|43|44|45|46|47|48|49|50||51|52|53|54|55|56|57|58|59|60|61|62|63|64|65|66|67|68|69|70|71|71|72|73|74|75|76|77|78|79|80
;Gui, add , DropDownList, xm+850  y380 w65  vTargetLegendlvl  gSubmitTargetLegendlvl  , 1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33|35|36|37|38|39|40|41|42|43|44|45|46|47|48|49|50|51|52|53|54|55|56|57|58|59|60|61|62|63|64|65|66|67|68|69|70|71|71|72|73|74|75|76|77|78|79|80||
;Gui, add , Edit, vamountsofweeks xm+723 y380 w125 h28 ReadOnly, Weeks 
;Gui, add, Picture, x750 y325, images\legend_icon.png

;Toggle********************************************************************************
; Toggle button
Gui, Add, Button, x860 y415 gTogglePanel, Show Low Star Adventures

;Start the GUI**************************************************************
Gui, Show, w1225 h575, Path of Champions XP Calculator Patch 6.11 Teamfight Adventures 

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