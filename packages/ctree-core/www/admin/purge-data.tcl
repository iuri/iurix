ad_page_contract {}


db_foreach select_items {
    SELECT item_id FROM cr_items WHERE content_type LIKE 'ctree%'
} {
    ns_log Notice "DELETE ITEM $item_id"
    # content::item::delete -item_id $item_id
}

ad_returnredirect [export_vars -base "index" {{msg "Data Successfully Deleted"}}]
ad_Script_abort
