ad_page_contract {}

set add_p 0

db_foreach select_grouped_per_hour "
    SELECT DATE_TRUNC('hour', o.creation_date) AS hour,
    COUNT(1) AS total,
    COUNT(CASE WHEN SPLIT_PART(f.description, ' ', 8) = '0' THEN f.item_id END) AS female,
    COUNT(CASE WHEN SPLIT_PART(f.description, ' ', 8) = '1' THEN f.item_id END) AS male
    FROM qt_face_tx f, acs_objects o
    WHERE f.item_id = o.object_id
--    AND SPLIT_PART(f.description, ' ', 37) = 'CCPN001\}' 
    AND SPLIT_PART(f.description, ' ', 37) = 'CCPN002\}'
    GROUP BY 1
    ORDER BY hour ASC   
" {

    ns_log Notice "$hour $total $female $male "

    set percentage ""
    # set hostname "PMXCO001"
    # set hostname "CCPN001"
    set hostname "CCPN002"

    if {$add_p eq 1} {
	ns_log Notice "ADDING TOTAL "
	ns_log Notice "$hour $total $female $male "
	db_transaction {
	    set total_id [db_nextval "qt_total_id_seq"]
	    
	    db_exec_plsql insert_totals {
		SELECT qt_totals__new(
				      :total_id,
				      :hour,
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
