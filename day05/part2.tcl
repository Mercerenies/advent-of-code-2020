#!/usr/bin/env tclsh

# Returns {row col}
proc binaryToPos {bin} {
    set row 0
    for {set i 0} {$i < 7} {incr i} {
        if {[string range $bin $i $i] == "B"} {
            set row [expr {$row + (2 ** (6 - $i))}]
        }
    }
    set col 0
    for {set i 7} {$i < 10} {incr i} {
        if {[string range $bin $i $i] == "R"} {
            set col [expr {$col + (2 ** (9 - $i))}]
        }
    }
    return [list $row $col]
}

proc posToID {pos} {
    set row [lindex $pos 0]
    set col [lindex $pos 1]
    return [expr {$row * 8 + $col}]
}

set spottedIDs [list]
for {set i 0} {$i < 1024} {incr i} {
    lappend spottedIDs false
}

set fh [open "input.txt"]
while {[gets $fh line] >= 0} {
    set pos [binaryToPos $line]
    lset spottedIDs [posToID $pos] true
}
close $fh

for {set i 1} {$i < 1023} {incr i} {
    set prev [lindex $spottedIDs [expr {$i - 1}]]
    set curr [lindex $spottedIDs $i]
    set next [lindex $spottedIDs [expr {$i + 1}]]
    if {$prev && !$curr && $next} {
        puts $i
        break
    }
}
