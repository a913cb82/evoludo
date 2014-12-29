#============================================
#SIMULATION SETTINGS
#============================================
#nrg-usage		- energy used when each action command fail or success
#mutation		- original chance (%), and mut chance for insertion, deletion and modification (add up to 100)
#atmos-nrg		- added to when action commands done
#s-nrg			- starting org nrg
#simx, simy		- num cells on each side of universe
#csize			- size of each cell
package require Tk
#every infotime steps org is saved and info it printed on screen
set infotime 50000
set simon -1
set ns 0
#1 to redraw every step, 0 to not
set redraw 1
#Birth and death logs
set born 0
set dead 0

set col(0) #FFFFFF		;#background colour

set simname SimName

set numorgrec1 99
set numorgrec2 9999

set startorg ".txt"
#ACTION NRG usage
set nrgusagefMOV	3
set nrgusagesMOV	5

set nrgusageROT		2

set nrgusagefCPY	5
set nrgusagesCPY	8

set nrgusagefBYT	5
set nrgusagesBYT	5

set nrgusageSYN		2

#SYN & BYT EFFECTIVENESS
set SYNabs 3
set BYTabs 10000
set plantnrg 1000	;#plants pasted with this nrg, taken from atmos

#MUTATION CHANCES
set mutchance 0.05
set DELchance 35
set MODchance 40
set INSchance 25
set maxmut 50

#ATMOS AND ORG STARTING NRG
set atmos 0
set snrg 100000	;#starting org energy

#SIM SIZE AND CELL SIZE(PIXELS)
set simx 63
set simy 63
set csize 7

set numorg 0
set stacksize 20
set liveorg 1
set liveorg [lreplace $liveorg 0 end]
set liveplant 1
set liveplant [lreplace $liveplant 0 end]
set drawlst 1
set drawlst [lreplace $drawlst 0 end]

for {set a 0} {$a<($simx*$simy)} {incr a} {
	lappend cells 0
}
#============================================
#lcount
#============================================
proc lcount list {
	foreach x $list {lappend arr($x) {}}
	set res {}
	foreach name [array names arr] {
		lappend res [list $name [llength $arr($name)]]
	}
	return $res
}
#============================================
#GRAPHICAL DISPLAY
#============================================
#Setting up buttoms etc
frame .toparea
grid .toparea -in . -row 1 -column 1

frame .leftarea
grid .leftarea -in .toparea -row 1 -column 1

frame .rightarea
grid .rightarea -in .toparea -row 1 -column 2

#Top-left
#=========
entry .mutc -textvariable mutchance
label .mutcl -text "Mut chance:"
entry .mmut -textvariable maxmut
label .mmutl -text "Max mut:"
entry .delc -textvariable DELchance
label .delcl -text "Del chance:"
entry .modc -textvariable MODchance
label .modcl -text "Mod chance:"
entry .insc -textvariable INSchance
label .inscl -text "Ins chance:"

grid .mutcl -in .leftarea -row 1 -column 1 -sticky nsew
grid .mmutl -in .leftarea -row 1 -column 2 -sticky nsew
grid .mutc -in .leftarea -row 2 -column 1 -sticky nsew
grid .mmut -in .leftarea -row 2 -column 2 -sticky nsew


grid .delcl -in .leftarea -row 3 -column 1 -sticky nsew
grid .modcl -in .leftarea -row 3 -column 2 -sticky nsew
grid .inscl -in .leftarea -row 3 -column 3 -sticky nsew
grid .delc -in .leftarea -row 4 -column 1 -sticky nsew
grid .modc -in .leftarea -row 4 -column 2 -sticky nsew
grid .insc -in .leftarea -row 4 -column 3 -sticky nsew


entry .seed -textvariable startorg
button .start -text "Start/Stop" -command "startstopbut"
button .addorg -text "Add Org" -command "addorg"
entry .sname -textvariable simname
entry .plnrg -textvariable plantnrg
entry .astme -textvariable infotime
checkbutton .rdraw -variable redraw -text Redraw

grid .seed -in .leftarea -row 5 -column 1
grid .start -in .leftarea -row 5 -column 2 -sticky w
grid .addorg -in .leftarea -row 5 -column 3 -sticky w
grid .sname -in .leftarea -row 6 -column 1
grid .plnrg -in .leftarea -row 6 -column 2
grid .astme -in .leftarea -row 6 -column 3
grid .rdraw -in .leftarea -row 7 -column 3

#Top-right
#=========
entry .orgnrg -width 10 -textvariable snrg
label .orgnrgl -text "Org energy:"

entry .atmnrg -width 10 -textvariable atmos
label .atmnrgl -text "Atmos energy:"

