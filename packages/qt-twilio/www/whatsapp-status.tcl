# /packages/qt-twilio/www/whatsapp-status.tcl
ad_page_contract {} {
    {EventType ""}
    {SmsSid ""}
    {SmsStatus ""}
    {MessageStatus ""}
    {ChannelToAddress ""}
    {To ""}
    {ChannelPrefix ""}
    {MessageSid ""}
    {AccountSid ""}
    {From ""}
    {ApiVersion ""}
    {ChannelInstallSid ""}
}

ns_log Notice "Running TCL script # /packages/qt-twilio/www/whatsapp-status.tcl"

set header [ns_conn header]
#ns_log Notice "HEADER \n $header"
set h [ns_set size $header]
#ns_log Notice "HEADERS $h"
set req [ns_set array $header]
ns_log Notice "$req"

set content  [ns_getcontent -as_file false]
ns_log Notice "COENTNT $content"




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





ns_respond -status 200 -type "text/html" -string ""
ad_script_abort
