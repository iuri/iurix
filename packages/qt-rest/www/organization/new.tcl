# /packages/qt-rest/www/organization/new.tcl

ns_log Notice "Running TCL script organization/new "

if {[ns_conn method] eq "POST"} {
    set header [ns_conn header]
    set header_size [ns_set size $header]
    set req [ns_set array $header]
    ns_log Notice "HEADER $header"
        set token [lindex [ns_set get $header Authorization] 1]
        ns_log Notice "TOKEN $token"

    #set content [ns_conn content]
    set content [ns_getcontent -as_file false]

    ns_log Notice "CONTENT $content"
    
    package req json
    set dict [json::json2dict [ns_getcontent -as_file false]]
    
    array set arr $dict 
    if {[array exists arr] && [array size arr] > 0} {
	
	ns_log Notice "ORG \n [parray arr]"
	
	permission::require_permission \
	    -object_id [apm_package_id_from_key "organization"] \
	    -privilege create

	db_transaction {
	    set organization_id [db_exec_plsql {
		select organization__new ( 
					  :legal_name,
					  :name,
					  :notes,
					  null,
					  :org_type_id,
					  :reg_number,
					  :email,
					  :url,
					  :user_id,
					  :peeraddr,
					  :package_id
					  );
	    }]
	    
	    db_dml do_insert_types {
		insert into organization_type_map 
		(organization_id, organization_type_id) values
		(:organization_id, :oti) 
	    }
	}
	
	append result "\{
		\"data\": \{  \},
		\"errors\":\[\],
		\"meta\": \{ 
	  	  \"copyright\": \"Copyright 2020 Qonteo\",
		  \"application\": \"Qonteo Rest API\",
		  \"version\": \"0.1d\",
		  \"id\": \"HTTP/1.1 200 HTML\",
		  \"status\": \"true\",
		  \"message\": \"New User successfully created\"
		\}  
	\}"
	    
	#doc_return 200 "application/json; access-control-allow-origin:*" $result
	# ns_return 200 "application/json;" $result
	
	set status 200
	ns_respond -status $status -type "application/json" -string $result  
	ad_script_abort
    } else {
	ad_return_complaint 1 "unsupported HTTP method: [ns_conn method]"
	ns_respond -status 406 -type "text/html" -string "No content in the payload"
	ad_script_abort
	
    }    
} else {
    ad_return_complaint 1 "unsupported HTTP method: [ns_conn method]"
    ns_respond -status 405 -type "text/html" -string "Method Not Allowed"
    ad_script_abort
}

