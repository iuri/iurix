# /packages/qt-rest/www/persons/reports.tcl
ad_page_contract {
    API REST method to send general reports
} {
    {report_type ""}
    {channel_type ""}
    {contact_type ""}
    {gender ""}
    {age_from ""}
    {age_to ""}
    {date_from:optional}
    {date_to:optional}
}
ns_log Notice "Running TCL script persons/reports.tcl"

ns_log Notice "
    report_type $report_type \n
    channel_type $channel_type \n   
    contact_type $contact_type \n
    gender $gender \n
    age_from $age_from \n
    age_to $age_to \n"


# Validate and Authenticate JWT
qt::rest::jwt::validation_p

set creation_date [db_string select_now { SELECT date(now() - INTERVAL '5 hour') FROM dual}]
set content_type qt_face
set where_clauses ""

if {[info exists date_from]} {
    if {![catch {set t [clock scan $date_from]} errmsg]} {
	append where_clauses " AND t.creation_date::date >= :date_from::date"
    } else {
	ns_respond -status 422 -type "text/plain" -string "Unprocessable Entity! $errmsg"
	ad_script_abort    
    }
}


if {[info exists date_to]} {
    if {![catch {set t [clock scan $date_to]} errmsg]} {
	append where_clauses " AND t.creation_date::date <= :date_to::date "
    } else {
	ns_respond -status 422 -type "text/plain" -string "Unprocessable Entity! $errmsg"
	ad_script_abort    
    }
}


set result "\{\"result\": true\}" 
if { [catch { acs_mail_lite::send -send_immediately -to_addr juan@tres.pe -cc_addr iuri.sampaio@gmail.com -from_addr postmaster@qonteo.com -reply_to postmaster@qonteo.com -subject "Report SENT successfully!" -body "report HTML" -mime_type "text/html" } errmsg] } {
    ns_log Notice "ERROR SENDING EMAIL $errmsg"
    set result "\{\"result\": false\}" 
}

ns_respond -status 200 -type "application/json" -string $result
ad_script_abort
