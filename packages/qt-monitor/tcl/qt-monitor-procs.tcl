# /packages/qt-monitor/tcl/qt-monitor-procs.tcl

ad_library {

    Utility functions for Qonteo Monitor package

    @author Iuri de Araujo (iuri@iurix.com)
    @creation-date Mar 2nd 2021

}


namespace eval qt {}
namespace eval qt::monitor {}
namespace eval qt::monitor::resource {}

ad_proc -public qt::monitor::resource::check_availability {} {
    It select resources, which haven't ben updated and sends notificxation to staff
} {
    
    ns_log Notice "Running TCL ad_proc qt::monitor::resorce::check_availability"

    set to_addr [parameter::get_global_value -package_key qt-monitor -parameter EmailRecipientAlerts -default "info@qonteo.com"]

    
    db_foreach select_resources {
	SELECT resource, last_modified FROM qt_uptime_resources WHERE status = TRUE AND last_modified < now() - INTERVAL  '10 minutes'
    } {
	
	if { [catch {
	    acs_mail_lite::send -send_immediately -to_addr $to_addr -from_addr postmaster@qonteo.com -reply_to postmaster@qonteo.com -subject "Notification Alert! $resource has been offline since $last_modified!" -body "Notification Alert! $resource has been offline since $last_modified!" -mime_type "text/html" } errmsg] } {
	    ns_log Notice "ERROR SENDING EMAIL $errmsg"
	    set result "\{\"result\": false\}" 
	}
    }
}
