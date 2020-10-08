ad_page_contract {}


ns_log Notice "Running TCL script import_persons.tcl"

set fp [open "/tmp/plates.json" r]
set i 0
set line [gets $fp]
while {![eof $fp]} {
    # set line [read $fp]
    set line [gets $fp]
    ns_log Notice "LINE $i $line"

    package require json
    package require rl_json
    namespace path {::rl_json}
    set data [json get $line]

    array set arr $data
    ns_log Notice "[parray arr]"

    if {[array exists arr]} {
	
	set item_id [db_nextval "acs_object_id_seq"]	    
	set creation_user 726
	set content_type qt_vehicle
	set storage_type "text"
	set package_id [apm_package_id_from_key qt-dashboard]
	set creation_ip "178.62.211.78"
	set creation_date $arr(first_seen)
	set name $arr(id)
	set description $data
	set plate [lindex $description 3]
	




	if {![db_0or1row item_exists {
	    SELECT item_id FROM cr_items WHERE name = :name AND parent_id = :package_id
	}]} {	    		
	    db_transaction {
		set item_id [content::item::new \
				 -item_id $item_id \
				 -parent_id $package_id \
				 -creation_user $creation_user \
				 -package_id $package_id \
				 -creation_ip $creation_ip \
				 -creation_date $creation_date \
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
	    
		ns_log Notice "New ITEM Vehicle Inserted $name"
	} else {
	    
	    db_1row item_exists {
		SELECT item_id FROM cr_items WHERE name = :name AND parent_id = :package_id
	    }
	    
	 #   set revision_id [content::revision::new \
	#			 -item_id $item_id \
	#			 -creation_user $creation_user \
	#			 -package_id $package_id \
	#			 -creation_ip $creation_ip \
#	    -creation_date $creation_date \
#				 -title $plate \
#				 -description $description \
#				 -content $description \
#				 -mime_type "text/plain" \
#				 -publish_date $creation_date \
#				 -is_live "t" \
#				 -storage_type "$storage_type" \
#				 -content_type $content_type]
	    
#	    ns_log Notice "New REVISION Vehicle Inserted $name"
	    
	}	     
    }
    
    
    
    incr i
}

close $fp
