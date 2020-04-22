ad_page_contract {

    Retrieves data and parse it to Google's JS API

    References:
    http://ben.goodacre.name/tech/Group_by_day,_week_or_month_(PostgreSQL)
    https://stackoverflow.com/questions/8723523/selecting-records-between-two-timestamps
}

ns_log Notice "Running TCL script emails-portlet"
set data1 "\['Data', "

set members [db_list select_senders {
    SELECT DISTINCT(u.user_id) FROM cc_users u, iurix_mails m
    WHERE m.from_address = u.email
}]






if {[llength $members] > 0} {

    ns_log Notice "MEMBERS $members "
    
    set data1 "\['Data', "
    
    foreach user_id $members {
	acs_user::get -user_id $user_id -array user
	append data1 "'$user(name)', "

	set color [format #%06x [expr {int(rand() * 0xFFFFFF)}]]
	append colors "'$color', "	
    }
    
    append data1 "'TOTAL'\],"
    append colors "'#7570b3'"

    
    # graphic must be per day
    db_foreach select_dates {
	SELECT date_trunc('day', date::timestamp) AS day, COUNT(*) AS total
	FROM iurix_mails WHERE date::timestamp > now() - interval '3 months'
	GROUP BY 1 ORDER BY 1;
	
    } {
	ns_log Notice "DATE $day"

	set total ""
	set users_total ""
	
	foreach user_id $members {
	    set user_total [db_string select_emails_qty {
	    SELECT COUNT(*) FROM iurix_mails m, cc_users u
		WHERE m.date::timestamp > :day::timestamp - interval '1 day'
		AND m.date::timestamp < :day::timestamp + interval '1 day'
		AND m.from_address = u.email
		AND u.user_id = :user_id

	    } -default 0]


	    #ns_log Notice "APPEND USER $user_id"
	    append users_total " $user_total,"

	    set total [expr $total + $user_total]
	    
	}
	
	
	# set scores [string trimright $scores ","]
	set day [lc_time_fmt $day "%q" "pt_BR"]

	ns_log Notice "\['$day', $users_total, $total\],"
	append data2 "\['$day', $users_total $total\],"
	
    }
    
    set data2 [string trimright $data2 ","]
    
}






    