entry .synabs -width 5 -textvariable SYNabs
label .synabsl -text "Synth absorb:"

entry .bytabs -width 5 -textvariable BYTabs
label .bytabsl -text "Bite % absorb:"

grid .orgnrgl -in .rightarea -row 2 -column 1 -sticky e
grid .orgnrg -in .rightarea -row 2 -column 2 -sticky w
grid .atmnrgl -in .rightarea -row 3 -column 1 -sticky e
grid .atmnrg -in .rightarea -row 3 -column 2 -sticky w
grid .synabsl -in .rightarea -row 4 -column 1 -sticky e
grid .synabs -in .rightarea -row 4 -column 2 -sticky w
grid .bytabsl -in .rightarea -row 5 -column 1 -sticky e
grid .bytabs -in .rightarea -row 5 -column 2 -sticky w

label .nrguses -text "Action energy usages:"
label .sucs -text "Success:"
label .fail -text "Failed:"
label .mov -text "Move:"
label .mov2 -text "Move:"
label .cpy -text "Copy:"
label .cpy2 -text "Copy:"
label .byt -text "Bite:"
label .byt2 -text "Bite:"
label .rot -text "Rotate:"
label .syn -text "Synth:"
entry .move -width 5 -textvariable nrgusagesMOV
entry .move2 -width 5 -textvariable nrgusagefMOV
entry .cpye -width 5 -textvariable nrgusagesCPY
entry .cpye2 -width 5 -textvariable nrgusagefCPY
entry .byte -width 5 -textvariable nrgusagesBYT
entry .byte2 -width 5 -textvariable nrgusagefBYT
entry .rote -width 5 -textvariable nrgusageROT
entry .syne -width 5 -textvariable nrgusageSYN

grid .nrguses -in .rightarea -row 1 -column 3
grid .sucs -in .rightarea -row 2 -column 3 -sticky w
grid .fail -in .rightarea -row 2 -column 5 -sticky w

grid .mov -in .rightarea -row 3 -column 3 -sticky w
grid .move -in .rightarea -row 3 -column 4 -sticky e
grid .cpy -in .rightarea -row 4 -column 3 -sticky w
grid .cpye -in .rightarea -row 4 -column 4 -sticky e
grid .byt -in .rightarea -row 5 -column 3 -sticky w
grid .byte -in .rightarea -row 5 -column 4 -sticky e
grid .rot -in .rightarea -row 6 -column 3 -sticky w
grid .rote -in .rightarea -row 6 -column 4 -sticky e
grid .syn -in .rightarea -row 7 -column 3 -sticky w
grid .syne -in .rightarea -row 7 -column 4 -sticky e

grid .mov2 -in .rightarea -row 3 -column 5 -sticky w
grid .move2 -in .rightarea -row 3 -column 6 -sticky e
grid .cpy2 -in .rightarea -row 4 -column 5 -sticky w
grid .cpye2 -in .rightarea -row 4 -column 6 -sticky e
grid .byt2 -in .rightarea -row 5 -column 5 -sticky w
grid .byte2 -in .rightarea -row 5 -column 6 -sticky e
#Middle (-in . -row 2)
#======
#Canvas
#Bottom (-in . -row 3)
#======
frame .botarea
grid .botarea -in . -row 3 -column 1

label .ns -textvariable nslab
label .norg -textvariable norglab
label .brn -textvariable born
label .ded -textvariable dead

grid .ns -in .botarea -row 1 -column 1 -sticky w
grid .norg -in .botarea -row 1 -column 2 -sticky w
grid .brn -in .botarea -row 1 -column 3 -sticky w
grid .ded -in .botarea -row 1 -column 4 -sticky w

proc startstopbut {} {
	upvar simon simon
	set simon [expr {$simon*-1}]
}

