ad_page_contract {}


db_foreach select_persons {
    SELECT item_id FROM cr_items WHERE content_type = 'qt_face'
} {
    content::item::delete -item_id $item_id

}

#content::item::delete -item_id 265079
ns_log Notice "DELETE COMPLETED *****"
