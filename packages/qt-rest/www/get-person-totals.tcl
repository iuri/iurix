# /packages/qt-rest/www/get-person-totals.tcl
ad_page_contract {
    API REST method to return cr_items qt_face
} {
    {group_id:integer 0}
    {date_from:optional}
    {date_to:optional}
    {age_range_p:boolean,optional}
    {heatmap_p:boolean,optional}
}
ns_log Notice "Running TCL script get-person-totals.tcl"

# Validate and Authenticate JWT
qt::rest::jwt::validation_p
ns_log Notice "GROUPID $group_id "
# group::get -group_id $group_id -array group
# ns_log Notice "[parray group]"




set creation_date [db_string select_now { SELECT date(now() - INTERVAL '5 hour') FROM dual}]
set content_type qt_face
set where_clauses ""

if {[info exists date_from]} {
    if {![catch {set t [clock scan $date_from]} errmsg]} {
	append where_clauses " AND o.creation_date::date >= :date_from::date"
    } else {
	ns_respond -status 422 -type "text/plain" -string "Unprocessable Entity! $errmsg"
	ad_script_abort    
    }
}


if {[info exists date_to]} {
    if {![catch {set t [clock scan $date_to]} errmsg]} {
	append where_clauses " AND o.creation_date::date <= :date_to::date "
    } else {
	ns_respond -status 422 -type "text/plain" -string "Unprocessable Entity! $errmsg"
	ad_script_abort    
    }
}