#============================================
#BARRIER DRAWING
#============================================
proc mouseclick {x y} {
	upvar cells cells
	global redraw
	global simx
	global simy
	
	set item [.universe find overlapping $x $y $x $y]
	set coords [.universe coords $item]
	
	set targt 0
	set targl 0

	set l [lindex $coords 0]
	set t [lindex $coords 1]
	set r [lindex $coords 2]
	set b [lindex $coords 3]
	set numcells [llength $cells]
	set n 0
	if {$l>0 && $t>0} {
		while {$n<$numcells && $l!=$targl} {
			incr n
			set targl [lindex [.universe coords cell($n)] 0]
		}
		while {$n<$numcells && $t!=$targt} {
			incr n $simx
			set targt [lindex [.universe coords cell($n)] 1]
		}
	}
	set targcell $n
	if {$targcell>=$numcells} {set targcell 0}
	if {[lindex $cells $targcell]==0} {
		lset cells $targcell -100
		
		.universe itemconfigure $item -fill black -outline black
	}
}
proc rmouseclick {x y} {
	upvar cells cells
	global redraw
	global simx
	global simy
	
	set item [.universe find overlapping $x $y $x $y]
	set coords [.universe coords $item]
	
	set targt 0
	set targl 0

	set l [lindex $coords 0]
	set t [lindex $coords 1]
	set r [lindex $coords 2]
	set b [lindex $coords 3]
	set numcells [llength $cells]
	set n 0
	if {$l>0 && $t>0} {
		while {$n<$numcells && $l!=$targl} {
			incr n
			set targl [lindex [.universe coords cell($n)] 0]
		}
		while {$n<$numcells && $t!=$targt} {
			incr n $simx
			set targt [lindex [.universe coords cell($n)] 1]
		}
	}
	set targcell $n
	if {$targcell>=$numcells} {set targcell 0}
	if {[lindex $cells $targcell]!=0} {
		lset cells $targcell 0
		
		.universe itemconfigure $item -fill white -outline white
	}
}
#============================================
#ADDING PLANTS/ORGS TO SIM
#============================================
proc addorg {} {
	global startorg
	global stacksize
	global cells
	global snrg
	global born
	global sorgcol
	global redraw
	
	upvar numorg numorg
	set org [expr {$numorg+1}]
	
	upvar dna($org) dna
	upvar stack($org) stack
	upvar nrg($org) nrg
	upvar cellnum($org) cellnum
	upvar age($org) age
	upvar step($org) step
	upvar d($org) d
	upvar live($org) live
	upvar col($org) col
	
	upvar drawlst drawlst
	
	upvar liveorg liveorg
	
	set organism [open $startorg r]
	set contents [read $organism]
	close $organism
	set dna [split $contents]
	if {[lindex $dna end]=={}} {set dna [lreplace $dna end end]}	;#saved files often have an extra line, resulting in {} at end of dna code when loaded. This removes that error.
	
	for {set n 0} {$n<$stacksize} {incr n} {						;#stack can store stacksize elements in it
		lappend stack 0
	}
	set nrg     	$snrg
	#set cellnum [expr {(int($simy/2)*$simx)+(int($simx/2))}]		;#position in centre
	set cellnum [expr {int(rand()*[llength $cells])}]				;#position in rnd pos
	while {[lindex $cells $cellnum]>0} {set cellnum [expr {int(rand()*[llength $cells])}]}
	set age 		0
	set step 		0
	set d    		1
	set live		1
	set col 		[getcol $dna]
	lset cells $cellnum $org
	lappend liveorg $org
	set numorg [expr {$numorg+1}]
	incr born

	if {[lsearch $drawlst $cellnum]==-1} {lappend drawlst $cellnum}
}
proc addplant {} {
	global startorg
	global stacksize
	global cells
	global plantnrg
	global redraw
	
	upvar numorg numorg
	set org [expr {$numorg+1}]
	
	upvar nrg($org) nrg
	upvar cellnum($org) cellnum
	upvar col($org) col
	upvar liveplant liveplant
	upvar atmos atmos
	
	upvar drawlst drawlst
	
	set nrg $plantnrg
	set atmos [expr {$atmos-$plantnrg}]
	set col #00FF00
	
	set cellnum [expr {int(rand()*[llength $cells])}]				;#position in rnd pos
	while {[lindex $cells $cellnum]!=0} {set cellnum [expr {int(rand()*[llength $cells])}]}
	
	lset cells $cellnum $org
	lappend liveplant $org
	set numorg [expr {$numorg+1}]

	if {[lsearch $drawlst $cellnum]==-1} {lappend drawlst $cellnum}
}

#============================================
#CREATING CANVAS
#============================================
#create canvas for putting stuff on
set cx [expr {$simx*$csize}]
set cy [expr {$simy*$csize}]
canvas .universe -width $cx -height $cy -bg white
grid .universe -in . -row 2 -column 1
#create each cell
for {set n 0} {$n<[llength $cells]} {incr n} {
	set ypos [expr {int($n/$simy)}]
	set xpos [expr {($n+$simx)%$simx}]
	set t [expr {$ypos*$csize}]
	set b [expr {($ypos+1)*$csize}]
	set l [expr {$xpos*$csize}]
	set r [expr {($xpos+1)*$csize}]
	.universe create rectangle $l $t $r $b -tag cell($n) -fill white -outline white
}

