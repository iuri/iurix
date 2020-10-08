ad_page_contract {}

ns_log Notice "Running SPLIT REVISIONS"

db_foreach select_items {
     SELECT i.item_id FROM cr_items i, acs_objects o, cr_revisions r WHERE i.item_id = o.object_id AND i.item_id = r.item_id AND i.content_type = 'qt_vehicle' AND r.title != 'UNKNOWN' ORDER BY o.creation_date DESC 
} {
    set revision_titles [db_list select_revisions {
	SELECT DISTINCT(r.title) FROM cr_revisions r WHERE item_id = :item_id 
    }]

    if {[llength $revision_titles] > 1 } {

	set revision_ids [db_list_of_lists select_revisions {
	    SELECT revision_id FROM cr_revisions r WHERE item_id = :item_id 
	}]
	ns_log Notice "TITLES $revision_titles"
	ns_log Notice "IDS $revision_ids"

	
    }

 
}

