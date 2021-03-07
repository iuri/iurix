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

#set content  [ns_getcontent -as_file false]
#ns_log Notice "COENTNT $content"

set phonenumber [lindex [split $From ":"] 1]
db_0or1row select_user_id {
    SELECT user_id AS creation_user
    FROM user_ext_info WHERE phonenumber = :phonenumber
}


db_0or1row select_messages {
    SELECT COUNT(revision_id) AS count
    FROM qt_whatsapp_msg_tx
    WHERE creation_user = :creation_user
}
ns_log Notice "COUNT $count *****"



set package_id [apm_package_id_from_key qt-twilio]
if {![db_0or1row item_exists {
    SELECT item_id FROM cr_items
    WHERE name = :MessageSid
    AND parent_id = :package_id
    AND content_type = 'qt_whatsapp_msg'
}]} {
    
    if {$count eq 1} {
	if {[regexp {^([0-9]+)$} $Body] || [regexp {^([0-9]+)\,([0-9]+)$} $Body] } {
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
	} else {
    
	    set username [parameter::get_global_value -package_key qt-twilio -parameter AccountSID -default ""]
	    set token [parameter::get_global_value -package_key qt-twilio -parameter AuthToken -default ""]
	    set source [parameter::get_global_value -package_key qt-twilio -parameter WhatsAppDefaultNumber -default ""]
	    
	    
	    set url "https://api.twilio.com/2010-04-01/Accounts/${username}/Messages.json"
	    #set url "https://dashboard.qonteo.com/twilio/whatsapp"
	    
	    set auth_token [join [ns_base64encode ${username}:${token}] ""]
	    
	    set req_headers [ns_set create]
	    ns_set update $req_headers Authorization "Basic $auth_token"
	    ns_set update $req_headers Content-Type "multipart/form-data"
	    	    
	   	 
	    set body "Por favor, Envie solamente numeros!"
	    set formvars [export_vars -url {{To "whatsapp:+5511998896571"} {From $source} {Body $body}}]
	    set res [util::http::post -url $url -headers $req_headers -formvars $formvars -multipart]
	}
    } else {

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
}

    





    
    
db_0or1row select_messages {
    SELECT COUNT(revision_id) AS count
    FROM qt_whatsapp_msg_tx
    WHERE creation_user = :creation_user
}
    

if {$count < 6} {	
    
    set username [parameter::get_global_value -package_key qt-twilio -parameter AccountSID -default ""]
    set token [parameter::get_global_value -package_key qt-twilio -parameter AuthToken -default ""]
    set source [parameter::get_global_value -package_key qt-twilio -parameter WhatsAppDefaultNumber -default ""]
    
    
    set url "https://api.twilio.com/2010-04-01/Accounts/${username}/Messages.json"
    
    set auth_token [join [ns_base64encode ${username}:${token}] ""]
    
    set req_headers [ns_set create]
    ns_set update $req_headers Authorization "Basic $auth_token"
    ns_set update $req_headers Content-Type "multipart/form-data"
    
    if {[info exists creation_user]} {
	db_0or1row select_user_names {
	    SELECT first_names, last_name FROM cc_users WHERE user_id = :creation_user
	}
    }

    ns_log Notice "COUINT $count ***********************"
    switch $count {
	1 {
	    
	    # First interaction
	    set body "Hola, $first_names $last_name!\nTe damos la bienvenida a la PROMO DE TRIDENTE!"
	    set formvars [export_vars -url {{To "whatsapp:+5511998896571"} {From $source} {Body $body}}]
	    set res [util::http::post -url $url -headers $req_headers -formvars $formvars -multipart]  
	    
	    
	    # Second interaction 
	    set body "Cómo te enteraste de la Promo PROMO DE TRIDENTE?\n1. TV\n2. Radio\n3. Via publica\n4. Envase de Toro\n5. Redes sociales\n6. Punto de venta\n7. Recomendación de amigo\n8. Otro\nInsira uno o más numeros separado por comas. (Ej: 1,4,7)"
	    set formvars [export_vars -url {{To "whatsapp:+5511998896571"} {From $source} {Body $body}}]       
	    set res [util::http::post -url $url -headers $req_headers -formvars $formvars -multipart]  
	    
	}              
	2 {					    
	    # Second interaction
	    set body "En donde vives?"
	    set formvars [export_vars -url {{To "whatsapp:+5511998896571"} {From $source} {Body $body}}]
	    set res [util::http::post -url $url -headers $req_headers -formvars $formvars -multipart]  
	}	
        3 {
	    # Third interaction
	    set body "Decinos, como tomas tu toro?\n1. Puro, sin mezclarlo\n2. Con Soda\n3. Con hielo\n4. Con jugo\n5. Con gaseosa\n6. Con fruta\n7. Otro\nInsira uno o más numeros separado por comas. Ejemplo: 1,4,7"
	    set formvars [export_vars -url {{To "whatsapp:+5511998896571"} {From $source} {Body $body}}]
	    set res [util::http::post -url $url -headers $req_headers -formvars $formvars -multipart]  
	    
	}	
	4 {					    
	    # Fourth interaction
	    set body "Correcto, a TORO te lo tomás 🍷 como querés!!!"       
	    set formvars [export_vars -url {{To "whatsapp:+5511998896571"} {From $source} {Body $body}}]
	    set res [util::http::post -url $url -headers $req_headers -formvars $formvars -multipart]  
	    
	    
	    
	    after 2000
	    set body "Muchas gracias $first_names!\nYa registramos tus datos, y no te los vamos a volver a pedir.\n\nPara participar en la PROMO TRIDENTE, tenés que escribirnos el LOTE y la HORA que figuran en tu envase de TRIDENT."
	    set formvars [export_vars -url {{To "whatsapp:+5511998896571"} {From $source} {Body $body}}]
	    set res [util::http::post -url $url -headers $req_headers -formvars $formvars -multipart]  
	    
	    after 2000
	    set body "Más veces participás, más chances vas a tener de ganar!"
	    set formvars [export_vars -url {{To "whatsapp:+5511998896571"} {From $source} {Body $body}}]
	    set res [util::http::post -url $url -headers $req_headers -formvars $formvars -multipart]  
	    
	    after 2000
	    set body "¿Tienes un LOTE y HORA? ¡Envialo ahora!\nPor ejemplo: 4/06723 11:57"
	    set formvars [export_vars -url {{To "whatsapp:+5511998896571"} {From $source} {Body $body}}]
	    set res [util::http::post -url $url -headers $req_headers -formvars $formvars -multipart]  
	    
	}	
	5 {
	    
	    set body "Muchas gracias $first_names!\nYa estas participando por los sorteos de la PROMO TRIDENT.\n\nPodés seguir participando todos los días con nuevos LOTE y HORA de tus envases TRIDENT.\n\n¡Cuanto más veces participes, más chances vas a tener de ganar!
"
	    set formvars [export_vars -url {{To "whatsapp:+5511998896571"} {From $source} {Body $body}}]
	    set res [util::http::post -url $url -headers $req_headers -formvars $formvars -multipart]  
	    
	    
	    
	    after 2000
	    set body "Suerte!\nAl participar estás aceptando nuestras bases y condiciones, miralas en: https://www.tridentgum.com/\n"
	    
	    set formvars [export_vars -url {{To "whatsapp:+5511998896571"} {From $source} {Body $body}}]
	    set res [util::http::post -url $url -headers $req_headers -formvars $formvars -multipart]  
	    
	    
	}
    }
}



ns_respond -status 200 -type "text/html" -string ""
ad_script_abort
