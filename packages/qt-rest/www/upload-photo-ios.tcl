ad_page_contract {} {}

ns_log Notice "Running REST upload-photo"


set content [ns_getcontent -as_file false]
ns_log Notice "HCONTENT $content"

if {[ns_conn method] eq "POST"} {
	set result "ok"
	set status 200
	# doc_return 200 "application/json" $result    
	# ns_return -binary $status "application/json;" -header $headers result
	ns_respond -status $status -type "application/json" -string $result  

} else {
    ad_return_complaint 1 "unsupported HTTP method: [ns_conn method]"
    ns_respond -status 405 -type "text/html" -string "Method not allowed/supported."
}


ad_script_abort
