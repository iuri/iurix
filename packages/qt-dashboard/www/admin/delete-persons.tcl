ad_page_contract {}


content::item::delete -item_id 686838
db_foreach select_persons {
    SELECT item_id FROM cr_items WHERE content_type = 'qt_face'
} {
#   content::item::delete -item_id $item_id

}

ns_log Notice "DELETE COMPLETED *****"
