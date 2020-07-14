ns_log Notice "Running TCL script index.tcl"

    package require json
    package require rl_json
    namespace path {::rl_json}

   
set fp [open "/var/www/iurix/packages/qt-dashboard/www/json-sample.json" r]
set i 0
while {1} {
    # set line [read $fp]
    set line [gets $fp]
    ns_log Notice "LINE $i $line"

    if {$line ne ""} {
	set l [json get [lindex $line 0]]
	ns_log Notice "JSON \n $l"
	array set arr $l
	
	ns_log Notice "[parray arr]"
	if { [lindex $arr(result) 0] eq "faces"} {
	    ns_log Notice "Import JSON"
	    # import_json -json_text $line
	}
    }
    incr i
    if {[eof $fp] } {
	close $fp
	break
    }
    
}

