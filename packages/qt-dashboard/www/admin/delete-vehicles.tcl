ad_page_contract {}

# ALL vehicles    --    SELECT item_id FROM cr_items WHERE content_type = 'qt_vehicle'
dsds
#content::item::delete -item_id 686838
db_foreach select_today_vehicles {
    SELECT item_id, creation_date  FROM cr_items ci, acs_objects o WHERE ci.item_id = o.object_id AND content_type = 'qt_vehicle' AND o.creation_date::date = now()::date;
} {
    ns_log Notice "DELETE VEHICLE $item_id"
    content::item::delete -item_id $item_id

}

ns_log Notice "DELETE COMPLETED *****"
