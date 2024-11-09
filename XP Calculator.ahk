#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#SingleInstance, force
;--------------------------------------------------------------------------------------------------
; history
;--------------------------------------------------------------------------------------------------
/*
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

;XP given for completing an adventure from half star to 4 star
;weekly 3.5 = ???, weekly 4* = 3200, weekly 4.5*=4470
StarXP       := [100,305,605,985,1425,1925,3100,4505,4360,5230,6030]
;Amount of XP for legend level it takes per level from 1 to 30                                                                                                                       31     32    33         35                            40                            45                            50                            55          57               60           62                65                68            70                   73     74     75                                 80
LegendXP     := [1000,2000,2500,3500,4000,4500,5000,5500,6000,7000,8000,9000,10000,11000,12000,13000,15000,17000,19000,21000,23000,25000,27000,29000,31000,33000,35000,37000,39000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000,45000,45000,45000,45000,45000,45000,60000,60000,60000,60000,60000,80000,80000,80000,80000,80000,80000,100000,100000,100000,100000,100000,100000,120000,120000,120000,120000,120000,120000,120000]
;Amount of XP for champ level it takes per level from 1 to 30
;				 1  2  3   4   5   6   7     8   9    10	11	12	  13   14   15	16	  17    18	  19	20	  21	22	  23	24	  25	26	  27	28	  29	30	 31		32	  33	34	  35    36	   37	   38	  39	40	   41	 42      43     44    45       46	 47    48      49	  50
ChampXPList  := [0,50,150,300,500,800,1250,1750,2310,2980,3780,4710,5780,6990,8350,9870,11560,13420,15460,17680,20090,22700,25510,28530,31760,35210,38880,42780,46920,51290,57140,64070,72210,81890,93130,105990,120610,136660,155430,176530,200040,226190,255380,287910,323330,361400,402630,448180,497870,552670]
                ;1   2    3    4    5    6     7	  8    9	  10   11	 12	   13	 14	   15	16	    17	  18	  19	 20	   21	  22	 23	   24		25	  26     27     28      29    30     31      32    33     34     35     36     37    38      39     40     41     42      43     44     45    46      47    48      49     50      51 		52	   53       54     55       56      57      58      59      60     61       62      63      64      65      66      67     68       69      70      71      72      73      74      75     76      77       78      79      80                                                                                                                                      
LegendXPList := [0,1000,3000,5500,9000,13000,17500,22500,28000,34000,41000,49000,58000,68000,79000,91000,104000,119000,136000,155000,176000,199000,224000,251000,280000,311000,344000,379000,416000,455000,485000,515000,545000,575000,605000,635000,665000,695000,725000,755000,785000,815000,845000,875000,905000,935000,965000,995000,1025000,1055000,1115500,1160500,1205500,1250500,1295500,1340500,1400500,1460500,1520500,1580500,1640500,1720500,1800500,1880500,1960500,2040500,2120500,2220500,2320500,2420500,2520500,2620500,2720500,2840500,2960500,3080500,3200500,3320500,3440500,3560500]

;used to do some calculations
frac_adv     := 0
ctr          := 0

;lookup table for XP per battle won on an adventure
halfstarXP       := [ 20, 40,  60, 100]
onestarXP        := [ 10, 20, 110, 160, 205, 245  305]
oneandstarXP     := [ 15, 30, 215, 320, 410, 485, 605]
twostarXP        := [ 25, 50, 350, 520, 665, 790, 985]
twoandstarXP     := [ 35, 70, 565, 780, 960,1140,1425]
threestarXP		 := [ 50,100, 770,1060,1300,1540,1925]
GalioXP          := [ 75,150, 615, 965,1315,1780,2130,2480,3100]
ASolXP           := [ 95,190, 285, 700,2015,2280,2545,2810,3225,3490,3755,4505]
LissXP           := [110,220,1785,2345,2905,3465,4360]
LongLissXP       := [110,220,1785,2345,3910,4470,5030,5925]
fivestarXP       := [130,260,2090,2875,3530,4185,5230]
sixnightmareXP   := [150,300,2410,3315,4070,4825,6030]

sevenbattleadventureratio := [.025,.05,.355,.528,.675,.8,1]
weekly4halfXP    := [110,220,1785,2455,3015,3575,4470]

CurrentChampXP		:=0
TargetChamplvl      :=30

MAX_XP := 552670
MAX_LEGEND_LEVEL :=80
MAX_LEGEND_XP := 2360000
WEEKLY_LEGEND_XP := 27000

BOTTOMSTARY := 475
BOTTOMRUNY  := 435

CurrentLegendXP     :=0
CurrentLegendlvl    :=1
TargetLegendlvl     :=50

;--------------------------------------------------------------------------------------------------
; GUI Stuff
;--------------------------------------------------------------------------------------------------
SetFormat, float, 6.1

;setup braum as as tray icon
Menu, Tray,  Icon, images\braum.ico

;GUI setup
Gui, -dpiscale
Gui, Add, Picture, x0 y0, images\fid_levelup_background.png
Gui, Add, Picture, x750 y325, images\legend_icon.png
Gui, Font, Times New Roman, s30, cwhite


;add star picture locations
Gui, add, picture, xm+90  ym+%BOTTOMSTARY%  w25 h25, images\wholestar.png
Gui, add, picture, xm+220 ym+%BOTTOMSTARY%  w25 h25, images\wholestar.png
Gui, add, picture, xm+245 ym+%BOTTOMSTARY%  w25 h25, images\wholestar.png
Gui, add, picture, xm+350 ym+%BOTTOMSTARY%  w25 h25, images\wholestar.png
Gui, add, picture, xm+375 ym+%BOTTOMSTARY%  w25 h25, images\wholestar.png
Gui, add, picture, xm+400 ym+%BOTTOMSTARY%  w25 h25, images\wholestar.png
Gui, add, picture, xm+525 ym+%BOTTOMSTARY%  w25 h25, images\wholestar.png
Gui, add, picture, xm+550 ym+%BOTTOMSTARY%  w25 h25, images\wholestar.png
Gui, add, picture, xm+575 ym+%BOTTOMSTARY%  w25 h25, images\wholestar.png
Gui, add, picture, xm+600 ym+%BOTTOMSTARY%  w25 h25, images\wholestar.png

;Liss/Swain/Night
Gui, add, picture, xm+635 ym+%BOTTOMSTARY%  w25 h25, images\wholestar.png
Gui, add, picture, xm+660 ym+%BOTTOMSTARY%  w25 h25, images\wholestar.png
Gui, add, picture, xm+685 ym+%BOTTOMSTARY%  w25 h25, images\wholestar.png
Gui, add, picture, xm+710 ym+%BOTTOMSTARY%  w25 h25, images\wholestar.png
Gui, add, picture, xm+735 ym+%BOTTOMSTARY%  w25 h25, images\wholestar.png

Gui, add, picture, xm+850 ym+%BOTTOMSTARY%  w25 h25, images\wholestar.png
Gui, add, picture, xm+875 ym+%BOTTOMSTARY%  w25 h25, images\wholestar.png
Gui, add, picture, xm+900 ym+%BOTTOMSTARY%  w25 h25, images\wholestar.png
Gui, add, picture, xm+925 ym+%BOTTOMSTARY%  w25 h25, images\wholestar.png
Gui, add, picture, xm+950 ym+%BOTTOMSTARY%  w25 h25, images\wholestar.png
Gui, add, picture, xm+975 ym+%BOTTOMSTARY%  w25 h25, images\wholestar.png
Gui, add, picture, xm+1000 ym+%BOTTOMSTARY% w13 h25, images\halfstar.png
;

;.5,1.5,2.5,3.5 positions
Gui, add, picture, xm+30 ym+%BOTTOMSTARY%   w13 h25, images\halfstar.png

Gui, add, picture, xm+155 ym+%BOTTOMSTARY%  w25 h25, images\wholestar.png
Gui, add, picture, xm+180 ym+%BOTTOMSTARY%  w13 h25, images\halfstar.png

Gui, add, picture, xm+280 ym+%BOTTOMSTARY%  w25 h25, images\wholestar.png
Gui, add, picture, xm+305 ym+%BOTTOMSTARY%  w25 h25, images\wholestar.png
Gui, add, picture, xm+330 ym+%BOTTOMSTARY%  w13 h25, images\halfstar.png

Gui, add, picture, xm+430 ym+%BOTTOMSTARY%  w25 h25, images\wholestar.png
Gui, add, picture, xm+455 ym+%BOTTOMSTARY%  w25 h25, images\wholestar.png
Gui, add, picture, xm+480 ym+%BOTTOMSTARY%  w25 h25, images\wholestar.png
Gui, add, picture, xm+505 ym+%BOTTOMSTARY%  w13 h25, images\halfstar.png


;CurrentChampXP
Gui, add , Edit, limit6 vCurrentChampXPString gSubmitCurrentChampXPString xm y405 w70 
Gui, add , DropDownList, xm+75 y405 w65  vTargetChamplvl gSubmitTargetChamplvl, 1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30||31|32|33|34|35|36|37|38|39|40|41|42|43|44|45|46|47|48|49|50

;Adventures to win
Gui, add , Edit, vhalfstar         xm-15  ym+%BOTTOMRUNY%  w77 ReadOnly
Gui, add , Edit, vonestar          xm+62  ym+%BOTTOMRUNY%  w78 ReadOnly
Gui, add , Edit, voneandhalfstar   xm+140 ym+%BOTTOMRUNY%  w70 ReadOnly
Gui, add , Edit, vtwostar          xm+210 ym+%BOTTOMRUNY%  w70 ReadOnly
Gui, add , Edit, vtwoandhalfstar   xm+280 ym+%BOTTOMRUNY%  w70 ReadOnly
Gui, add , Edit, vthreestar        xm+350 ym+%BOTTOMRUNY%  w75 ReadOnly
Gui, add , Edit, vthreeandhalfstar xm+425 ym+%BOTTOMRUNY%  w100 ReadOnly
Gui, add , Edit, vfourstar         xm+525 ym+%BOTTOMRUNY%  w100 ReadOnly
Gui, add , Edit, vLissStar         xm+640 ym+%BOTTOMRUNY%  w100 ReadOnly
Gui, add , Edit, vfivestar         xm+750 ym+%BOTTOMRUNY%  w100 ReadOnly
Gui, add , Edit, vnightmarestar    xm+890 ym+%BOTTOMRUNY%  w100 ReadOnly

;Legends XP part
Gui, add , Edit, limit5 vCurrentLegendXPString gSubmitCurrentLegendXPString xm+778 y350 w70 h28
Gui, add , DropDownList, xm+850  y350 w65  vCurrentLegendlvl gSubmitCurrentLegendlvl , 1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33|35|36|37|38|39|40|41|42|43|44|45|46|47|48|49|50||51|52|53|54|55|56|57|58|59|60|61|62|63|64|65|66|67|68|69|70|71|71|72|73|74|75|76|77|78|79|80
Gui, add , DropDownList, xm+850  y380 w65  vTargetLegendlvl  gSubmitTargetLegendlvl  , 1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33|35|36|37|38|39|40|41|42|43|44|45|46|47|48|49|50|51|52|53|54|55|56|57|58|59|60|61|62|63|64|65|66|67|68|69|70|71|71|72|73|74|75|76|77|78|79|80||
Gui, add , Edit, vamountsofweeks xm+723 y380 w125 h28 ReadOnly, Weeks 

Gui, -AlwaysOntop

;Base delay text box
Gui, Color, E1E1E1

Gui, Show, w1024 h512, Path of Champions XP Calculator

;--------------------------------------------------------------------------------------------------
; Label Functions for Champ XP 
;--------------------------------------------------------------------------------------------------
SubmitCurrentChampXPString:
	Gui,+OwnDialogs
	Gui,Submit,NoHide
	

	if(CurrentChampXPString>552670)
	{
		CurrentChampXPString := 552670
		GuiControl,Text, CurrentChampXPString, %CurrentChampXPString%
	}
	
	UpdateRuns()
	
	;if input is max, 0, or null then clear lines
	ClearRuns()
	
	if(AmountofAdventures<0)
	{
		ForceZero()		
	}
	

return

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
		GuiControl,Text, fourstar, 0
		GuiControl,Text, Lissstar, 0
		GuiControl,Text, fivestar, 0
		GuiControl,Text, nightmarestar, 0
		
		return
}

ClearRuns()
{
	global
	
	if(CurrentChampXPString = "" || CurrentChampXPString >= 552670 || CurrentChampXPString = 0)
	{
		GuiControl,Text, halfstar, 0
		GuiControl,Text, onestar,  0
		GuiControl,Text, oneandhalfstar, 0 
		GuiControl,Text, twostar,  0
		GuiControl,Text, twoandhalfstar, 0
		GuiControl,Text, threestar, 0
		GuiControl,Text, threeandhalfstar, 0
		GuiControl,Text, fourstar, 0
		GuiControl,Text, Lissstar, 0
		GuiControl,Text, fivestar, 0
		GuiControl,Text, nightmarestar, 0
	}
		
	return
}

UpdateRuns()
{
	global
	
		
	;.5*---------------------------------------------------------------------------------------

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
	
	;1*---------------------------------------------------------------------------------------
	
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
	
	;1.5*---------------------------------------------------------------------------------------
	
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
	
	
	;2*---------------------------------------------------------------------------------------

	
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
	
	
	;2.5*--------------------------------------------------------------------------------------
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
	
	;3*--------------------------------------------------------------------------------------------
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
	;3.5*------------------------------------------------------------------------------------------
	ctr := 0
	
	frac_adv := mod( (ChampXPList[TargetChamplvl] - CurrentChampXPString),StarXP[7])
	;MsgBox % frac_adv
	while frac_adv>GalioXP[++ctr] && ctr<9
	{}	
	
	AmountofAdventures := floor((ChampXPList[TargetChamplvl] - CurrentChampXPString) / StarXP[7])
	GuiControl,Text, threeandhalfstar, %AmountofAdventures%+%ctr%/9
	
	if(ctr = 9)
	{
	AmountofAdventures++
	GuiControl,Text, threeandhalfstar, %AmountofAdventures%
	}
	
	;4*-------------------------------------------------------------
	ctr := 0
	
	frac_adv := mod( (ChampXPList[TargetChamplvl] - CurrentChampXPString),StarXP[8])
	;MsgBox % frac_adv	
	
	while frac_adv>ASolXP[++ctr] && ctr<12
	{}
	
	AmountofAdventures := floor( (ChampXPList[TargetChamplvl] - CurrentChampXPString) / StarXP[8] )
	GuiControl,Text, fourstar, %AmountofAdventures%+%ctr%/12
	
	if(ctr = 12)
	{
	AmountofAdventures++
	GuiControl,Text, fourstar, %AmountofAdventures%
	}
	;Liss--------------------------------------------------------------------------------------------
	ctr := 0
	
	frac_adv := mod( (ChampXPList[TargetChamplvl] - CurrentChampXPString),StarXP[9])
	;MsgBox % frac_adv
	while frac_adv>LissXP [++ctr] && ctr<7
	{}	
	
	AmountofAdventures := floor((ChampXPList[TargetChamplvl] - CurrentChampXPString) / StarXP[9])
	GuiControl,Text, Lissstar, %AmountofAdventures%+%ctr%/7
	
	if(ctr = 7)
	{
	AmountofAdventures++
	GuiControl,Text, Lissstar, %AmountofAdventures%
	}
	;5-------------------------------------------------------------
	ctr := 0
	
	frac_adv := mod( (ChampXPList[TargetChamplvl] - CurrentChampXPString),StarXP[10])
	;MsgBox % frac_adv
	while frac_adv>fivestarXP[++ctr] && ctr<7
	{}	
	
	AmountofAdventures := floor((ChampXPList[TargetChamplvl] - CurrentChampXPString) / StarXP[10])
	GuiControl,Text, fivestar, %AmountofAdventures%+%ctr%/7
	
	if(ctr = 7)
	{
	AmountofAdventures++
	GuiControl,Text, fivestar, %AmountofAdventures%
	}
	;6 nightmare-------------------------------------------------------------
	ctr := 0
	
	frac_adv := mod( (ChampXPList[TargetChamplvl] - CurrentChampXPString),StarXP[11])
	;MsgBox % frac_adv
	while frac_adv>sixnightmareXP[++ctr] && ctr<7
	{}	
	
	AmountofAdventures := floor((ChampXPList[TargetChamplvl] - CurrentChampXPString) / StarXP[11])
	GuiControl,Text, nightmarestar, %AmountofAdventures%+%ctr%/7
	
	if(ctr = 7)
	{
	AmountofAdventures++
	GuiControl,Text, nightmarestar, %AmountofAdventures%
	}
	
return
}	


WM_CHAR(wParam, lParam)
{	
	;prevent non-numbers
	If(A_GuiControl = "CurrentChampXPString" and !RegExMatch(Chr(wParam), "^[0-9]*$")) ;
	{
		Return false
	}
}

OnMessage(0x102, "WM_CHAR")
return	


^x::ExitApp