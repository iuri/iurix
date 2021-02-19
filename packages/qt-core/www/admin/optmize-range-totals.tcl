ad_page_contract {}

ns_log Notice "Running TCL script optmize-totals.tcl"

dsds
# set creation_date [db_string select_now { SELECT date_trunc('hour', now()::timestamp - INTERVAL '5 hour') FROM dual}]
set creation_date "2018-12-11 00:00:00"
ns_log Notice "CREATION DATE $creation_date"

#set hostnames [list CCPN001 CCPN002 PMXCO001]
set hostnames [list CCPN001 CCPN002]
#set hostnames [list PMXCO001]

foreach hostname $hostnames {
    ns_log Notice "Hostname $hostname"

    if {$hostname eq "PMXCO001"} {
	set where_clauses " AND SPLIT_PART(f.description, ' ', 37) != 'CCPN001\}' AND SPLIT_PART(f.description, ' ', 37) != 'CCPN002\}'"
    } else {
	set where_clauses " AND SPLIT_PART(f.description, ' ', 37) = '${hostname}\}'"
    }
    
    db_foreach select_grouped_per_hour "
	SELECT
        DATE_TRUNC('hour', o.creation_date::timestamp) AS hour,
	CASE WHEN SPLIT_PART(f.description, ' ', 4) <> 'undefined' THEN ROUND(SPLIT_PART(f.description, ' ',4)::numeric) END AS range,
	COUNT(1) AS total,
	COUNT(CASE WHEN SPLIT_PART(f.description, ' ', 8) = '0' THEN f.item_id END) AS total_female,
	COUNT(CASE WHEN SPLIT_PART(f.description, ' ', 8) = '1' THEN f.item_id END) AS total_male
	FROM qt_face_tx f, acs_objects o
	WHERE f.item_id = o.object_id
        $where_clauses
	AND o.creation_date::date >= :creation_date::date 
	GROUP BY hour, range
        ORDER BY hour;
    " {
	set percentage ""

	ns_log Notice "$hour | $range | $total | $total_female | $total_male | $hostname "

	db_transaction {

	    db_exec_plsql insert_range {
		SELECT qt_face_range_totals__new (
						  null,
						  :range,
						  :hour,
						  :total,
						  :total_female,
						  :total_male,
						  :percentage,
						  :hostname,
						  'qt_face')


	    }

	}


    }   
}
