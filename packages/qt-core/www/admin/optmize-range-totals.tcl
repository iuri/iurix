ad_page_contract {}

ns_log Notice "Running TCL script optmize-totals.tcl"


set creation_date [db_string select_now { SELECT date_trunc('hour', now()::timestamp - INTERVAL '5 hour') FROM dual}]
set creation_date "2021-01-15 00:00:00"
ns_log Notice "CREATION DATE $creation_date"

set hostnames [list CCPN001 CCPN002]
foreach hostname $hostnames {
    ns_log Notice "Hostname $hostname"
    
    db_foreach select_grouped_per_hour "
	SELECT
	CASE WHEN SPLIT_PART(f.description, ' ', 4) <> 'undefined' THEN ROUND(SPLIT_PART(f.description, ' ',4)::numeric) END AS range,
	COUNT(1) AS total,
	COUNT(CASE WHEN SPLIT_PART(f.description, ' ', 8) = '0' THEN f.item_id END) AS total_female,
	COUNT(CASE WHEN SPLIT_PART(f.description, ' ', 8) = '1' THEN f.item_id END) AS total_male
	FROM qt_face_tx f, acs_objects o
	WHERE f.item_id = o.object_id
	AND SPLIT_PART(f.description, ' ', 37) = '${hostname}\}'
	GROUP BY range;
    " {
	set percentage ""
	# set hostname "PMXCO001"
	# set hostname "CCPN001"
	# set hostname "CCPN002"

	ns_log Notice "$total | $female | $male | $hostname | [db_string select_hour { SELECT DATE_TRUNC('hour', :hour::timestamp) FROM dual} ]"

       	db_0or1row exists_total_p {
	    SELECT qt_total_id AS total_id, total1, total2, total3, creation_date AS old_date, hostname AS old_host
	    FROM qt_totals
	    WHERE hostname = :hostname
	    AND creation_date = DATE_TRUNC('hour', :hour::timestamp) 
	}
	
	if {[info exists total_id]} {
	    if {$total1 ne $total} {
		ns_log Notice "UPDATE TOTALS $total_id | $total1 | $total2 | $total3 | $old_date | $old_host"
		db_transaction {
		    db_exec_plsql update_totals {
			SELECT qt_totals__edit(
					       :total_id,
					       :total,
					       :female,
					       :male,
					       :percentage)
		    }   
		}
	    }
	    unset total_id
	    unset total1
	    unset total2
	    unset total3
	    unset old_date
	    unset old_host
	    
	} else {
	    ns_log Notice "ADDING NEW TOTAL "
	    ns_log Notice "$hour $total $female $male $hostname"
	    
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
}
