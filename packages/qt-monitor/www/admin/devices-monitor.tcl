ad_page_contract {}


# Retrieves a list of hosts, which are pending to authenticate and did not sent an update status (whether are turned off or disconnected, or any other reason)

db_foreach select_resources {
    SELECT resource, last_modified
    FROM qt_uptime_resources WHERE status = TRUE
    AND last_modified > now() - INTERVAL '10 minutes'
} {

    if { [catch { acs_mail_lite::send -send_immediately -to_addr iuri.sampaio@gmail.com -from_addr postmaster@qonteo.com -reply_to postmaster@qonteo.com -subject "Notification Alert! $resource has been offline since $last_modified!" -body "report HTML" -mime_type "text/html" } errmsg] } {
    ns_log Notice "ERROR SENDING EMAIL $errmsg"
	set result "\{\"result\": false\}" 
    }

}
