ad_page_contract {}

set visited_plates [list]

db_foreach select_vehicles {
    SELECT i.item_id, r.title, o.creation_date, o.creation_user, o.package_id, o.creation_ip
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
	ns_log Notice "ITEMID $item_id \n TITLE $title \n  DATE $creation_date \n USER $creation_user \n PKGID $package_id "
	ns_log Notice "REPEATED ITEMS $repeated_items"
	
	set repeated_items [join $repeated_items ", "]
	
	foreach id $repeated_items {

	    db_1row select_data {
		SELECT
		i.item_id AS repeated_item_id,
		r.title AS repeated_title,
		o.creation_date AS repeated_date,
		r.description AS repeated_description 
		FROM cr_items i, cr_revisions r, acs_objects o
		WHERE o.object_id = i.item_id
		AND i.item_id = r.item_id
		AND i.latest_revision = r.revision_id
		AND i.item_id = :id
	    }
	    
	    ns_log Notice "REPEATED ITEMID $repeated_item_id \n TITLE $repeated_title \n  DATE $repeated_date \n DESC $repeated_description \n"
	    
	    
	    if {[lsearch $visited_plates $repeated_title] eq -10} {
		
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
			UPDATE acs_objects SET creation_date = :creation_date WHERE object_id = :revision_id
			
		    }
		    
		    
		    # Delete repeated item
		    content::item::delete -item_id $repeated_item_id
		    
		}
	    }
	}
    }
    
    if {[lsearch $visited_plates $title] eq -1} {
	lappend visited_plates $title
    }
}
ns_log Notice "VISITED ITEMS \n $visited_plates"
ns_log Notice "LENGTH [llength $visited_plates]"
