ad_page_contract {}
dsds


db_transaction {
    db_dml {
	UPDATE cr_revisions SET title = SPLIT_PART(description, ' ', 4) WHERE revision_id IN (SELECT cr.revision_id FROM cr_items ci , cr_revisions cr WHERE ci.item_id = cr.item_id AND ci.latest_revision = cr.revision_id AND ci.content_type = 'qt_vehicle');
    }
}
