ad_page_contract {} {
    {creation_user:integer,notnull}
}

ns_log Notice "Running TCL script whatsapp-inbound-2"

set username [parameter::get_global_value -package_key qt-twilio -parameter AccountSID -default ""]
set token [parameter::get_global_value -package_key qt-twilio -parameter AuthToken -default ""]
set source [parameter::get_global_value -package_key qt-twilio -parameter WhatsAppDefaultNumber -default ""]


set url "https://api.twilio.com/2010-04-01/Accounts/${username}/Messages.json"
#set url "https://dashboard.qonteo.com/twilio/whatsapp"

set auth_token [join [ns_base64encode ${username}:${token}] ""]

set req_headers [ns_set create]
ns_set put $req_headers Authorization "Basic $auth_token"
ns_set put $req_headers Content-Type "multipart/form-data; charset=utf-8"


db_0or1row select_messages {
    SELECT COUNT(revision_id) AS count
    FROM qt_whatsapp_msg_tx
    WHERE creation_user = :creation_user
}
    

if {$count < 6} {	
        
    if {[info exists creation_user]} {
	db_0or1row select_user_names {
	    SELECT first_names, last_name FROM cc_users WHERE user_id = :creation_user
	}
    }

    ns_log Notice "COUINT $count *"
    switch $count {
	1 {
	    
	    # First interaction
	    set body "\u00a1Hola, $first_names $last_name!\n\u00a1Te damos la bienvenida a la PROMO DE TRIDENTE!"
	    set formvars [export_vars -url {{To "whatsapp:+5511998896571"} {From $source} {Body $body}}]
	    set res [util::http::post -url $url -headers $req_headers -formvars $formvars -multipart]  
	    ns_log Notice "RES $res"
	    
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