#============================================
#BINDING MOUSE ACTIONS
#============================================
bind .universe <ButtonPress-1> "mouseclick %x %y"
bind .universe <B1-Motion> "mouseclick %x %y"
bind .universe <ButtonPress-3> "rmouseclick %x %y"
bind .universe <B3-Motion> "rmouseclick %x %y"
#============================================
#VARIABLES FOR EACH ORG
#============================================
#LISTS:
#======
#dna($org)			- DNA of org
#stack($org)		- datastack
#VARIABLES:
#==========
#nrg($org)		- energy of org
#cellnum($org)	- pos of org
#step($org)		- step in DNA org is on
#d($org)		- direction, 1=N, 2=E, 3=S, 4=W
#live($org)		- 1=alive, 0=dead
#col($org)		- Hex string for colour of org

#============================================
#COMMANDS
#============================================
#ACTIONS
#=======
#MOV		- move forward							(redraw target & origin cell if success)
#x ROT		- rotate org, clockwise is x=even, else anticlockwise
#x CPY		- create new org with x nrg				(redraw target cell if success)
#BYT		- take nrg from org in front			(redraw target cell if it's nrg drops to 0)
#SYN		- absorb nrg from atmos
#x msg		- set message							(not to be in V1)
#recv		- read closest org in front's message	(not to be in V1)
set MOV MOV
set ROT ROT
set CPY CPY
set BYT BYT
set SYN SYN

#THINKING
#========
#MUP		- delete top (no 0) element on stack
#MDN		- delete bottom (no 20) element on stack
#x y	ADD- x	+	y
#		SUB		-
#		DIV		/
#		MUL		*
#		LSS		<
#		MRE		>
#		EQU		==
#		MOD		% (remainder)
#		JMP	- if x!=0 then goto #y in DNA using lsearch
#		WER	- return dist to closest cell in my direction
set MUP MUP
set MDN MDN

set ADD ADD
set SUB SUB
set DIV DIV
set MUL MUL
set MOD MOD

set EQU EQU
set LSS LSS
set MRE MRE

set JMP JMP
set WER WER

#VARIABLE ACCESS

set NRG NRG	;#my energy
set ATM ATM	;#atmos energy
set AGE AGE	;#my age
set STP STP	;#step in code i'm on
set STK STK	;#copy a stack element to top