# Retrieves vehicles grouped by hour
# Reference: https://popsql.com/learn-sql/postgresql/how-to-group-by-time-in-postgresql
set weekly_data [db_list_of_lists select_week_totals_totem "
    SELECT date_trunc('day', o.creation_date) AS day,
    COUNT(CASE WHEN SPLIT_PART(f.description, ' ', 37) = 'CCPN001\}' THEN 1 END),
    COUNT(CASE WHEN SPLIT_PART(f.description, ' ', 37) = 'CCPN002\}' THEN 1 END),
    COUNT(CASE WHEN SPLIT_PART(f.description, ' ', 8) = '0' AND SPLIT_PART(f.description, ' ', 37) = 'CCPN001\}' THEN f.item_id END),
    COUNT(CASE WHEN SPLIT_PART(f.description, ' ', 8) = '0' AND SPLIT_PART(f.description, ' ', 37) = 'CCPN002\}' THEN f.item_id END),
    COUNT(CASE WHEN SPLIT_PART(f.description, ' ', 8) = '1' AND SPLIT_PART(f.description, ' ', 37) = 'CCPN001\}' THEN f.item_id END),
    COUNT(CASE WHEN SPLIT_PART(f.description, ' ', 8) = '1' AND SPLIT_PART(f.description, ' ', 37) = 'CCPN002\}' THEN f.item_id END)
    FROM qt_face_tx f, acs_objects o WHERE f.item_id = o.object_id
    AND o.creation_date::date > :creation_date::date - INTERVAL '14 days'
    GROUP BY 1 ORDER BY day"]


# weekly_data Format
# list date total1 total2 female1 female2 male1 male2

# ns_log Notice "Weekly data $weekly_data"


# list date total1 total2 female1 female2 male1 male2
set today_totals [lindex $weekly_data end]

# list date total1 total2 female1 female2 male1 male2
set yesterday_totals [lindex $weekly_data end-1]


set i 0
set previous_week_totals [list 0 0 0]
set week_totals [list 0 0 0]
foreach elem $weekly_data {
    #    ns_log Notice "ELEM $elem"
    if {$i < 8} {
        set previous_week_totals [list \
				      [expr [lindex $previous_week_totals 0] + [lindex $elem 1]] \
				      [expr [lindex $previous_week_totals 1] + [lindex $elem 2]] \
				      [expr [lindex $previous_week_totals 2] + [lindex $elem 3]] \
				      [expr [lindex $previous_week_totals 3] + [lindex $elem 4]] \
				      [expr [lindex $previous_week_totals 4] + [lindex $elem 5]] \
				      [expr [lindex $previous_week_totals 5] + [lindex $elem 6]] ]
    } else {
	set week_totals [list \
			     [expr [lindex $week_totals 0] + [lindex $elem 1]] \
			     [expr [lindex $week_totals 1] + [lindex $elem 2]] \
			     [expr [lindex $week_totals 2] + [lindex $elem 3]] \
			     [expr [lindex $week_totals 3] + [lindex $elem 4]] \
			     [expr [lindex $week_totals 4] + [lindex $elem 5]] \
			     [expr [lindex $week_totals 5] + [lindex $elem 6]] ]	
    }
    incr i
}


# Percentage & maths
## Today # list date total1 total2 female1 female2 male1 male2
### Totem1

if { [lindex $today_totals 1] ne 0 && [lindex $yesterday_totals 1] ne 0 } {
    lappend percentages [format "%.2f" [expr [format "%.2f" [expr [expr [lindex $today_totals 1] * 100] / [lindex $yesterday_totals 1]] ] / 100]]
    # ns_log Notice "TODAY TOTEM1 % [lindex $today_totals 1]  [lindex $yesterday_totals 1] [lindex $percentages 0]" 
} else {
    lappend percentages 0
}


### Totem2
if { [lindex $today_totals 2] ne 0 && [lindex $yesterday_totals 2] ne 0 } {
    lappend percentages [format "%.2f" [expr [format "%.2f" [expr [expr [lindex $today_totals 2] * 100] / [lindex $yesterday_totals 2]] ] / 100]]
    # ns_log Notice "TODAY TOTEM2 % [lindex $today_totals 1]  [lindex $yesterday_totals 1] [lindex $percentages 1]" 
} else {
    lappend percentages 0
}

### Total
if { [expr [lindex $today_totals 1] + [lindex $today_totals 2]] ne 0 && [expr [lindex $yesterday_totals 1] + [lindex $yesterday_totals 2]] ne 0 } {
    lappend percentages [format "%.2f" [expr [format "%.2f" [expr [expr [expr [lindex $today_totals 1] + [lindex $today_totals 2]] * 100] / [expr [lindex $yesterday_totals 1] + [lindex $yesterday_totals 2]] ]] / 100]]
    # ns_log Notice "TODAY TOTEM1 % [lindex $today_totals 1]  [lindex $yesterday_totals 1] [lindex $percentages 0]" 
} else {
    lappend percentages 0
}







## Week
### Totem1
if {[lindex $week_totals 0] ne 0 && [lindex $previous_week_totals 0] ne 0} {
    lappend percentages [format "%.2f" [expr [format "%.2f" [expr [expr [lindex $week_totals 0] * 100] / [lindex $previous_week_totals 0]]] / 100]]
   # ns_log Notice "WEEK TOTEM1 % [lindex $week_totals 0] [lindex $previous_week_totals 0] [lindex $percentages 2]"
    
} else {
    lappend percentages 0
}

### Totem2
if {[lindex $week_totals 1] ne 0 && [lindex $previous_week_totals 1] ne 0} {
    lappend percentages [format "%.2f" [expr [format "%.2f" [expr [expr [lindex $week_totals 1] * 100] / [lindex $previous_week_totals 1]]] / 100]]
    # ns_log Notice "WEEK TOTEM2 % [lindex $week_totals 1] [lindex $previous_week_totals 1] [lindex $percentages 3]"
    
} else {
    lappend percentages 0
}

### Total
if {[expr [lindex $week_totals 0] + [lindex $week_totals 1]] ne 0 && [expr [lindex $previous_week_totals 0] + [lindex $previous_week_totals 1]] ne 0} {
    lappend percentages [format "%.2f" [expr [format "%.2f" [expr [expr [expr [lindex $week_totals 0] + [lindex $week_totals 1]] * 100] / [expr [lindex $previous_week_totals 0] + [lindex $previous_week_totals 1]]]] / 100]]
    # ns_log Notice "WEEK TOTEM2 % [lindex $week_totals 1] [lindex $previous_week_totals 1] [lindex $percentages 3]"
    
} else {
    lappend percentages 0
}



# Total
db_0or1row select_totems_totals "
    SELECT
    COUNT(CASE WHEN SPLIT_PART(f.description, ' ', 37) = 'CCPN001\}' THEN 1 END) AS total_totem1,
    COUNT(CASE WHEN SPLIT_PART(f.description, ' ', 37) = 'CCPN002\}' THEN 1 END) AS total_totem2,
    COUNT(CASE WHEN SPLIT_PART(f.description, ' ', 8) = '0' AND SPLIT_PART(f.description, ' ', 37) = 'CCPN001\}' THEN f.item_id END) AS total_female1,
    COUNT(CASE WHEN SPLIT_PART(f.description, ' ', 8) = '0' AND SPLIT_PART(f.description, ' ', 37) = 'CCPN002\}' THEN f.item_id END) AS total_female2,
    COUNT(CASE WHEN SPLIT_PART(f.description, ' ', 8) = '1' AND SPLIT_PART(f.description, ' ', 37) = 'CCPN001\}' THEN f.item_id END) AS total_male1,
    COUNT(CASE WHEN SPLIT_PART(f.description, ' ', 8) = '1' AND SPLIT_PART(f.description, ' ', 37) = 'CCPN002\}' THEN f.item_id END) AS total_male2
    FROM qt_face_tx f"


append result "\{
    \"totemone\": \{	
	\"today\": \{
	    \"count\": [lindex $today_totals 1],
            \"percent\": [lindex $percentages 0],
	    \"female\": [lindex $today_totals 3],
	    \"male\": [lindex $today_totals 5]
	\},
	\"yesterday\": \{
	    \"total\": [lindex $yesterday_totals 1],
	    \"female\": [lindex $yesterday_totals 3],
	    \"male\": [lindex $yesterday_totals 5]
	\},
	\"week\": \{
	    \"total\": [lindex $week_totals 0],
            \"percent\": [lindex $percentages 3],
	    \"female\": [lindex $week_totals 2],
	    \"male\": [lindex $week_totals 4]
	\},
	\"total\": \{
	    \"count\": $total_totem1,
	    \"female\": $total_female1,
	    \"male\": $total_male1
	\}
    \},
    \"totemtwo\": \{	
	\"today\": \{
	    \"count\": [lindex $today_totals 2],
            \"percent\": [lindex $percentages 1],
	    \"female\": [lindex $today_totals 4],
	    \"male\": [lindex $today_totals 6]
	\},
	\"yesterday\": \{
	    \"total\": [lindex $yesterday_totals 2],
	    \"female\": [lindex $yesterday_totals 4],
	    \"male\": [lindex $yesterday_totals 6]
	\},
	\"week\": \{
	    \"total\": [lindex $week_totals 1],
            \"percent\": [lindex $percentages 4],
	    \"female\": [lindex $week_totals 3],
	    \"male\": [lindex $week_totals 5]
	\},
	\"total\": \{
	    \"count\": $total_totem2,
	    \"female\": $total_female2,
	    \"male\": $total_male2
	\}
    \},
    \"totemtotal\": \{
	\"today\": \{
	    \"count\": [expr [lindex $today_totals 1] + [lindex $today_totals 2]],
            \"percent\": [lindex $percentages 2],
	    \"female\": [expr [lindex $today_totals 3] + [lindex $today_totals 4]],
	    \"male\": [expr [lindex $today_totals 5] + [lindex $today_totals 6]]
        \},
	\"yesterday\": \{
	    \"total\": [expr [lindex $yesterday_totals 1] +  [lindex $yesterday_totals 2]],
	    \"female\": [expr [lindex $yesterday_totals 3] +  [lindex $yesterday_totals 4]],
	    \"male\": [expr [lindex $yesterday_totals 5] +  [lindex $yesterday_totals 6]]
	\},
	\"week\": \{
	    \"total\": [expr [lindex $week_totals 0] +  [lindex $week_totals 1]],
            \"percent\": [lindex $percentages 5],
	    \"female\": [expr [lindex $week_totals 2] +  [lindex $week_totals 3]],
	    \"male\": [expr [lindex $week_totals 4] +  [lindex $week_totals 5]]
	\},
	\"total\": \{
	    \"count\": [expr $total_totem1 + $total_totem2],
	    \"female\": [expr $total_female1 + $total_female2],
	    \"male\": [expr $total_male1 + $total_male2]
	\}
    \}
\}"


ns_respond -status 200 -type "application/json" -string $result
ad_script_abort
