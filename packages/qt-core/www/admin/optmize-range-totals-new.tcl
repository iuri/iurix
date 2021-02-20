ad_page_contract {}

ns_log Notice "Running TCL script optmize-totals-new.tcl"
dsdsds
set creation_date [db_string select_now { SELECT date_trunc('hour', now()::timestamp - INTERVAL '5 hour') FROM dual}]
set creation_date "2018-01-15 00:00:00"
ns_log Notice "CREATION DATE $creation_date"

set hostnames [list PMXCO001 CCPN001 CCPN002]
foreach hostname $hostnames {
    
    if {$hostname eq "PMXCO001"} {
	set where_clauses " AND SPLIT_PART(f.description, ' ', 37) != 'CCPN001\}' AND SPLIT_PART(f.description, ' ', 37) != 'CCPN002\}'"
    } else {
	set where_clauses " AND SPLIT_PART(f.description, ' ', 37) = '${hostname}\}'"
    }
    
    db_foreach select_grouped_per_range "
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
	    # set hostname "PMXCO001"
	    # set hostname "CCPN001"
	    # set hostname "CCPN002"
	    
	    ns_log Notice "$hour | $range | $total | $total_female | $total_male | $hostname "
	    
	    db_0or1row exists_total_p {
		SELECT range_id, total AS old_total,
		total_female,
		total_male,
		creation_date AS old_date,
		hostname AS old_host
		FROM qt_face_range_totals
		WHERE hostname = :hostname
		AND range = :range
		AND creation_date = DATE_TRUNC('hour', :hour::timestamp) 
	    }
	    
	    if {[info exists range_id]} {
		if {$old_total ne 56} {
		    ns_log Notice "UPDATE TOTALS $range_id | $range | $total | $total_female | $total_male | $old_date | $old_host"
		    db_transaction {
			db_exec_plsql update_totals {
			    SELECT qt_face_range_totals__edit(
							      :range_id,
							      :range,
							      :total,
							      :total_female,
							      :total_male,
							      :percentage)
			}   
		    }
		}		
	    } else {
		ns_log Notice "ADDING NEW TOTAL "
		#		ns_log Notice "$hour $total $female $male $hostname"
		
		db_transaction {
		    db_exec_plsql insert_totals {
			SELECT qt_face_range_totals__new(
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
    }
    
