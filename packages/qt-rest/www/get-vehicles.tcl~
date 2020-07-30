ad_page_contract {}


set result "\{\"vehicles\": \["

db_foreach select_vehicles {
    SELECT ci.name, cr.description, cr.creation_date
    FROM cr_items ci, cr_revisionsx cr
    WHERE ci.item_id = cr.item_id
    AND ci.latest_revision = cr.revision_id
    AND ci.content_type = 'qt_vehicle'
    AND cr.creation_date > now() - INTERVAL '2 day'
--    AND cr.creation_date < now()
    AND cr.creation_date < now() - INTERVAL '1 day'
--    LIMIT 3
} {


    append result "\{\"name\": \"$name\", \"creation_date\": \"$creation_date\", \"description\": \"$description\"\},"
}


set result [string trimright $result ","]
append result "\]\}"

ns_respond -status 200 -type "application/json" -string $result
ad_script_abort
