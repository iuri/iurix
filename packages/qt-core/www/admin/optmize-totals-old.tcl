ad_page_contract {}

ns_log Notice "Running TCL script optmize-totals.tcl"

set add_p 1


set creation_date [db_string select_now { SELECT date_trunc('hour', now()::timestamp - INTERVAL '5 hour') FROM dual}]
set creation_date "2018-01-30 00:00:00"
ns_log Notice "CREATION DATE $creation_date"

db_foreach select_grouped_per_hour "
    SELECT DATE_TRUNC('hour', o.creation_date::timestamp) AS hour,
    COUNT(1) AS total,
    COUNT(CASE WHEN SPLIT_PART(f.description, ' ', 8) = '0' THEN f.item_id END) AS female,
    COUNT(CASE WHEN SPLIT_PART(f.description, ' ', 8) = '1' THEN f.item_id END) AS male
    FROM qt_face_tx f, acs_objects o
    WHERE f.item_id = o.object_id
    AND o.creation_date::date >= :creation_date::date 
    AND SPLIT_PART(f.description, ' ', 37) != 'CCPN001\}'
    AND SPLIT_PART(f.description, ' ', 37) != 'CCPN002\}'
    GROUP BY 1
    ORDER BY hour ASC   
" {
    set percentage ""
    set hostname "PMXCO001"
    # set hostname "CCPN001"
    # set hostname "CCPN002"
    
    
    ns_log Notice "$hour $total $female $male $hostname"
    
    
    if {$add_p eq 1} {
		
	ns_log Notice "ADDING NEW TOTAL "
	
	db_transaction {
	    
	    db_exec_plsql insert_totals {
		SELECT qt_totals__new(:hour,
				      :total,
				      :female,
				      :male,
				      :percentage,
				      :hostname,
				      'qt_face')
	    }   
	}
    }
}
