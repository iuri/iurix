# /packages/qt-twilio/www/whatsapp-inbound.tcl
ad_page_contract {


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
} {
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
ns_headers 200 "multipart/form-data; charset=utf-8"



set package_id [apm_package_id_from_key qt-twilio]

if {![db_0or1row item_exists {
    SELECT item_id FROM cr_items
    WHERE name = :MessageSid
    AND parent_id = :package_id
    AND content_type = 'qt_whatsapp_msg'
}]} {
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

    
    set phonenumber [lindex [split $From ":"] 1]
    db_0or1row select_user_id {
	SELECT user_id AS creation_user
	FROM user_ext_info
	WHERE phonenumber = :phonenumber
    }
    
    
    db_0or1row select_messages {
	SELECT COUNT(revision_id) AS count
	FROM qt_whatsapp_msg_tx
	WHERE creation_user = :creation_user
    }
    
    
    
    
    if {$count eq 1} {
	if {[regexp {^([0-9]+)$} $Body] || [regexp {^([0-9]+)\,([0-9]+)$} $Body] } {
	    db_transaction {	
		
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
	} else {        	    

	    
	    qt::twilio::send_input_number_validation
	    ns_respond -status 200 -type "text/html" -string ""
	    ad_script_abort
	    
	}
    } else {

	db_transaction {
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
}

    

qt::twilio::send -creation_user $creation_user



    
ns_respond -status 200 -type "text/html" -string ""
ad_script_abort
