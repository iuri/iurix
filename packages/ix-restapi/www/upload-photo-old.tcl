ns_log Notice "Running TCL script user/login"

if {[ns_conn method] eq "POST"} {
    package req json


    set header [ns_conn header]
    ns_log Notice "HEADER \n $header"
    set h [ns_set size $header]
    ns_log Notice "HEADERS $h"
    set req [ns_set array $header]
    ns_log Notice "$req"
    
    set dict [json::json2dict [ns_getcontent -as_file false]]
    #
    # Do something with the dict
    #
    # ns_log Notice "DICT $dict"

    set result "ok"
    set status 200
    # doc_return 200 "application/json" $result    
    # ns_return -binary $status "application/json;" -header $headers result
    ns_respond -status $status -type "application/json" -string $result  
    ad_script_abort



} else {
    ad_return_complaint 1 "unsupported HTTP method: [ns_conn method]"
    ns_respond -status 405 -type "text/html" -string "Method Not Allowed"
    ad_script_abort
}
