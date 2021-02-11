ad_page_contract {}

set access_token [parameter::get_global_value -package_key qt-bluefox -parameter AccessToken -default ""]
set secret_token [parameter::get_global_value -package_key qt-bluefox -parameter SecretToken -default ""]
set content_type [parameter::get_global_value -package_key qt-bluefox -parameter ContentType -default ""]


set req_headers [ns_set create]
ns_set put $req_headers "x-api-access-token" "$access_token"
ns_set put $req_headers "x-api-secret-token" "$secret_token"
ns_set put $req_headers "Content-Type" "$content_type"

ns_log Notice "$access_token | $secret_token | $content_type"

#   set url "http://luna.qonteo.com:5000/4/storage/lists"
set proto [parameter::get_global_value -package_key qt-bluefox -parameter ProtoURL -default "https"]
set domain [parameter::get_global_value -package_key qt-bluefox -parameter DomainURL -default ""]
set path [parameter::get_global_value -package_key qt-bluefox -parameter HistoricalPath -default ""]
set url "${proto}://${domain}/${path}"

set body "\{
    \"day_span\": 7
\}"
ns_log Notice "URL $url"
set res [ns_http run -method POST -headers $req_headers -body $body $url]
#ns_log Notice "RES2 $res"


set data [dict get $res body]

package req json

set l [json::json2dict $data]
#ns_log Notice "DATA $l"
array set arr $l


#status OK occupancy_count_flooring_enabled 1 floor_occupancy_count 0 occupancy_count_slots

#ns_log Notice "$occupancy_count_slots"
set total 0
set l_totals [list] 
foreach elem $arr(occupancy_count_slots) {
    
    set timestamp [lindex $elem 0]	
    set date_from [db_string convert_timestamp {
	SELECT TIMESTAMP WITH TIME ZONE 'epoch' + :timestamp * INTERVAL '1 second'
    }]
    
    
    
    set day_hour [lindex [split $date_from ":"] 0]
    set idx [lsearch -index 0 $l_totals "${day_hour}:00:00"] 
    set total [expr $total + [expr [expr [lindex $elem 2] + [lindex $elem 3]] / 2.00]]


    
    if { $idx eq -1 } {
	if {[lindex $elem 2] eq 0 && [lindex $elem 3] eq 0} {
	    # do nothing
	} else {
	    ns_log Notice "INSERT PARTIAL"
	    set count [expr [expr [lindex $elem 2] + [lindex $elem 3]] / 2.00]
	    lappend l_totals [list "${day_hour}:00:00" $count]

	    ns_log Notice "$day_hour | $idx | [lindex $elem 2] | [lindex $elem 3] | TOTAL $total"

	}
    } else {
	ns_log Notice "SUM PARTIAL"
	set old_count [lindex [lindex $l_totals $idx] 1]
	set count [expr [expr [lindex $elem 2] + [lindex $elem 3]] / 2.00]
	lset l_totals $idx [list "${day_hour}:00:00" [expr $count + $old_count]]

	ns_log Notice "$day_hour | $idx | [lindex $elem 2] | [lindex $elem 3] | TOTAL $total"

    }		  
	
    
}

ns_log Notice "RESULT ****"
foreach elem $l_totals {
#    ns_log Notice "ELEM $elem"
    set hour [lindex $elem 0]
    set total [expr round([lindex $elem 1])]
#    set total [expr [lindex $elem 1]]

    ns_log Notice "INSERT $hour TOTAL $total "


    
    db_transaction {
	db_exec_plsql insert_totals {
	    SELECT qt_totals__new(:hour,
				  :total,
				  null,
				  null,
				  null,
				  'CCPN003',
				  'qt_face')		    
	}
    }
    
}

