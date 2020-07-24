
ns_log Notice "running TCL script persons.tcl"


set status 200
set result OK
ns_respond -status $status -type "application/json" -string $result  
    ad_script_abort
