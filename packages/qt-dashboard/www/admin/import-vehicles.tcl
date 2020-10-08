ad_page_contract {
    Format 1
    {"id": 2, "plate_number": "_MP354", "country_name": "Colombia", "country_symbol": "CO", "first_seen": "2020-07-11 12:45:51", "last_seen": "2020-07-11 12:45:51", "probability": 0.3, "location_name": "Test", "camera_name": "LPR 1", "direction": "UNKNOWN", "class": "Car", "plate_image": "http://178.62.211.78/plate_image_fa.php?id=2", "car_image": "http://178.62.211.78/car_image_fa.php?id=2"}
    
}
dsdsds

ns_log Notice "Running TCL script import_vehicles.tcl"

package require json

set fp [open "/tmp/plates.json" r]
set i 0
set line [gets $fp]
while {![eof $fp]} {
    # set line [read $fp]
    set line [gets $fp]
    
    set dict [json::json2dict $line]
    array set arr $dict

    set insert_p true
    
    set item_id [db_nextval "acs_object_id_seq"]	    
    set creation_user 726
    set content_type qt_vehicle
    set storage_type "text"
    set package_id [apm_package_id_from_key qt-dashboard]
    set creation_ip "181.48.187.90"
    set creation_date $arr(first_seen)
    set description $dict
    set plate $arr(plate_number)



#    if {$creation_date > "2020-09-23 10:26:41+00"} {}
	ns_log Notice "LINE $i $line"
	
	set name [util_text_to_url $plate]
	if {$plate eq "UNKNOWN"} {
	    set name "$name-$item_id"
	}
	
	if { [regexp {^([0-9]+)$} $plate] } {
	    ns_log Notice "IMPORTING VEHICLE ERROR: PLATE HAS ONLY NUMBERS NOT INSERTED"
	    set insert_p false 
	}
	
	
	ns_log Notice "
	-item_id $item_id \
	-parent_id $package_id \
	    -creation_user $creation_user \
	    -package_id $package_id \
	    -creation_ip $creation_ip \
	    -creation_date $creation_date \
	    -name $name \
	    -title $plate \
	    -description $description \
	    -storage_type $storage_type \
	    -content_type $content_type \
	    -text $description \
	    -data $description \
	    "
	
	
	
	if {$insert_p eq "true"} {
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
				     -mime_type "text/plain"]
		    
		    db_transaction {
			db_dml update_revision_date {
			    UPDATE acs_objects SET creation_date = :creation_date
			    WHERE object_id = (SELECT latest_revision FROM cr_items WHERE item_id = :item_id)
			    
			}
		    }	    	    		    
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
				     -storage_type "$storage_type" \
				     -content_type $content_type]
		
		ns_log Notice "New REVISION Vehicle Inserted $plate"
		
		db_transaction {
		    db_dml update_revision_date {
			UPDATE acs_objects SET creation_date = :creation_date WHERE object_id = :revision_id
			
		    }
		}	    
		
	    }
	}  
    
    incr i
}

close $fp
