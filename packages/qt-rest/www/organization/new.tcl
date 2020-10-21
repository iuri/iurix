# /packages/qt-rest/www/organization/new.tcl

ns_log Notice "Running TCL script organization/new"

if {[ns_conn method] eq "POST"} {
    qt::rest::jwt::validation_p

    set header [ns_conn header]
    set token [ns_set get $header authorization]
    ns_log Notice "TOKEN $token"

    #set content [ns_conn content]
    set content [ns_getcontent -as_file false]

    ns_log Notice "CONTENT $content"
    
    package req json
    set dict [json::json2dict [ns_getcontent -as_file false]]
    ns_log Notice "DICT $dict"
    foreach {field value} $dict {
	set $field $value
    }

    if {[info exists name] && [info exists user_id]} {
	ns_log Notice "name $name | $legal_name $legal_name | reg_number $reg_number | type $type | user_id $user_id"
	
	db_transaction {
	    
	    # Mainsite node id 696	    
	    set folder [site_node::verify_folder_name \
			    -parent_node_id [ad_conn node_id] \
			    -current_node_id 696 \
			    -folder [util_text_to_url "$legal_name-$reg_number"] \
			    -instance_name $name]

	    ns_log Notice "FOLDER $folder"
	    if { $folder eq "" } {
		ns_respond -status 422 -type "application/json" -string "This name is alredy taken!"  
		ad_script_abort
	    }

	    ns_log Notice "ADD SUBSITE"
	    # Create and mount new subsite
	    set new_package_id [site_node::instantiate_and_mount \
				    -parent_node_id 696 \
				    -node_name $folder \
				    -package_name $name \
				    -package_key acs-subsite]
	    
	    # Set template
	    subsite::set_theme -subsite_id $new_package_id -theme default_plain
	    
	    # Set join policy
	    set group(join_policy) "needs approval"
	    set member_group_id [application_group::group_id_from_package_id -package_id $new_package_id]
	    group::update -group_id $member_group_id -array group
	    
	    # Add current user as admin
	    group::add_member \
		-no_perm_check \
		-member_state "approved" \
		-rel_type "admin_rel" \
		-group_id $member_group_id \
		-user_id $user_id
	    
	    permission::set_not_inherit -object_id $new_package_id	   	    
	    
	    set peeraddr [ad_conn peeraddr]
	    ns_log Notice "ADD ORG $legal_name | $name | $type | $reg_number | $url | $user_id | $peeraddr | $new_package_id"
	    
	    set organization_id [db_exec_plsql insert_org {
		select organization__new ( 
					  :legal_name,
					  :name,
					  null,
					  null,
					  :type,
					  :reg_number,
					  null,
					  :url,
					  :user_id,
					  :peeraddr,
					  :new_package_id
					  );
	    }]
	    
	    db_dml do_insert_types {
		insert into organization_type_map 
		(organization_id, organization_type_id) values
		(:organization_id, :type) 
	    }

	} on_error {
	    ns_log Notice "Problem creating application. \n We got the following error message while trying to create this relation: <pre>$errmsg</pre>******"
	    ns_respond -status 422 -type "application/json" -string  "Problem Creating Application. We had a problem creating the organization."
	    ad_script_abort
	    
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
	ad_return_complaint 1 "unsupported HTTP input: [ns_conn method]"
	ns_respond -status 406 -type "text/html" -string "No content in the payload"
	ad_script_abort
	
    }    
} else {
    ad_return_complaint 1 "unsupported HTTP method: [ns_conn method]"
    ns_respond -status 405 -type "text/html" -string "Method Not Allowed"
    ad_script_abort
}

