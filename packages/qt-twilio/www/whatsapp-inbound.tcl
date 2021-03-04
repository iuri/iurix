# /packages/qt-twilio/www/whatsapp-inbound.tcl
ad_page_contract {} {
    {SmsMessageSid ""}
    {NumMedia ""}
    {ProfileName ""}
    {SmsSid ""} 
    {WaId ""}
    {SmsStatus ""}
    {Body ""}
    {To ""}
    {NumSegments ""}
    {MessageSid ""}
    {AccountSid ""}
    {From ""}
    {ApiVersion ""}
}

ns_log notice "Running TCL script /packages/qt-twilio/www/whatsapp-inbound.tcl"

ns_log Notice "RECEIVE POST - Request Message from Twilio API"


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





set header [ns_conn header]
#ns_log Notice "HEADER \n $header"
set h [ns_set size $header]
#ns_log Notice "HEADERS $h"
set req [ns_set array $header]
ns_log Notice "$req"

set content  [ns_getcontent -as_file false]
ns_log Notice "COENTNT $content"




#SmsMessageSid = SMc96daf13509762f2997d5aac4561ee37
#NumMedia = 0
#ProfileName = I
#SmsSid = SMc96daf13509762f2997d5aac4561ee37
#WaId = 5511998896571
#SmsStatus = received
#Body = Hi
#To = whatsapp:+14155238886
#NumSegments = 1
#MessageSid = SMc96daf13509762f2997d5aac4561ee37
#AccountSid = ACe13c431fe7a0339882f57e87c4b4db37
#From = whatsapp:+5511998896571
#ApiVersion = 2010-04-01

set phonenumber [lindex [split $From ":"] 1]
db_0or1row select_user_id {
    SELECT user_id AS creation_user
    FROM user_ext_info WHERE phonenumber = :phonenumber
}


set package_id [apm_package_id_from_key qt-twilio]
if {![db_0or1row item_exists {
    SELECT item_id FROM cr_items
    WHERE name = :MessageSid
    AND parent_id = :package_id
    AND content_type = 'qt_whatsapp_msg'
}]} {
    
    db_transaction {
	set description [list \
			     [list SmsMessageSid $SmsMessageSid] \
			     [list NumMedia $NumMedia] \
			     [list ProfileName $ProfileName] \
			     [list SmsSid $SmsSid] \
			     [list WaId $WaId] \
			     [list SmsStatus $SmsStatus] \
			     [list Body $Body] \
			     [list To $To] \
			     [list NumSegments $NumSegments] \
			     [list MessageSid $MessageSid] \
			     [list AccountSid $AccountSid] \
			     [list From $From] \
			     [list ApiVersion $ApiVersion]]
			     
	
	set item_id [content::item::new \
			 -parent_id $package_id \
			 -creation_user $creation_user \
			 -package_id $package_id \
			 -name $MessageSid \
			 -title [util_close_html_tags $Body "50" "50" " ..." ""] \
			 -description $description \
			 -storage_type text \
			 -content_type qt_whatsapp_msg \
			 -text $description \
			 -data $description \
			 -is_live "t" \
			 -mime_type "text/plain"
		    ]
    }	    	    
}
















db_0or1row select_messages {
    SELECT COUNT(revision_id) AS count
    FROM qt_whatsapp_msg_tx
    WHERE creation_user = :creation_user
}

if {$count < 3} {
    

    
    set username [parameter::get_global_value -package_key qt-twilio -parameter AccountSID -default ""]
    set token [parameter::get_global_value -package_key qt-twilio -parameter AuthToken -default ""]
    set source [parameter::get_global_value -package_key qt-twilio -parameter WhatsAppDefaultNumber -default ""]
    
    
    set url "https://api.twilio.com/2010-04-01/Accounts/${username}/Messages.json"
    #set url "https://dashboard.qonteo.com/twilio/whatsapp"
    
    set auth_token [join [ns_base64encode ${username}:${token}] ""]
    
    set req_headers [ns_set create]
    ns_set update $req_headers Authorization "Basic $auth_token"
    ns_set update $req_headers Content-Type "multipart/form-data"
    
    set req1 [ns_set array $req_headers]
    #ns_log Notice "REQ HEADER $req1"


    if {[info exists creation_user]} {
	ns_log Notice "USERID $creation_user"
	
	db_0or1row select_user_names {
	    SELECT first_names, last_name FROM cc_users WHERE user_id = :creation_user
	}
    }
    


    

    #set body "&#161;Hola, $first_names $last_name!\n&#191;Tienes un LOTE y HORA?\n&#161;Envialo ahora!"
    #set body "¡Hola, $first_names $last_name!\n¿Tienes un LOTE y HORA?\n¡Envialo ahora!"
    set body "Hola, $first_names $last_name!\nTienes un LOTE y HORA? Envialo ahora!"
    set formvars [export_vars -url {{To "whatsapp:+5511998896571"} {From $source} {Body $body}}]
    
    #ns_log Notice "SEND POST REquest - Message to Twilio API"
    set res [util::http::post -url $url -headers $req_headers -formvars $formvars -multipart]  
    ns_log Notice "RES2 $res"
    
}




ns_respond -status 200 -type "text/html" -string ""
ad_script_abort
