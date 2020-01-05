ad_page_contract {

    Retrieves data and parse it to Google's JS API

    References:
    http://ben.goodacre.name/tech/Group_by_day,_week_or_month_(PostgreSQL)
    https://stackoverflow.com/questions/8723523/selecting-records-between-two-timestamps
}




#template::paginator::get_group_count name
# Get ADV's group_id


set group_id [group::get_id -group_name "ADVJR"]
set members "[group::get_members -group_id $group_id]"

ns_log Notice "ID $group_id | MEMBERS $members"
set group_id [group::get_id -group_name "ADVSR"]

set members "$members [group::get_members -group_id $group_id]"




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
	select date_trunc('day', creation_date) AS day, COUNT(*) AS qty, SUM(score)  AS total FROM ns_user_score WHERE creation_date > now() - interval '3 months' GROUP BY 1 ORDER BY 1;
	
    } {
	ns_log Notice "DATE $day"

	set scores ""
	
	foreach user_id $members {
	    set score_total 0
	    
	    db_foreach select_scores {
		SELECT ns1.score
		FROM ns_user_score ns1
		WHERE ns1.creation_date > :day::timestamp - interval '1 day'
		AND ns1.creation_date < :day::timestamp + interval '1 day'
		AND ns1.user_id = :user_id
		ORDER BY ns1.creation_date
		
		
	    } {

		
		ns_log Notice "USERID $user_id | SCORE $score"
		set score_total [expr $score + $score_total]
	    }

	    append scores " $score_total,"

	}

	
	set scores [string trimright $scores ","]
	set day [lc_time_fmt $day "%q" "pt_BR"]

	ns_log Notice "\['$day', $scores , $total\],"
	append data2 "\['$day', $scores , $total\],"
	
    }
    
    set data2 [string trimright $data2 ","]
    
}






    
