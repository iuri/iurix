ad_page_contract {}


ns_log Notice "Running TCL script index.tcl"

#content::item::delete -item_id 337277
# https://dba.stackexchange.com/questions/112796/postgres-count-with-different-condition-on-the-same-query
# https://www.postgresqltutorial.com/postgresql-split_part/

db_0or1row select_persons_yesterday {
    SELECT COUNT(ci.item_id) total,
    COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '0' THEN ci.item_id END) AS female,
    COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '1' THEN ci.item_id END) AS male
    FROM cr_items ci, cr_revisions cr, acs_objects o
    WHERE ci.item_id = o.object_id
    AND ci.item_id = cr.item_id
    AND ci.latest_revision = cr.revision_id
    AND ci.content_type = 'qt_face'
    AND o.creation_date >= TIMESTAMP 'YESTERDAY' - INTERVAL '25 hour'
    AND o.creation_date < TIMESTAMP 'TODAY' - INTERVAL '25 hour'
    --  AND o.creation_date >= TIMESTAMP '2020-07-29'
    --  AND o.creation_date < TIMESTAMP '2020-07-30'
} -column_array yesterday




db_0or1row select_persons_today {
    SELECT COUNT(ci.item_id) total,
    COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '0' THEN ci.item_id END) AS female,
    COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '1' THEN ci.item_id END) AS male
    FROM cr_items ci, cr_revisions cr, acs_objects o
    WHERE ci.item_id = o.object_id
    AND ci.item_id = cr.item_id
    AND ci.latest_revision = cr.revision_id
    AND ci.content_type = 'qt_face'
    AND o.creation_date >= TIMESTAMP 'TODAY' - INTERVAL '25 hours' 
}
ns_log Notice "TOTAL TODAY $total"
array set today [list \
		     total $total \
		     female $female \
		     female_diff [expr 100 - [expr [expr $female * 100] / $yesterday(female)]] \
		     male $male \
		     male_diff [expr 100 - [expr [expr $male * 100] / $yesterday(male)]]]




array set lastweek {
    total 0
    female 0
    male 0
}






template::head::add_css -href "/resources/qt-dashboard/styles/dashboard.css"
# <!-- Latest compiled and minified CSS -->
template::head::add_css -href "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"

# <!-- Optional theme -->
template::head::add_css -href "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css"

# <!-- Latest compiled and minified JavaScript -->
template::head::add_javascript -src "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"
