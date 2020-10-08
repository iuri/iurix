ad_page_contract {}
dsd

db_foreach select_vehicles {
    SELECT i.item_id, r.title, o.creation_date::timestamp, r.creation_date as date2, r.revision_id, r.description
    FROM cr_items i, cr_revisionsx r, acs_objects o
    WHERE o.object_id = i.item_id
    AND i.item_id = r.item_id
    AND i.latest_revision = r.revision_id
    AND i.content_type = 'qt_vehicle'
    AND r.title = 'UNKNOWN'
    ORDER BY o.creation_date ASC
   -- LIMIT 100;
    
} {
    ns_log Notice "ITEMID $item_id \n REVISION ID $revision_id \n TITLE $title \n  DATE $creation_date \n DATE2 $date2 \n DESC $description \n"
    
    
    
}
