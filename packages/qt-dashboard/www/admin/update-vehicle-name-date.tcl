ad_page_contract {}


db_foreach select_vehicles {
    SELECT i.item_id, r.title, o.creation_date::timestamp, r.description
    FROM cr_items i, cr_revisions r, acs_objects o
    WHERE o.object_id = i.item_id
    AND i.item_id = r.item_id
    AND i.latest_revision = r.revision_id
    AND i.content_type = 'qt_vehicle'
    AND r.title != 'UNKNOWN'
    ORDER BY o.creation_date ASC LIMIT 100;
    
} {
    ns_log Notice "ITEMID $item_id TITLE $title, DATE $creation_date, DESC $description"

    if {$title ne "UNKNOWN"} {
	set repeated_items [join [db_list select_item_ids { SELECT item_id FROM qt_vehicle_ti WHERE item_id != :item_id AND title = :title }] ", "]
	
	ns_log Notice "REPEATED ITEMS $repeated_items"

	if {[llength $repeated_items] > 0} {
	    db_foreach select_repeated_items "
		SELECT v.object_id, v.object_title, v.title, v.creation_date::timestamp, o.creation_date::timestamp, v.description FROM qt_vehicle_ti v, acs_objects o WHERE o.object_id = v.item_id AND v.item_id IN ($repeated_items) ORDER BY v.creation_date ASC LIMIT 10;
	    " {
		ns_log Notice "REPEATED OBJ $item_id, TITLE $title, DATE $creation_date, DESC $description"
		
	    }
	}	    
    }
}