#============================================
#PROCEDURES
#============================================
proc moveup {stack} {					;#Move up all elements on stack, deleting top (number 0) element
	set n 0
	foreach x $stack {
			lset stack $n [lindex $stack [expr {$n+1}]]
			incr n
	}
	lset stack [expr {[llength $stack]-1}] 0
	return $stack
}
proc movedown {stack} {					;#Move down all elements on stack, deleting bottom (number 20) element
	for {set n [expr {[llength $stack]-1}]} {$n>0} {incr n -1} {
			lset stack $n [lindex $stack [expr {$n-1}]]
	}
	lset stack 0 0
	return $stack
}
#Work out total nrg in a sim
proc totalnrg {} {
	global liveorg
	global liveplant
	global atmos
	set totnrg $atmos
	foreach org $liveorg {
		upvar nrg($org) nrg
		set totnrg [expr {$totnrg+$nrg}]
	}
	foreach org $liveplant {
		upvar nrg($org) nrg
		set totnrg [expr {$totnrg+$nrg}]
	}
	return $totnrg
}
#Get a target cell
proc gettarg {d cellnum} {
	global simx
	global simy
	#if d=1 target=cellnum-x
	#if d=2 target=cellnum+1
	#if d=3 target=cellnum+x
	#if d=4 target=cellnum-1
	set target [expr {$d==1 ? ($cellnum-$simx): \
					  $d==2 ? ($cellnum+1)    : \
					  $d==3 ? ($cellnum+$simx): \
					  $d==4 ? ($cellnum-1)    :-100}]
	#if current cell is on side of universe and target is off universe then fail
	#uncomment to make universe a box
	#set target [expr {((($cellnum%$simx)==0) 			&& ($d==4)) || \
					   ((($cellnum%$simx)==($simx-1)) 	&& ($d==2)) \
					      ? -100 : $target}]
	
	#if current cell is on side of universe loop to other side
	#uncomment to make universe infinite
	set target [expr {($cellnum%$simx==0 			&& $d==4) ? $target+$simx : \
					  ($cellnum%$simx==$simx-1 		&& $d==2) ? $target-$simx : \
					  ($cellnum<$simx 				&& $d==1) ? $target+$simx*$simy : \
					  ($cellnum>=$simx*($simy-1)	&& $d==3) ? $target-$simx*$simy : $target}]
	return $target
}
#Mutate dna
proc mutate {dna} {
	global maxmut
	global mutchance
	global DELchance
	global MODchance
	global INSchance
	for {set n 1} {$n<$maxmut} {incr n} {
		if {rand()<$mutchance} {
			set rnd2 [expr {rand()*100}]
			set pos [expr {int(rand()*[llength $dna])}]	;#pos to be mutated
			if {$rnd2<=$DELchance} 										{set dna [DEL $dna $pos]}
			if {$rnd2>$DELchance && $rnd2<=($MODchance+$DELchance)} 	{set dna [MOD $dna $pos]}
			if {$rnd2>($MODchance+$DELchance)} 							{set dna [INS $dna $pos]}
		}
	}
	return $dna
}
proc DEL {dna pos} {
	set dna [lreplace $dna $pos $pos]
	return $dna
}
proc MOD {dna pos} {
	lset dna $pos [rndcom]
	return $dna
}
proc INS {dna pos} {
	set dna [linsert $dna $pos [rndcom]]
	return $dna
}
#Get a random command
proc rndcom {} {
	set ATVI [expr {int(rand()*4+1)}]	;#Action, thought, variable access or integer command
	if {$ATVI==1} {					;#Action command
		set rnd [expr {int(rand()*5+1)}]
		if {$rnd==1} {set command MOV}
		if {$rnd==2} {set command ROT}
		if {$rnd==3} {set command CPY}
		if {$rnd==4} {set command BYT}
		if {$rnd==5} {set command SYN}
	}
	if {$ATVI==2} {					;#Thought command
		set rnd [expr {int(rand()*12+1)}]
		if {$rnd==1}  {set command MUP}
		if {$rnd==2}  {set command MDN}
		if {$rnd==3}  {set command ADD}
		if {$rnd==4}  {set command SUB}
		if {$rnd==5}  {set command DIV}
		if {$rnd==6}  {set command MUL}
		if {$rnd==7}  {set command MOD}
		if {$rnd==8}  {set command EQU}
		if {$rnd==9}  {set command LSS}
		if {$rnd==10} {set command MRE}
		
		if {$rnd==11} {set command JMP}
		if {$rnd==12} {set command WER}
	}
	if {$ATVI==3} {					;#Variable access command
		set rnd [expr {int(rand()*5+1)}]
		if {$rnd==1} {set command NRG}
		if {$rnd==2} {set command ATM}
		if {$rnd==3} {set command AGE}
		if {$rnd==4} {set command STP}
		if {$rnd==5} {set command STK}
	}
	if {$ATVI==4} {					;#Integer command
		set rnd [expr {int(rand()*100-50)}]
		set rnd2 [expr {int(rand()*100)}]
		set command $rnd
		if {$rnd2>=90} {set command #$command}
	}
	return $command
}
#Redraw all unique cells on drawlst
proc redraw {} {
	global cells
	upvar drawlst drawlst
	set drawlst [lsort -unique $drawlst]
	foreach todraw $drawlst {
		set org [lindex $cells $todraw]
		upvar col($org) col
		if {[.universe itemcget cell($todraw) -fill]!=$col} {
			.universe itemconfigure cell($todraw) -fill $col
		}
	}
	set drawlst [lreplace 0 0 0]
}
#Works out colour org should be
proc getcol {dna} {
#Command RGB values
#MOV 3 0 2
#ROT 3 0 2
#CPY 2 0 3
#BYT 5 0 0
#SYN 0 5 0

#	 1 3 1
#MUP
#MDN
#ADD
#SUB
#DIV
#MUL
#MOD
#EQU
#LSS
#MRE
#JMP 0 1 4
#WER 0 2 3
#	 0 3 2
#NRG
#ATM
#AGE
#STP
#STK
	#count commands in dna
	set MOV 0 ; set ROT 0 ; set CPY 0 ; set BYT 0 ; set SYN 0
	set MUP 0 ; set MDN 0 ; set ADD 0 ; set SUB 0 ; set DIV 0 ; set MUL 0 ; set MOD 0 ; set EQU 0 ; set LSS 0 ; set MRE 0	;#THO commands
	set JMP 0 ; set WER 0
	set NRG 0 ; set ATM 0 ; set AGE 0 ; set STP 0 ; set STK 0																;#VAR commands
	set lstdata [lcount $dna]
	#loop will set each of above variables as no times it occurs in dna
	foreach item $lstdata {
		set comm [lindex $item 0]
		set num [lindex $item 1]
		set $comm $num
	}
	set THO [expr {$MUP+$MDN+$ADD+$SUB+$DIV+$MUL+$MOD+$EQU+$LSS+$MRE}]	;#thought commands
	set VAR [expr {$NRG+$ATM+$AGE+$STP+$STK}]							;#variable access commands
	#work out total rgb value of dna
	set r [expr {$MOV*3+$ROT*3+$CPY*2+$BYT*5+$SYN*0+$THO*1+$JMP*0+$WER*0+$VAR*0}]
	set g [expr {$MOV*0+$ROT*0+$CPY*0+$BYT*0+$SYN*5+$THO*3+$JMP*1+$WER*2+$VAR*3}]
	set b [expr {$MOV*2+$ROT*2+$CPY*3+$BYT*0+$SYN*0+$THO*1+$JMP*4+$WER*3+$VAR*2}]
	#format to decimal
	set r1 [expr 0x$r]
	set g1 [expr 0x$g]
	set b1 [expr 0x$b]
	#get total rgb value, and multiply out to make total 255
	set tcol [expr {$r1+$g1+$b1}]
	set maxcol [expr {sqrt([llength $dna])*20}]
	set factor [expr {$maxcol/$tcol}]
	#multiply out to make 255
	set r2 [expr {$r1*$factor}]
	set g2 [expr {$g1*$factor}]
	set b2 [expr {$b1*$factor}]
	#set back to hex
	set r [format %x [expr {int($r2)}]]
		if {[string length $r]<2} {set r 0$r}
		if {[string length $r]>2} {set r ff}
	set g [format %x [expr {int($g2)}]]
		if {[string length $g]<2} {set g 0$r}
		if {[string length $g]>2} {set g ff}
	set b [format %x [expr {int($b2)}]]
		if {[string length $b]<2} {set b 0$r}
		if {[string length $b]>2} {set b ff}
	
	set ncol #$r$g$b
	return $ncol
}
#============================================
#MAIN LOOP
#============================================
while {1} {
	while {$simon==1} {
		foreach org $liveplant {
			if {$nrg($org)<=0} {
				if {[lsearch $drawlst $cellnum($org)]==-1} {lappend drawlst $cellnum($org)}
				lset cells $cellnum($org) 0
				set atmos [expr {$atmos+$nrg($org)}]
				set col($org) #000000
				set nrg($org) 		0
				set lorgpos [lsearch $liveplant $org]
				set liveplant [lreplace $liveplant $lorgpos $lorgpos]
			}
		}
		foreach org $liveorg {
		#============================================
		#DEATH
		#============================================
		if {$nrg($org)<=0} {
			if {[lsearch $drawlst $cellnum($org)]==-1} {lappend drawlst $cellnum($org)}
			lset cells $cellnum($org) 0
			set stack($org) 	0
			set live($org) 		0
			set atmos [expr {$atmos+$nrg($org)}]
			set col($org) #000000
			set nrg($org) 		0
			set lorgpos [lsearch $liveorg $org]
			set liveorg [lreplace $liveorg $lorgpos $lorgpos]
			incr dead 1
		}
		#============================================
		#PLANT MAKING
		#============================================
		if {$atmos>=$plantnrg} {
			addplant
		}
			if {$live($org)==1} {
				if {[lindex $stack($org) 0]=={}} {lset stack($org) 0 0}
				lset stack($org) 0 [expr {int([lindex $stack($org) 0])}]		;#set a non-integer stack element to an integer
					#============================================
					#ACTION COMMANDS
					#============================================
				#============================================
				#MOV
				#============================================
				if {[lindex $dna($org) $step($org)]==$MOV} {
					set target [gettarg $d($org) $cellnum($org)]
					set stack($org) [movedown $stack($org)]
					#if target cell empty then move to that cell and redraw, else fail.
					if {[lindex $cells $target]==0} {
						if {[lsearch $drawlst $cellnum($org)]==-1} 	{lappend drawlst $cellnum($org)}
						if {[lsearch $drawlst $target]==-1} 		{lappend drawlst $target}
						lset cells $cellnum($org) 0
						lset cells $target $org
						lset stack($org) 0 1
						set cellnum($org) $target
						set nrg($org) [expr {$nrg($org)-$nrgusagesMOV}]
						set atmos [expr {$atmos+$nrgusagesMOV}]
					} else {
						lset stack($org) 0 0
						set nrg($org) [expr {$nrg($org)-$nrgusagefMOV}]
						set atmos [expr {$atmos+$nrgusagefMOV}]
					}
				}

				#============================================
				#ROT
				#============================================
				if {[lindex $dna($org) $step($org)]==$ROT} {
					#if top of stack is even then clockwise, else anticlockwise
					set d($org) [expr {([lindex $stack($org) 0]%2)==0 ? \
									   ($d($org)+1):($d($org)-1)}]
					#if d>4 or <1 then wrap it around
					set d($org) [expr {$d($org)<1 ? \
									   ($d($org)+4) : \
									   
									   $d($org)>4 ? \
									   ($d($org)-4) : \
									   
									   $d($org)}]
					set stack($org) [moveup $stack($org)]
					set nrg($org) [expr {$nrg($org)-$nrgusageROT}]
					set atmos [expr {$atmos+$nrgusageROT}]
				}

				#============================================
				#CPY
				#============================================
				if {[lindex $dna($org) $step($org)]==$CPY} {
					#target is opposite direction to normal
					set newd [expr {$d($org)==1 ? 3 : \
									$d($org)==2 ? 4 : \
									$d($org)==3 ? 1 : \
									$d($org)==4 ? 2 : 0}]
					set target [gettarg $newd $cellnum($org)]
					set offnrg [lindex $stack($org) 0]
					set offno [expr {$numorg+1}]
					#if offnrg>=nrg(org) then fail, or if offnrg<=0 fail
					set target [expr {(($offnrg>=$nrg($org)) || ($offnrg<=0)) ? -100 : $target}]
					#if target cell empty then produce new org there, else fail
					if {[lindex $cells $target]==0} {
						lset cells $target $offno
						lset stack($org) 0 1
						#Set up offspring
							set dna([expr {$offno}]) $dna($org)
							for {set n 0} {$n<$stacksize} {incr n} {				;#stack can store $stacksize elements in it
								lappend stack($offno) 0
							}
							set nrg($offno) 				$offnrg
							set cellnum([expr {$offno}]) 	$target
							set age($offno) 			0
							set step($offno) 			0
							set d($offno) 				[expr { $d($org)==1 ? 3: \
																$d($org)==2 ? 4: \
																$d($org)==3 ? 1:2}]
							set live($offno)			1
							set col($offno)				$col($org)
							lappend liveorg $offno
							incr born 1
							
							#Mutate offspring
							set ndna [mutate $dna($offno)]
							if {$ndna!=$dna($offno)} {set col($offno) [getcol $dna($offno)]}
							set dna($offno) $ndna
							
							if {[lsearch $drawlst $target]==-1} {lappend drawlst $target}
						
						set numorg $offno
						set nrg($org) [expr {$nrg($org)-$nrgusagesCPY-$offnrg}]
						set atmos [expr {$atmos+$nrgusagesCPY}]
					} else {
						lset stack($org) 0 0
						set nrg($org) [expr {$nrg($org)-$nrgusagefCPY}]
						set atmos [expr {$atmos+$nrgusagefCPY}]
					}
				}

				#============================================
				#BYT
				#============================================
				if {[lindex $dna($org) $step($org)]==$BYT} {
					set stack($org) [moveup $stack($org)]
					#take in BYTabs nrg, unless there's less than that in cell in front
					set target [gettarg $d($org) $cellnum($org)]
					if {[lindex $cells $target]>0} {
						set targnrg $nrg([lindex $cells $target])		;#nrg of targ cell
						#set BYTabsnrg [expr {int(($BYTabs*(rand()*0.5+0.5))/$nrg($org))}]
						set BYTabsnrg [expr {$targnrg}]
						#set BYTabsnrg [expr {$BYTabsnrg>$targnrg ? \
						#					 $targnrg : $BYTabsnrg}]	;#nrg to be taken from targ cell, either BTYabs or targnrg
						set nrg($org) [expr {$nrg($org)+$BYTabsnrg-$nrgusagesBYT}]
						set nrg([lindex $cells $target]) [expr {$targnrg-$BYTabsnrg}]
						set atmos [expr {$atmos+$nrgusagesBYT}]
						lset stack($org) 0 $BYTabsnrg
					} else {
						lset stack($org) 0 0
						set nrg($org) [expr {$nrg($org)-$nrgusagefBYT}]
						set atmos [expr {$atmos+$nrgusagefBYT}]
					}
				}

				#============================================
				#SYN
				#============================================
				if {[lindex $dna($org) $step($org)]==$SYN} {
					#take in SYNabs nrg, unless there's less than that in atmos, then fail
					set nrgtarget [expr {$SYNabs>$atmos ? $atmos : $SYNabs}]
					set nrg($org) [expr {$nrg($org)+$nrgtarget-$nrgusageSYN}]
					set atmos [expr {$atmos-$nrgtarget+$nrgusageSYN}]
				}

					#============================================
					#THINKING COMMANDS
					#============================================
				#Numeric operators
				if {[lindex $dna($org) $step($org)]==$ADD} {
					lset stack($org) 1 [expr {[lindex $stack($org) 1]+[lindex $stack($org) 0]}]
					set stack($org) [moveup $stack($org)]
				}
				if {[lindex $dna($org) $step($org)]==$SUB} {
					lset stack($org) 1 [expr {[lindex $stack($org) 1]-[lindex $stack($org) 0]}]
					set stack($org) [moveup $stack($org)]
				}
				if {[lindex $dna($org) $step($org)]==$DIV} {
					lset stack($org) 1 [expr {int([lindex $stack($org) 1]/([lindex $stack($org) 0]!=0 ? [lindex $stack($org) 0]:1))}]
					set stack($org) [moveup $stack($org)]
				}
				if {[lindex $dna($org) $step($org)]==$MUL} {
					lset stack($org) 1 [expr {[lindex $stack($org) 1]*[lindex $stack($org) 0]}]
					set stack($org) [moveup $stack($org)]
				}
				if {[lindex $dna($org) $step($org)]==$MOD} {
					lset stack($org) 1 [expr {[lindex $stack($org) 1]%([lindex $stack($org) 0]!=0 ? [lindex $stack($org) 0]:1)}]
					set stack($org) [moveup $stack($org)]
				}
				#============================================
				#Moveup and movedown
				if {[lindex $dna($org) $step($org)]==$MUP} {
					set stack($org) [moveup $stack($org)]
				}
				if {[lindex $dna($org) $step($org)]==$MDN} {
					set stack($org) [movedown $stack($org)]
				}
				#============================================
				#Compatitive operators
				if {[lindex $dna($org) $step($org)]==$EQU} {
					lset stack($org) 1 [expr {[lindex $stack($org) 1]==[lindex $stack($org) 0]}]
					set stack($org) [moveup $stack($org)]
				}
				if {[lindex $dna($org) $step($org)]==$LSS} {
					lset stack($org) 1 [expr {[lindex $stack($org) 1]<[lindex $stack($org) 0]}]
					set stack($org) [moveup $stack($org)]
				}
				if {[lindex $dna($org) $step($org)]==$MRE} {
					lset stack($org) 1 [expr {[lindex $stack($org) 1]>[lindex $stack($org) 0]}]
					set stack($org) [moveup $stack($org)]
				}
				#============================================
				#Goto
				if {[lindex $dna($org) $step($org)]==$JMP} {
					if {[lindex $stack($org) 1]!=0} {
						set pos #[lindex $stack($org) 0]
						set gotostep [lsearch $dna($org) $pos]
						set step($org) [expr {$gotostep>=0 ? $gotostep : $step($org)}]
					}
					set stack($org) [moveup $stack($org)]
					set stack($org) [moveup $stack($org)]
				}
				#============================================
				#Where
				if {[lindex $dna($org) $step($org)]==$WER} {
					set dist 1
					set target [gettarg $d($org) $cellnum($org)]
					while {[lindex $cells $target]==0} {			;#While target cell is empty, move target forwards 1 and increment dist
						set target [gettarg $d($org) $target]
						incr dist
					}
					set obj [expr {[lindex $cells $target]<0 ? 0:1}]
					set stack($org) [movedown $stack($org)]
					set stack($org) [movedown $stack($org)]
					lset stack($org) 0 $dist
					lset stack($org) 1 $obj							;#return dist and what object is, 1=organism, 0=barrier
				}
				#============================================
				#Integer
				if {[string is integer [lindex $dna($org) $step($org)]]==1} {
					set stack($org) [movedown $stack($org)]
					lset stack($org) 0 [lindex $dna($org) $step($org)]
				}
					#============================================
					#VARIABLE ACCESS
					#============================================
				if {[lindex $dna($org) $step($org)]==$NRG} {
					set stack($org) [movedown $stack($org)]
					lset stack($org) 0 $nrg($org)
				}
				if {[lindex $dna($org) $step($org)]==$ATM} {
					set stack($org) [movedown $stack($org)]
					lset stack($org) 0 [expr {int($atmos)}]
				}
				if {[lindex $dna($org) $step($org)]==$AGE} {
					set stack($org) [movedown $stack($org)]
					lset stack($org) 0 $age($org)
				}
				if {[lindex $dna($org) $step($org)]==$STP} {
					set stack($org) [movedown $stack($org)]
					lset stack($org) 0 $step($org)
				}
				#============================================
				#List access
				#============================================
				if {[lindex $dna($org) $step($org)]==$STK} {
					lset stack($org) 0 [lindex $stack($org) [lindex $stack($org) 0]]
				}
				
				incr age($org)
				incr step($org)
			}
		}
		#Save org
		if {$ns%$infotime==0} {
			set savefile [open "$simname-Step$ns Org[lindex $liveorg end].txt" w]
			puts $savefile $dna([lindex $liveorg end])
			close $savefile
			
			set numorgrec1 $numorgrec2
			set numorgrec2 [lindex $liveorg end]
		}
		
		after 1 {set sleep {}}
		tkwait variable sleep
		incr ns
		if {([llength $liveorg]==0) || ($numorgrec1==$numorgrec2)} {startstopbut}
		
		#Refresh labels
		set nslab "Step $ns"
		set norglab "[llength $liveorg] organisms"
		if {$redraw==1} {redraw}
	}
	after 1 {set sleep {}}
	tkwait variable sleep
}