
ns_log Notice "Running TCL script export.tcl"
# Validate and Authenticate JWT 
qt::rest::jwt::validation_p



if {[ns_conn method] eq "POST"} {
    package req json
    set dict [json::json2dict [ns_getcontent -as_file false]]
    array set arr $dict
        
    if { [array exists arr] && [info exists arr(type)] && [info exists arr(format)]  } {
	lang::user::set_locale "es_ES"

	switch $arr(format) {
	    "csv" {
		if {[info exists arr(interval)] } {
		    switch $arr(type) {
			"v" {
			    if {[info exists arr(date_from)] && [info exists arr(date_to)] } {
				qt::dashboard::vehicle::export_csv \
				    -interval $arr(interval) \
				    -date_from $arr(date_from) \
				    -date_to $arr(date_to)
			    } else {
				qt::dashboard::vehicle::export_csv \
				    -interval $arr(interval)
				}			    
			}					    
			"p" {
			    if {[info exists arr(date_from)] && [info exists arr(date_to)] } {
				qt::dashboard::person::export_csv \
				    -interval $arr(interval) \
				    -date_from $arr(date_from) \
				    -date_to $arr(date_to)
			    } else {
				qt::dashboard::person::export_csv \
				    -interval $arr(interval) 
			    }			
			}
		    }
		}
	    }	    
	    "pdf" {
		# set content [ns_getcontent -as_file false]
		# ns_log Notice "CONTENT \n $content"			
		if { [info exists arr(template)] } {
		    set filename [text_templates::create_pdf_from_html -html_content [ad_convert_to_html -html_p t "$arr(template)"]]		    
		    ns_respond -status 200 \
			-type application/pdf \
			-length [file size $filename] \
			-file $filename 
		}
	    }
	    
	}
    }
    
    
    
    ns_respond -status 401 -type "text/plain" -string "401 Unauthorized! Something is wrong inthe input request. Please, review the request input."
    
} else {
    #ad_return_complaint 1 "unsupported HTTP method: [ns_conn method]"
    ns_respond -status 405 -type "text/plain" -string "Method Not Allowed"

}


ad_script_abort





