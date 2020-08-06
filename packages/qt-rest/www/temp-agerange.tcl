   set i 10
    set l_elems [list]
    while {$i <= 60} {
	set j [expr $i + 2]

	append l_elem "age$i female$i male$i "
	
	append sql "
	    -- persons $i < ageRange <= $j
	    COUNT(CASE WHEN ( SPLIT_PART(cr.description, ' ', 4) > '$i' AND SPLIT_PART(cr.description, ' ', 4) <= '$j' ) THEN ci.item_id END) AS age$i$j,
	    -- Females $i < ageRange <= $j
	    COUNT(CASE WHEN ( SPLIT_PART(cr.description, ' ', 4) > '$i' AND SPLIT_PART(cr.description, ' ', 4) <= '$j' ) AND SPLIT_PART(cr.description, ' ', 8) = '0' THEN ci.item_id END) AS female$i$j,
	    -- Males $i < ageRange <= $j
	    COUNT(CASE WHEN ( SPLIT_PART(cr.description, ' ', 4) > '$i' AND SPLIT_PART(cr.description, ' ', 4) <= '$j' ) AND SPLIT_PART(cr.description, ' ', 8) = '1' THEN ci.item_id END) AS male$i$j,
	"
	set i [expr $i + 2]	
    }

    set total_month 0
    set female_month 0
    set male_month 0










    
    set data [db_list_of_lists select_person_grouped_ageRange_daily "
	SELECT
	date_trunc('day', o.creation_date) AS day, 
        -- totalPersons
	COUNT(1) AS total_day,
	COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '0' THEN ci.item_id END) AS female_day,
	COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '1' THEN ci.item_id END) AS male_day,


	-- persons <= ageRange 10
	COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 4) <= '10' THEN ci.item_id END) AS age10minus,
	-- Females ageRange <= 10 
	COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 4) <= '10' AND SPLIT_PART(cr.description, ' ', 8) = '0' THEN ci.item_id END) AS female10minus,
	-- Males ageRange <= 10
	COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 4) <= '10' AND SPLIT_PART(cr.description, ' ', 8) = '1' THEN ci.item_id END) AS male10minus,

	$sql
	
	-- persons ageRange > 60    
	COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 4) > '60' THEN ci.item_id END) AS age60plus,
	-- females ageRange > 60    
	COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 4) > '60' AND SPLIT_PART(cr.description, ' ', 8) = '0' THEN ci.item_id END) AS female60plus,
	-- males ageRange > 50    
	COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 4) > '60' AND SPLIT_PART(cr.description, ' ', 8) = '1' THEN ci.item_id END) AS male60plus
	
	FROM cr_items ci, acs_objects o, cr_revisions cr
	WHERE ci.item_id = o.object_id
	AND ci.item_id = cr.item_id
	AND ci.latest_revision = cr.revision_id
	AND ci.content_type = :content_type
	-- AND o.creation_date BETWEEN :creation_date::date - INTERVAL '6 day' AND :creation_date::date + INTERVAL '1 day'
	AND o.creation_date BETWEEN :creation_date::date - INTERVAL '1 month' AND :creation_date::date + INTERVAL '1 day'
	GROUP BY 1
	ORDER BY day ASC;	
    "]
    # ns_log Notice "DATA $data"
    






    foreach elem $data {
	ns_log Notice "ELEM $elem"
	# ELEM {2020-07-05 00:00:00+00} 142 39 103 0 0 0 3 0 3 0 0 0 3 0 3 0 0 0 0 0 0 1 0 1 7 4 3 6 1 5 9 3 6 11 2 9 10 3 7 16 4 12 19 9 10 10 4 6 15 3 12 9 2 7 5 0 5 7 2 5 2 0 2 2 1 1 0 0 0 2 0 2 1 0 1 2 1 1 2 0 2 0 0 0 0 0 0
	
	ns_log Notice "LENGTH [llength $elem]"
	set day [clock scan [lindex [split [lindex $elem 0] "+"] 0]]
	set day [clock format $day -format "%d/%m"]

	set total_day [lindex $elem 1]
	set female_day [lindex $elem 2]
	set male_day [lindex $elem 3]

	set total_month [expr $total_day + $total_month]
	set female_month [expr $female_day + $female_month]
	set male_month [expr $male_day + $male_month]

	set i 10
	append result "\{\"day\": \"$day\", \"ranges\": \["

	set partial_result ""
	while {$i <= 60} {
	    set a $i
	    if {$i eq 10} {
		set a "-$i"
	    }
	    append partial_result "\{\"Age\": \"$a\"\},"


    


	    
	    set i [expr $i + 2]
	}
	append result $partial_result
	set result [string trimright $result ","]
	append result "\]\},"
	    
	
    }

    set result [string trimright $result ","]
    append result "\]\},"



















