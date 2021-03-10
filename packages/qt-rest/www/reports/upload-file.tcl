
# Validate and Authenticate JWT
qt::rest::jwt::validation_p


ns_log Notice "Running REST TCL script upload-file.tcl"

set header [ns_conn header]
ns_log Notice "HEADER \n $header"
set h [ns_set size $header]
ns_log Notice "HEADERS $h"
set req [ns_set array $header]
ns_log Notice "$req"

set tmp_file [ns_getcontent -as_file true]

ns_log Notice "FILE \n $tmp_file"

if {[ns_conn method] eq "POST"} {

    set myform [ns_getform]
    if {[string equal "" $myform]} {
	ns_log Notice "No Form was submited"
    } else {
	ns_log Notice "FORM"
	ns_set print $myform
	for {set i 0} {$i < [ns_set size $myform]} {incr i} {
	    set varname [ns_set key $myform $i]
	    set varvalue [ns_set value $myform $i]
	    ns_log Notice " $varname - $varvalue"
	}
    }
    
    
    
    
    
    
    set result "ok"
    set status 200
    # doc_return 200 "application/json" $result    
    # ns_return -binary $status "application/json;" -header $headers result
    ns_respond -status $status -type "application/json" -string $result  
    
}

ad_script_abort
