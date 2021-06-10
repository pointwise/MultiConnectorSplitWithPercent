#############################################################################
#
# (C) 2021 Cadence Design Systems, Inc. All rights reserved worldwide.
#
# This sample script is not supported by Cadence Design Systems, Inc.
# It is provided freely for demonstration purposes only.
# SEE THE WARRANTY DISCLAIMER AT THE BOTTOM OF THIS FILE.
#
#############################################################################

###############################################################################
##
## Multi_Connector_Split_wPercent.glf
##
## Script with Tk interface to split multiple connectors at once
##
###############################################################################

package require PWI_Glyph 2

pw::Script loadTk


############################################################################
# showTitle: add a title label
############################################################################
proc showTitle { f } {
  pack [frame $f.title] -side top -expand FALSE -fill x
  pack [label $f.title.label -text "Split Connectors" -justify center] \
    -side top -fill y -pady 5
  pack [frame $f.title.hr -height 2 -relief sunken -borderwidth 1] \
    -side top -fill x

  set font [$f.title.label cget -font]
  set fontFamily [font actual $font -family]
  set fontSize [font actual $font -size]
  set bigLabelFont [font create -family $fontFamily -weight bold \
    -size [expr {int(1.5 * $fontSize)}]]
  $f.title.label configure -font $bigLabelFont

  wm title . "Split Connectors"
}

############################################################################
# showEndMessage: display a message and quit
############################################################################
proc showEndMessage { msg } {
  wm iconify .
  tk_messageBox -type ok -message $msg
  exit
}

############################################################################
# doSplit: split the given cons
############################################################################
proc doSplit { cons axis coord percent } {
    if {$coord == "" && $percent == ""} {
      exit
    }
    set newCons $cons
    set i 0
    foreach con $cons {
	set current_con [lindex $cons $i]
        #split the connector
        set point [list]
        if {$axis == "X"} {
	    set total [$current_con getTotalLength]
            set partial [$current_con getLength -X $coord]
	    set point [expr $partial/$total]
        }
        if {$axis == "Y"} {
            set total [$current_con getTotalLength]
            set partial [$current_con getLength -Y $coord]
	    set point [expr $partial/$total]
        }
        if {$axis == "Z"} {
            set total [$current_con getTotalLength]
            set partial [$current_con getLength -Z $coord]
	    set point [expr $partial/$total]
        }
	if {$axis == "P"} {
	    set total [$current_con getTotalLength]
	    set point [expr $percent/100.0]
	}
        set newcon($i) [$current_con split $point]
        incr i
    }
    exit
}

############################################################################
# pickCons: select connectors to split
############################################################################
proc pickCons { } {
  set conMask [pw::Display createSelectionMask -requireConnector {} \
    -blockConnector {Pole}]
  
  pw::Display selectEntities -selectionmask $conMask \
    -description "Select connector(s) to split" results
  
  set cons $results(Connectors)

  if {[llength $cons] == 0} {
    exit
  }
  return $cons
}

############################################################################
# makeWindow: make the Tk interface
############################################################################
proc makeWindow { } {
  global cons
  set con_num [llength $cons]
  set minDim -1
  set ::axis "X"
  set i 1
  if {$minDim == 2} {
      showEndMessage [join [list \
        "At least one of the connectors chosen has" \
        "a dimension of 2 and can not be split."] "\n"]
  }

  # create GUI to select the number of points.
  if {0 == $minDim} {
    set coord 2
    set msg [join [list \
    "Enter the location of split:"] "\n"]
  } else {
    set coord [expr {$minDim - 1}]
    set msg [join [list \
    "Enter the location of split:"] "\n"]
  }

  pack [frame .f]
  showTitle .f

  pack [frame .f.r] -expand true -fill x -pady 10
  pack [radiobutton .f.r.r5 -value "X" -text "X axis" -variable axis]\
    -expand false -pady 5
  pack [radiobutton .f.r.r2 -value "Y" -text "Y axis" -variable axis]\
    -expand false -pady 5
  pack [radiobutton .f.r.r3 -value "Z" -text "Z axis" -variable axis]\
    -expand false -pady 5

  pack [frame .f.t] -expand true -fill x -ipadx 50 -pady 10
  pack [label .f.t.l1 -text "Coordinate"] \
    -side left -expand true -fill both -padx 10 -pady 0
  pack [entry .f.t.l2 -width 10 -textvariable coord] \
    -side right -expand false -pady 0 -padx 10
  
  pack [frame .f.hr1 -height 2 -relief sunken -borderwidth 1] -side top -fill x
  pack [frame .f.u] -expand true -fill x -pady 10
  pack [radiobutton .f.u.r4 -value "P" -text "Split by Percent" -variable axis]\
    -side top -expand false -pady 5
  pack [label .f.u.l3 -text "Percentage"]\
    -side left -expand true -fill both -padx 15 -pady 15
  pack [entry .f.u.l4 -width 10 -textvariable percent]\
    -side right -expand false -side right -pady 5 -padx 10
  pack [frame .f.hr2 -height 2 -relief sunken -borderwidth 1] -side top -fill x
  pack [frame .f.bf] -expand true -fill x -pady 10

  pack [button .f.bf.cancel -text "Cancel" -command exit] -side right -padx 5
  pack [button .f.bf.ok -text "OK" -command {doSplit $cons $axis $coord $percent}] \
    -side right -padx 5 -pady 5


  ::tk::PlaceWindow . widget

}

set cons [pickCons]
makeWindow
tkwait window .

#############################################################################
#
# This file is licensed under the Cadence Public License Version 1.0 (the
# "License"), a copy of which is found in the included file named "LICENSE",
# and is distributed "AS IS." TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE
# LAW, CADENCE DISCLAIMS ALL WARRANTIES AND IN NO EVENT SHALL BE LIABLE TO
# ANY PARTY FOR ANY DAMAGES ARISING OUT OF OR RELATING TO USE OF THIS FILE.
# Please see the License for the full text of applicable terms.
#
#############################################################################
