ad_page_contract {
    Exports and returns csv file to the backend

} {
    {type:notnull}
    {format:notnull}
    {interval ""}
    {date_from ""}
    {date_to ""}
    {template:optional}
}

ns_log Notice "Running TCL script export.tcl"


switch $type {
    "v" {
	switch $format {
	    "csv" {
		qt::dashboard::vehicle::export_csv \
		    -interval $interval \
		    -date_from $date_from \
		    -date_to $date_to
	    }
	    "pdf" {
		set content [ns_getcontent -as_file false]
		ns_log Notice "CONTENT \n $content"
		
		set filename [text_templates::create_pdf_from_html -html_content $content]
		ns_log Notice "FILENAME $filename"
		
		set oh [ns_conn outputheaders]
		ns_set put $oh Content-Disposition "attachment; filename=$filename"
		ns_return 200 text/pdf [open $filename r]
		
	    }
	    
	}
    }
    "p" {  }
}




#set result ""
#ns_respond -status 200 -type "application/json" -string $result
ad_script_abort