for {set j 4} {$j < [llength $elem]} {incr j} {
		append result "\"female\": \"[lindex $elem 4]\", \"hombres\": \"[lindex $elem 5]\", \"total\": \"[lindex $elem 6]\"\},"

		set i [expr $i + 2]
	    }


{
	set day [clock scan [lindex [split $day "+"] 0]]
	set day [clock format $day -format "%d/%m"]

	set total_month [expr $total_day + $total_month]
	set female_month [expr $female_day + $female_month]
	set male_month [expr $male_day + $male_month]


	set total_female_10minus [expr $female1012 + $total_female_1012]
	set total_male_10minus [expr $male1012 + $total_male_1012]
	set total_age10minus [expr $age1012 + $total_age1012]

	set total_female1012 [expr $female1012 + $total_female1012]
	set total_male1012 [expr $male1012 + $total_male1012]
	set total_age1012 [expr $age1012 + $total_age1012]
	
	set total_female_1214 [expr $female1214 + $total_female1214]
	set total_male_1214 [expr $male1214 + $total_male1214]
	set total_age1214 [expr $age1214 + $total_age1214]

	set total_female1416 [expr $female1416 + $total_female1416]
	set total_male1416 [expr $male1416 + $total_male1416]
	set total_age1416 [expr $age1416 + $total_age1416]

	set total_female1618 [expr $female1618 + $total_female1618]
	set total_male1618 [expr $male1618 + $total_male1618]
	set total_age1618 [expr $age1618 + $total_age1618]

	set total_female_1820 [expr $female1820 + $total_female1820]
	set total_male1820 [expr $male1820 + $total_male1820]
	set total_age1820 [expr $age1820 + $total_age1820]

	set total_female_2022 [expr $female2022 + $total_female2022]
	set total_male_2022 [expr $male2022 + $total_male2022]
	set total_age2022 [expr $age20222 + $total_age2022]
	
	
	append result "\{\"day\": \"$day\", \"ranges\": \["
	append result "\{\"rangoEdad\": \"-10\", \"mujeres\": \"$female10minus\", \"hombres\": \"$male10minus\", \"total\": \"$age10minus\"\},"

	append result "\{\"rangoEdad\": \"12\", \"mujeres\": \"$female1012\", \"hombres\": \"$male1012\", \"total\": \"$age1012\"\},"
	append result "\{\"rangoEdad\": \"14\", \"mujeres\": \"$female1214\", \"hombres\": \"$male1214\", \"total\": \"$age1214\"\},"
	append result "\{\"rangoEdad\": \"16\", \"mujeres\": \"$female1416\", \"hombres\": \"$male1416\", \"total\": \"$age1416\"\},"
	append result "\{\"rangoEdad\": \"18\", \"mujeres\": \"$female1618\", \"hombres\": \"$male1618\", \"total\": \"$age1618\"\},"
	append result "\{\"rangoEdad\": \"20\", \"mujeres\": \"$female1820\", \"hombres\": \"$male1820\", \"total\": \"$age1820\"\},"
	append result "\{\"rangoEdad\": \"22\", \"mujeres\": \"$female2022\", \"hombres\": \"$male2022\", \"total\": \"$age2022\"\},"
	append result "\{\"rangoEdad\": \"24\", \"mujeres\": \"$female2224\", \"hombres\": \"$male2224\", \"total\": \"$age2224\"\},"
	append result "\{\"rangoEdad\": \"26\", \"mujeres\": \"$female2426\", \"hombres\": \"$male2426\", \"total\": \"$age2426\"\},"
	append result "\{\"rangoEdad\": \"28\", \"mujeres\": \"$female2628\", \"hombres\": \"$male2628\", \"total\": \"$age2628\"\},"
	append result "\{\"rangoEdad\": \"30\", \"mujeres\": \"$female2830\", \"hombres\": \"$male2830\", \"total\": \"$age2830\"\},"
	append result "\{\"rangoEdad\": \"32\", \"mujeres\": \"$female3032\", \"hombres\": \"$male3032\", \"total\": \"$age3032\"\},"
	append result "\{\"rangoEdad\": \"34\", \"mujeres\": \"$female3234\", \"hombres\": \"$male3234\", \"total\": \"$age3234\"\},"
	append result "\{\"rangoEdad\": \"36\", \"mujeres\": \"$female3436\", \"hombres\": \"$male3436\", \"total\": \"$age3436\"\},"
	append result "\{\"rangoEdad\": \"38\", \"mujeres\": \"$female3638\", \"hombres\": \"$male3638\", \"total\": \"$age3638\"\},"
	append result "\{\"rangoEdad\": \"40\", \"mujeres\": \"$female3840\", \"hombres\": \"$male3840\", \"total\": \"$age3840\"\},"
	append result "\{\"rangoEdad\": \"42\", \"mujeres\": \"$female4042\", \"hombres\": \"$male4042\", \"total\": \"$age4042\"\},"
	append result "\{\"rangoEdad\": \"44\", \"mujeres\": \"$female4244\", \"hombres\": \"$male4244\", \"total\": \"$age4244\"\},"
	append result "\{\"rangoEdad\": \"46\", \"mujeres\": \"$female4446\", \"hombres\": \"$male4446\", \"total\": \"$age4446\"\},"
	append result "\{\"rangoEdad\": \"48\", \"mujeres\": \"$female4648\", \"hombres\": \"$male4648\", \"total\": \"$age4648\"\},"
	append result "\{\"rangoEdad\": \"50\", \"mujeres\": \"$female4850\", \"hombres\": \"$male4850\", \"total\": \"$age4850\"\},"
	append result "\{\"rangoEdad\": \"52\", \"mujeres\": \"$female5052\", \"hombres\": \"$male5052\", \"total\": \"$age5052\"\},"
	append result "\{\"rangoEdad\": \"54\", \"mujeres\": \"$female5254\", \"hombres\": \"$male5254\", \"total\": \"$age5254\"\},"
	append result "\{\"rangoEdad\": \"56\", \"mujeres\": \"$female5456\", \"hombres\": \"$male5456\", \"total\": \"$age5456\"\},"
	append result "\{\"rangoEdad\": \"58\", \"mujeres\": \"$female5658\", \"hombres\": \"$male5658\", \"total\": \"$age5658\"\},"

	append result "\{\"rangoEdad\": \"+60\", \"mujeres\": \"$female60plus\", \"hombres\": \"$male60plus\", \"total\": \"$age60plus\"\}"
	append result "\]\},"
    }
    
    set result [string trimright $result ","]
    append result "\],
	\"total\": \"$total_month\",
	\"total_female_10\": \"$total_female_10minus\",
	\"total_male_10\": \"$total_male_10minus\",
	\"total_female_12\": \"$total_female_1012\",
	\"total_male_12\": \"$total_male_1012\",
	\"total_female_14\": \"$total_female_1214\",
	\"total_male_14\": \"$total_male_1214\",
	\"total_female_16\": \"$total_female_1416\",
	\"total_male_16\": \"$total_male_1416\",
	\"total_female_18\": \"$total_female_1618\",
	\"total_male_18\": \"$total_male_1618\",
	\"total_female_20\": \"$total_female_1820\",
	\"total_male_20\": \"$total_male_1820\",
	\"total_female_22\": \"$total_female_2022\",
	\"total_male_22\": \"$total_male_2022\",
	\"total_female_24\": \"$total_female_2224\",
	\"total_male_24\": \"$total_male_2224\",
	\"total_female_26\": \"$total_female_2426\",
	\"total_male_26\": \"$total_male_2426\",
	\"total_female_28\": \"$total_female_2628\",
	\"total_male_28\": \"$total_male_2628\",
	\"total_female_30\": \"$total_female_2830\",
	\"total_male_30\": \"$total_male_2830\",
	\"total_female_32\": \"$total_female_3032\",
	\"total_male_32\": \"$total_male_3032\",
	\"total_female_34\": \"$total_female_3234\",
	\"total_male_34\": \"$total_male_3234\",
	\"total_female_36\": \"$total_female_3436\",
	\"total_male_36\": \"$total_male_3436\",
	\"total_female_38\": \"$total_female_3638\",
	\"total_male_38\": \"$total_male_3638\",
	\"total_female_40\": \"$total_female_3840\",
	\"total_male_40\": \"$total_male_3840\",
	\"total_female_42\": \"$total_female_4042\",
	\"total_male_42\": \"$total_male_4042\",
	\"total_female_44\": \"$total_female_4244\",
	\"total_male_44\": \"$total_male_4244\",
	\"total_female_46\": \"$total_female_4446\",
	\"total_male_46\": \"$total_male_4446\",
	\"total_female_48\": \"$total_female_4648\",
	\"total_male_48\": \"$total_male_4648\",
	\"total_female_50\": \"$total_female_4850\",
	\"total_male_50\": \"$total_male_4850\",
	\"total_female_52\": \"$total_female_5052\",
	\"total_male_52\": \"$total_male_5052\",
	\"total_female_54\": \"$total_female_5254\",
	\"total_male_54\": \"$total_male_5254\",
	\"total_female_56\": \"$total_female_5456\",
	\"total_male_56\": \"$total_male_5456\",
	\"total_female_58\": \"$total_female_5658\",
	\"total_male_58\": \"$total_male5658\",
	\"total_female_60\": \"$total_female60plus\",
	\"total_male_60\": \"$total_male60plus\"\}"

}
