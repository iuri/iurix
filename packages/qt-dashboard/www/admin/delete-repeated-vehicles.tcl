ad_page_contract {}

set i 0
set visited_revisions [list]
db_foreach select_today_vehicles {
    -- CASE 1 LPR1 Camera
    -- SELECT revision_id, title, SPLIT_PART(description, ' ', 21) AS camera, creation_date FROM qt_vehicle_ti WHERE title != 'UNKNOWN' AND SPLIT_PART(description, ' ', 21) = 'LPR1' ORDER BY creation_date ASC 
    -- EVAL SAMPLE  AND title = 'WCK412' AND creation_date::date = '2020-09-11' 

    -- CASE 2 LPR4 Camera 
    -- SELECT revision_id, title, SPLIT_PART(description, ' ', 21) AS camera, creation_date FROM qt_vehicle_ti WHERE title != 'UNKNOWN' AND SPLIT_PART(description, ' ', 21) = 'LPR4' ORDER BY creation_date ASC LIMIT 100

    -- CASE 3 Cam11 Camera (Car Exit)
    -- SELECT revision_id, title, SPLIT_PART(description, ' ', 21) AS camera, creation_date FROM qt_vehicle_ti WHERE title != 'UNKNOWN' AND SPLIT_PART(description, ' ', 21) = 'Cam11' ORDER BY creation_date DESC LIMIT 1000

    -- CASE 4 Cam14 Camera (Car Entry)
    SELECT revision_id, title, SPLIT_PART(description, ' ', 21) AS camera, creation_date FROM qt_vehicle_ti WHERE title != 'UNKNOWN' AND SPLIT_PART(description, ' ', 21) = 'Cam14' ORDER BY creation_date ASC LIMIT 1000
    
} { 


    set repeated_revisions [db_list_of_lists select_repeated_revisions {
	SELECT revision_id, title, SPLIT_PART(description, ' ', 21) AS camera, creation_date
	FROM qt_vehicle_ti
	WHERE title = :title
	AND revision_id != :revision_id
	-- Cam11 To retrieve revisions, which are timestamped before interval must be filtered to before creation_date
	-- AND SPLIT_PART(description, ' ', 21) = 'Cam11'	
 	-- AND creation_date BETWEEN :creation_date::timestamp - INTERVAL '9 minutes' AND :creation_date::timestamp
	-- ORDER BY creation_date DESC

	-- CAM14, LPR1 and LPR4 
	-- AND SPLIT_PART(description, ' ', 21) = 'LPR1'	
	-- AND SPLIT_PART(description, ' ', 21) = 'LPR4'	
	AND SPLIT_PART(description, ' ', 21) = 'Cam14'       
	AND creation_date BETWEEN :creation_date::timestamp AND :creation_date::timestamp + INTERVAL '9 minutes'	
	ORDER BY creation_date ASC
    }]

    if {[llength $repeated_revisions] > 0} {
	ns_log Notice "ID $revision_id PLATE $title TIMESTAMP $creation_date \n REPEATED ITEMS $repeated_revisions"
	foreach revision $repeated_revisions {
	    set id [lindex $revision 0]
	    ns_log Notice "VISITED? [lsearch $visited_revisions $id]"
	    if {[lsearch $visited_revisions $id] eq -1} {
		
		ns_log Notice "DELETE ID $id"
		# content::revision::delete -revision_id $revision_id
		incr i
	    }
	}
    }
    
    lappend visited_revisions $revision_id
}
ns_log Notice "TOTAL DELETED $i"
