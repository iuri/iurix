ad_page_contract {}


db_foreach select_vehicles {
    SELECT i.item_id, r.title, o.creation_date::timestamp, r.description
    FROM cr_items i, cr_revisions r, acs_objects o
    WHERE o.object_id = i.item_id
    AND i.item_id = r.item_id
    AND i.latest_revision = r.revision_id
    AND i.content_type = 'qt_vehicle'
    AND r.title != 'UNKNOWN'
    ORDER BY o.creation_date ASC
    -- LIMIT 100;
    
} {
    if {$title ne "UNKNOWN"} {
	set repeated_items [db_list select_item_ids { SELECT item_id FROM qt_vehicle_ti WHERE item_id != :item_id AND title = :title }]
	
	
	if {[llength $repeated_items] > 0} {
	    ns_log Notice "ITEMID $item_id TITLE $title, DATE $creation_date, DESC $description"
	    ns_log Notice "REPEATED ITEMS $repeated_items"
	    
	   set repeated_items [join $repeated_items ", "]
	    db_foreach select_repeated_items "
		SELECT i.item_id, r.revision_id, r.title, o.creation_date::timestamp, r.description, r.creation_date AS date2
		FROM cr_items i, cr_revisionsx r, acs_objects o
		WHERE o.object_id = i.item_id
		AND i.item_id = r.item_id
		AND i.latest_revision = r.revision_id
		AND i.content_type = 'qt_vehicle'
		AND i.item_id IN ($repeated_items)
	    " {
		ns_log Notice "REPEATED OBJ $item_id \n REVISION ID $revision_id \n TITLE $title \n  DATE $creation_date \n DATE2 $date2 \n DESC $description \n"
		db_transaction {
		    db_dml update_revision_date {
			UPDATE acs_objects SET creation_date = :creation_date WHERE object_id = :revision_id
			
		    }
		}	    
		
	    }
	}
    }
}
