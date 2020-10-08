ad_page_contract {}

set visited_items [list]
set i 0
db_foreach select_revisions {
    SELECT v.object_id AS revision_id, v.title, v.description, v.creation_date, v.item_id FROM qt_vehicle_ti v ORDER BY v.creation_date ASC 
} {
    
    
    if {[lsearch $visited_items $item_id] eq -1} {
	# ns_log Notice "REVID $revision_id TITLE $title DESCRIPTION $description CREATIONDATE $creation_date ITEMID $item_id"
	set repeated_revisions [db_list select_revision_id {
	    SELECT object_id FROM qt_vehicle_ti
	    WHERE object_id != :revision_id
	    AND item_id = :item_id
	    AND title = :title
	    AND description = :description
	    AND creation_date = :creation_date
	}]

	if {[llength $repeated_revisions] > 0 } {
	    ns_log Notice "REPETATED REVISIONS $repeated_revisions"
	    
	    ns_log Notice "DELETE revision"
	    #       content::revision::delete -revision_id $revision_id
	}
    }

    lappend visited_items $item_id   
    incr i
}


ns_log Notice "I $i COMPLETED  [llength $visited_items] VISITED"
