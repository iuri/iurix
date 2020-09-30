ad_page_contract {}



db_foreach select_number_plates {
    SELECT ci.item_id, cr.title FROM cr_items ci, cr_revisions cr, acs_objects o WHERE ci.item_id = cr.item_id AND ci.item_id = o.object_id AND ci.content_type = 'qt_vehicle' AND cr.title ~ '^[0-9]*$' ;
    
} {

    if { [regexp {^([0-9]+)$} $title] } {
	ns_log Notice "DELETE ITEM $title"
       content::item::delete -item_id $item_id
    } else {
	ns_log Notice "NOT A NUMBER"
    }
}
