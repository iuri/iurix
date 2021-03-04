ad_page_contract {}



db_foreach select_item_id {

    SELECT item_id FROM qt_whatsapp_msg_tx
} {
    ns_log Notice "DELETE message $item_id"
    content::item::delete -item_id $item_id
}
