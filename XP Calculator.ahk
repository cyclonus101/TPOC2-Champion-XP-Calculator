#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#SingleInstance, force

;--------------------------------------------------------------------------------------------------
; Lookup Table Stuff
;--------------------------------------------------------------------------------------------------

;XP given for completing an adventure from half star to 4 star
;weekly 3.5 = 3015, weekly 4* = 3200, weekly 4.5*=4470
StarXP       := [100,305,605,985,1425,1925,3100,4505]
;Amount of XP for legend level it takes per level from 1 to 30                                                                                                                       31     32    33         35                            40                            45                             50
LegendXP     := [1000,2000,2500,3500,4000,4500,5000,5500,6000,7000,8000,9000,10000,11000,12000,13000,15000,17000,19000,21000,23000,25000,27000,29000,31000,33000,35000,37000,39000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000,30000]
;Amount of XP for champ level it takes per level from 1 to 30
ChampXPList  := [0,50,150,300,500,800,1250,1750,2310,2980,3780,4710,5780,6990,8350,9870,11560,13420,15460,17680,20090,22700,25510,28530,31760,35210,38880,42780,46920,51290]
                ;1   2    3    4    5    6     7	  8    9	  10   11	 12	   13	 14	   15	16	    17	  18	  19	 20	   21	  22	 23	   24		25	  26     27     28      29    30     31      32    33     34     35     36     37    38      39     40     41     42      43     44     45    46      47    48      49     50
LegendXPList := [0,1000,3000,5500,9000,13000,17500,22500,28000,34000,41000,49000,58000,68000,79000,91000,104000,119000,136000,155000,176000,199000,224000,251000,280000,311000,344000,379000,416000,455000,485000,515000,545000,575000,605000,635000,665000,695000,725000,755000,785000,815000,845000,875000,905000,935000,965000,995000,1025000,1055000]

;used to do some calculations
frac_adv     := 0
ctr          := 0

;lookup table for XP per battle won on an adventure
halfstarXP       := [20,40,60,100]
;7 Battle XP for 1.5
onestarXP        := [30, 60, 155, 200, 230, 260, 305]
oneandstarXP     := [60, 120, 305, 395, 455, 515, 605]

;7 Battle XP
twostarXP        := [25, 50,395, 540, 665, 790, 985]
twoandstarXP     := [35, 70,565, 780, 960,1140,1425]
threestarXP	 := [50,100,770,1060,1300,1540,1925]
;9+12 Battle XP
GalioXP          := [75,150,615, 965,1315,1780,2130,2480,3100]
ASolXP           := [95,190,285, 700,2015,2280,2545,2960,3225,3490,3755,4505]

;for 1*,1.5*
sevenbattleadventureratiolowstar := [0.1,0.2,0.5082,0.657,0.755,0.853,1]

;for 2*,2.5*,3*
sevenbattleadventureratio := [.025,.05,.4,.548,.675,.8,1]


weekly3halfXP    := [75,150,1030,1595,2035,2395,3015]
weekly4xp        := [95,190,1505,1835,2200,2545,3200]
weekly4halfXP    := [110,220,1785,2455,3015,3575,4470]

CurrentChampXP	    :=0
TargetChamplvl      :=30

MAX_XP:= 51290

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
Gui, Add, Picture, x0 y0, images\labsbackground2.png
Gui, Font, Times New Roman, s30, cwhite

;add star picture locations
Gui, add, picture, xm+90  ym  w25 h25, images\wholestar.png
Gui, add, picture, xm+220 ym  w25 h25, images\wholestar.png
Gui, add, picture, xm+245 ym  w25 h25, images\wholestar.png
Gui, add, picture, xm+350 ym  w25 h25, images\wholestar.png
Gui, add, picture, xm+375 ym  w25 h25, images\wholestar.png
Gui, add, picture, xm+400 ym  w25 h25, images\wholestar.png
Gui, add, picture, xm+525 ym  w25 h25, images\wholestar.png
Gui, add, picture, xm+550 ym  w25 h25, images\wholestar.png
Gui, add, picture, xm+575 ym  w25 h25, images\wholestar.png
Gui, add, picture, xm+600 ym  w25 h25, images\wholestar.png

;.5,1.5,2.5,3.5 positions
Gui, add, picture, xm+30 ym   w13 h25, images\halfstar.png

Gui, add, picture, xm+155 ym  w25 h25, images\wholestar.png
Gui, add, picture, xm+180 ym  w13 h25, images\halfstar.png

