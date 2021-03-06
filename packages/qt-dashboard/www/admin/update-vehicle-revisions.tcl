ad_page_contract {}

set visited_plates [list]

db_foreach select_vehicles {
    SELECT i.item_id, r.title, o.creation_date::timestamp, o.creation_user, o.package_id, o.creation_ip
    FROM cr_items i, cr_revisionsx r, acs_objects o
    WHERE o.object_id = i.item_id
    AND i.item_id = r.item_id
    AND i.latest_revision = r.revision_id
    AND i.content_type = 'qt_vehicle'
    AND r.title != 'UNKNOWN'
    ORDER BY o.creation_date ASC
} {

    set repeated_items [db_list select_item_ids { SELECT item_id FROM qt_vehicle_ti WHERE item_id != :item_id AND title = :title}]
    
    if {[llength $repeated_items] > 0} {
	ns_log Notice "ITEMID $item_id \n TITLE $title \n  DATE $creation_date "
	ns_log Notice "REPEATED ITEMS $repeated_items"
	
       	foreach id $repeated_items {

	    db_0or1row select_data {
		SELECT
		i.item_id AS repeated_item_id,
		r.title AS repeated_title,
		o.creation_date::timestamp AS repeated_date,
		r.description AS repeated_description 
		FROM cr_items i, cr_revisions r, acs_objects o
		WHERE o.object_id = i.item_id
		AND i.item_id = r.item_id
		AND i.latest_revision = r.revision_id
		AND i.item_id = :id
	    }
	    
	    
	    if {[info exists repeated_title] && [lsearch $visited_plates $repeated_title] eq -1} {
		ns_log Notice "REPEATED ITEMID $repeated_item_id \n TITLE $repeated_title \n ORIGINAL $title \n  DATE $repeated_date \n DESC $repeated_description \n"
				
		if {$title eq $repeated_title} { 
		    if {$creation_date ne $repeated_date} {		    
			db_transaction {
			    # Create item reivion in the original item
			    set revision_id [content::revision::new \
						 -item_id $item_id \
						 -creation_user $creation_user \
						 -package_id $package_id \
						 -creation_ip $creation_ip \
						 -creation_date $repeated_date \
						 -title $repeated_title \
						 -description $repeated_description \
						 -content $repeated_description \
					     -mime_type "text/plain" \
						 -publish_date $repeated_date \
						 -storage_type text \
						 -content_type qt_vehicle]
			    
			    ns_log Notice "New REVISION Vehicle Inserted $repeated_title"
			    
			    # Update revision creation_date 
			    db_dml update_revision_date {
				UPDATE acs_objects SET creation_date = :repeated_date WHERE object_id = :revision_id			    
			    }			
			}
		    }
		    
		    # Delete repeated item
		    content::item::delete -item_id $repeated_item_id
		}	      
				
	    } else {
		ns_log Notice  "Plate in the list Already Visited"
	    }
	}
    }
    
    if {[lsearch $visited_plates $title] eq -1} {
	lappend visited_plates $title
    }
}
#ns_log Notice "VISITED ITEMS \n $visited_plates"
#ns_log Notice "LENGTH [llength $visited_plates]"
