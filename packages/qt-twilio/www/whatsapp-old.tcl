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


set package_id [apm_package_id_from_key qt-twilio]

if {![db_0or1row item_exists {
    SELECT item_id FROM cr_items WHERE name = :name AND parent_id = :package_id
}]} {	    		

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

    
    db_transaction {

	set name 
	
	set item_id [content::item::new \
			 -parent_id $package_id \
			 -creation_user $creation_user \
			 -package_id $package_id \
			 -name $name \
			 -title $plate \
			 -description $description \
			 -storage_type "$storage_type" \
			 -content_type $content_type \
			 -text $description \
			 -data $description \
			 -is_live "t" \
			 -mime_type "text/plain"
		    ]
    }	    	    
    
    ns_log Notice "New ITEM Vehicle Inserted $plate"
} else {
    
    db_1row item_exists {
	SELECT item_id FROM cr_items WHERE name = :name AND parent_id = :package_id
    }
    
    set revision_id [content::revision::new \
			 -item_id $item_id \
			 -creation_user $creation_user \
			 -package_id $package_id \
			 -creation_ip $creation_ip \
			 -creation_date $creation_date \
			 -title $plate \
			 -description $description \
			 -content $description \
			 -mime_type "text/plain" \
			 -publish_date $creation_date \
			 -is_live "t" \
			 -storage_type "$storage_type" \
			 -content_type $content_type]
    
    ns_log Notice "New REVISION Vehicle Inserted $plate"
    
}












# Answerig the user


if {$MessageStatus eq "delivered"} {


    



    
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
    
    
    set formvars [export_vars -url {{To "whatsapp:+5511998896571"} {From $source} {Body "Hello from Qonteo! Welcome! We're glad to read from you! \n\nPlease, select one of our options the menu bellow: \n\n 1. Support \n 2. Marketing \n 3.Commercial & Sales"}}]
    
    #ns_log Notice "SEND POST REquest - Message to Twilio API"
    #set res [util::http::post -url $url -headers $req_headers -formvars $formvars -multipart]  
   # ns_log Notice "RES2 $res"
}
    
    



ns_respond -status 200 -type "application/json" -string true
ad_script_abort