Gui, add, picture, xm+280 ym  w25 h25, images\wholestar.png
Gui, add, picture, xm+305 ym  w25 h25, images\wholestar.png
Gui, add, picture, xm+330 ym  w13 h25, images\halfstar.png

Gui, add, picture, xm+430 ym  w25 h25, images\wholestar.png
Gui, add, picture, xm+455 ym  w25 h25, images\wholestar.png
Gui, add, picture, xm+480 ym  w25 h25, images\wholestar.png
Gui, add, picture, xm+505 ym  w13 h25, images\halfstar.png


;CurrentChampXP
Gui, add , Edit, limit5 vCurrentChampXPString gSubmitCurrentChampXPString xm y85 w70 
Gui, add , DropDownList, xm+75 y85 w65  vTargetChamplvl gSubmitTargetChamplvl, 1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30||

;Adventures to win
Gui, add , Edit, vhalfstar         xm-15  y35  w77 ReadOnly
Gui, add , Edit, vonestar          xm+62  y35  w78 ReadOnly
Gui, add , Edit, voneandhalfstar   xm+140 y35  w70 ReadOnly
Gui, add , Edit, vtwostar          xm+210 y35  w70 ReadOnly
Gui, add , Edit, vtwoandhalfstar   xm+280 y35  w70 ReadOnly
Gui, add , Edit, vthreestar        xm+350 y35  w75 ReadOnly
Gui, add , Edit, vthreeandhalfstar xm+425 y35  w100 ReadOnly
Gui, add , Edit, vfourstar         xm+525 y35  w100 ReadOnly

;Legends XP part
Gui, add , Edit, limit5 vCurrentLegendXPString gSubmitCurrentLegendXPString xm+370 y225 w70 
Gui, add , DropDownList, xm+442  y225 w65  vCurrentLegendlvl gSubmitCurrentLegendlvl , 1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30||31|32|33|34|35|36|37|38|39|40|41|42|43|44|45|46|47|48|49
Gui, add , DropDownList, xm+509  y225 w65  vTargetLegendlvl  gSubmitTargetLegendlvl  , 1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33|34|35|36|37|38|39|40|41|42|43|44|45|46|47|48|49|50||
Gui, add , Edit, vamountsofweeks xm+370 y265 w125 ReadOnly, Weeks

Gui, -AlwaysOntop

;Base delay text box
Gui, Color, E1E1E1

Gui, Show, w649 h426, Path of Champions XP Calculator

;--------------------------------------------------------------------------------------------------
; Label Functions for Champ XP 
;--------------------------------------------------------------------------------------------------
SubmitCurrentChampXPString:
	Gui,+OwnDialogs
	Gui,Submit,NoHide
	
	if(CurrentChampXPString>51290)
	{
		CurrentChampXPString := 51290
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
	
		
	if(CurrentChampXPString>51290)
	{
		CurrentChampXPString := 51290
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
	
	WeekstoLegends := (LegendXPList[TargetLegendlvl] - CurrentLegendXPString - LegendXPList[CurrentLegendlvl])  / 16000
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
	WeekstoLegends := (LegendXPList[TargetLegendlvl] - CurrentLegendXPString - LegendXPList[CurrentLegendlvl])  / 16000
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
		WeekstoLegends := (LegendXPList[TargetLegendlvl] - CurrentLegendXPString - LegendXPList[CurrentLegendlvl])  / 16000
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
		
		return
}

ClearRuns()
{
	global
	
	if(CurrentChampXPString = "")
	{
		GuiControl,Text, halfstar, 
		GuiControl,Text, onestar, 
		GuiControl,Text, oneandhalfstar, 
		GuiControl,Text, twostar, 
		GuiControl,Text, twoandhalfstar, 
		GuiControl,Text, threestar, 
		GuiControl,Text, threeandhalfstar, 
		GuiControl,Text, fourstar, 
	}
	
	if(CurrentChampXPString = 51290 || CurrentChampXPString = 0)
	{
		GuiControl,Text, halfstar, 0
		GuiControl,Text, onestar, 0
		GuiControl,Text, oneandhalfstar, 0
		GuiControl,Text, twostar, 0
		GuiControl,Text, twoandhalfstar, 0
		GuiControl,Text, threestar, 0
		GuiControl,Text, threeandhalfstar, 0
		GuiControl,Text, fourstar, 0
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
	;---------------------------------------------------------------
	
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
