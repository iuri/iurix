ad_page_contract {}

set i 0
db_foreach select_revisions {
    SELECT cr.revision_id
    FROM cr_revisions cr, cr_items ci
    WHERE ci.item_id = cr.item_id
    AND ci.latest_revision = cr.revision_id
    AND ci.content_type = 'qt_vehicle';

} {
    ns_log Notice "REVID $revision_id"
    content::item::set_live_revision -revision_id $revision_id -publish_status live
    incr i
}


ns_log Notice "I $i"
