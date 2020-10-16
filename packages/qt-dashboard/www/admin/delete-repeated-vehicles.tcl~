ad_page_contract {}
dsds

set i 0
db_foreach select_today_vehicles {
    SELECT ci.item_id, cr.title, o.creation_date
    FROM cr_items ci, acs_objects o, cr_revisions cr
    WHERE ci.item_id = o.object_id
    AND ci.item_id = cr.item_id
    AND content_type = 'qt_vehicle'
    AND cr.title != 'UNKNOWN' ORDER BY o.creation_date ASC
} {

    
    set repeated_items [db_list_of_lists select_repeated_vehicles {
	SELECT ci.item_id, cr.title, o.creation_date
	FROM cr_items ci, acs_objects o, cr_revisions cr
	WHERE ci.item_id = o.object_id
	AND ci.item_id = cr.item_id
	AND content_type = 'qt_vehicle'
	AND ci.item_id != :item_id
	AND cr.title = :title
	AND 
	AND o.creation_date != :creation_date
	AND o.creation_date::timestamp BETWEEN :creation_date::timestamp AND :creation_date::timestamp + INTERVAL '10 minutes'
	
    }]
    
    if {[llength $repeated_items] > 0} {
	ns_log Notice "VEHICLE $item_id | PLATE $title | DATETIME $creation_date"
	ns_log Notice "            REPEATED VEHICLES $repeated_items"
	foreach elem $repeated_items {
	    set id [lindex $elem 0]
	    ns_log Notice "DEELTE ID $id"
	    incr i
	   # content::item::delete -item_id $id
	    
	}
    }
}

ns_log Notice "TOTAL DELETED $i"
