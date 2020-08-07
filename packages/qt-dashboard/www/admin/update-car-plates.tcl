ad_page_contract {}

set plate [db_string select_plate {

    SELECT SPLIT_PART(description, ' ', 4) AS plate
    FROM cr_items ci , cr_revisions cr
    WHERE ci.item_id = cr.item_id
    AND ci.latest_revision = cr.revision_id
    AND ci.content_type = 'qt_vehicle'
    LIMIT 1
} -default ""]



db_transaction {
    db_dml update_title {
	UPDATE cr_revisions SET title = SPLIT_PART(description, ' ', 4) WHERE revision_id IN (SELECT cr.revision_id FROM cr_items ci , cr_revisions cr WHERE ci.item_id = cr.item_id AND ci.latest_revision = cr.revision_id AND ci.content_type = 'qt_vehicle');
    }
}
