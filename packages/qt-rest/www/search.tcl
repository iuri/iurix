ad_page_contract {
    @author Neophytos Demetriou <k2pts@cytanet.com.cy>
    @creation-date September 01, 2001
    @cvs-id $Id: search.tcl,v 1.40.2.7 2017/02/05 11:40:32 gustafn Exp $
} {
    {q:trim ""}
    {t:trim ""}
    {date_from:optional}
    {date_to:optional}
    {offset:naturalnum,notnull 0}
    {num:range(0|200) 0}
    {dfs:word,trim,notnull ""}
    {dts:word,trim,notnull ""}
    {search_package_id:naturalnum ""}
    {scope ""}
    {page 0}
    {object_type:token ""}
} -validate {
    valid_dfs -requires dfs {
        if {![array exists symbol2interval]} {
            array set symbol2interval [parameter::get -package_id [ad_conn package_id] -parameter Symbol2Interval]
        }
        if {$dfs ni [array names symbol2interval]} {
            ad_complain "dfs: invalid interval"
        }
    }
    valid_dts -requires dts {
        if {![array exists symbol2interval]} {
            array set symbol2interval [parameter::get -package_id [ad_conn package_id] -parameter Symbol2Interval]
        }
        if {$dts ni [array names symbol2interval]} {
            ad_complain "dts: invalid interval"
        }
    }
    
}

# Validate and Authenticate JWT
qt::rest::jwt::validation_p

set creation_date [db_string select_now { SELECT date(now() - INTERVAL '5 hour') FROM dual}]
set where_clauses ""

if {[info exists date_from]} {
    if {![catch {set t [clock scan $date_from]} errmsg]} {
	append where_clauses " AND cr.creation_date::date >= :date_from::date "
	
    } else {
	ns_respond -status 422 -type "text/plain" -string "Unprocessable Entity! $errmsg"
	ad_script_abort    
    }
}


if {[info exists date_to]} {
    if {![catch {set t [clock scan $date_to]} errmsg]} {
	append where_clauses " AND cr.creation_date::date <= :date_to::date"
    } else {
	ns_respond -status 422 -type "text/plain" -string "Unprocessable Entity! $errmsg"
	ad_script_abort    
    }
}



set page_title "Search Results"

set package_id [apm_package_id_from_key search]
set package_url "/search/"
set package_url_with_extras $package_url

set context Results
set context_base_url $package_url

# Do we want debugging information at the end of the page
set debug_p 0

set user_id [ad_conn user_id]
set driver [parameter::get -package_id $package_id -parameter FtsEngineDriver]

db_0or1row select_top_plate "
    SELECT cr.title,
    MAX(cr.creation_date) AS creation_date,
    COUNT(*) AS occurency
    FROM cr_items ci,
    cr_revisionsx cr
    WHERE ci.item_id = cr.item_id
    AND ci.content_type = 'qt_vehicle'
    AND cr.title <> 'UNKNOWN'
    AND cr.title <> '111111'
    AND cr.title <> '333333'
    AND cr.title <> 'FBF724'
    AND cr.title <> 'FBF124'
    GROUP BY cr.title
    HAVING COUNT(*) > 1
    ORDER BY COUNT(*) DESC
    LIMIT 1
" -column_array top_plate

db_0or1row select_top_plate_month "
    SELECT cr.title,
    MAX(cr.creation_date) AS creation_date,
    COUNT(*) AS occurency
    FROM cr_items ci,
    cr_revisionsx cr
    WHERE ci.item_id = cr.item_id
    AND ci.content_type = 'qt_vehicle'
    AND cr.title <> 'UNKNOWN'
    AND cr.title <> '111111'
    AND cr.title <> '333333'
    AND cr.title <> 'FBF724'
    AND cr.title <> 'FBF124'
    $where_clauses
    GROUP BY cr.title
    HAVING COUNT(*) > 1
    ORDER BY COUNT(*) DESC
    LIMIT 1
" -column_array top_plate_month


set top_plate(description) [db_string select_description "
    SELECT cr.description FROM cr_revisionsx cr
    WHERE cr.title = '$top_plate(title)'
    AND cr.creation_date = '$top_plate(creation_date)'
" -default ""]

set top_plate_month(description) [db_string select_description "
    SELECT cr.description FROM cr_revisionsx cr WHERE cr.title = '$top_plate_month(title)' AND cr.creation_date = '$top_plate_month(creation_date)'
" -default ""]


append json "\{
    \"top_plate\": \{
        \"plate\": \"$top_plate(title)\",
        \"date\": \"[lc_time_fmt $top_plate(creation_date) %Y-%m-%d]\",
        \"time\": \"[lc_time_fmt $top_plate(creation_date) %H:%M]\",
        \"location\": \"4.60971, -74.08175\",
        \"occurency\": \"$top_plate(occurency)\",
        \"client_p\": true,
        \"membership_p\": false
    \},
    \"top_plate_month\": \{
        \"plate\": \"$top_plate_month(title)\",
        \"date\": \"[lc_time_fmt $top_plate_month(creation_date) %Y-%m-%d]\",
        \"time\": \"[lc_time_fmt $top_plate_month(creation_date) %H:%M]\",
        \"location\": \"4.60971, -74.08175\",
        \"occurency\": \"$top_plate_month(occurency)\",
        \"client_p\": true,
        \"membership_p\": false
    \},"


if {[callback::impl_exists -impl $driver -callback search::driver_info]} {
    array set info [lindex [callback -impl $driver search::driver_info] 0]
    #    array set info [list package_key intermedia-driver version 1 automatic_and_queries_p 1  stopwords_p 1]
} else {
    array set info [acs_sc::invoke -contract FtsEngineDriver -operation info -call_args [list] -impl $driver]
}

if { [array get info] eq "" } {
    ns_return 200 text/html [_ search.lt_FtsEngineDriver_not_a]
    ad_script_abort
}

if { $num <= 0} {
    set limit [parameter::get -package_id $package_id -parameter LimitDefault]
} else {
    set limit $num
}


#
# Work out the date restriction 
#
set df ""
set dt ""

if { $dfs eq "all" } {
    set dfs ""
}

if { $dfs ne "" } {
    set df [db_exec_plsql get_df "select now() + '$symbol2interval($dfs)'::interval"]
}
if { $dts ne "" } {
    set dt [db_exec_plsql get_dt "select now() + '$symbol2interval($dts)'::interval"]
}

#set q [string tolower $q]
set urlencoded_query [ad_urlencode $q]

set params [list $q $offset $limit $user_id $df]
if {$search_package_id eq "" && [parameter::get -package_id $package_id -parameter SubsiteSearchP -default 1]
    && [subsite::main_site_id] != [ad_conn subsite_id]} {
    # We are in a subsite and SubsiteSearchP is true
    set subsite_packages [concat [ad_conn subsite_id] [subsite::util::packages -node_id [ad_conn node_id]]]
    lappend params $subsite_packages
    set search_package_id $subsite_packages
} elseif {$search_package_id ne ""} { 
    lappend params $search_package_id
}

set t0 [clock clicks -milliseconds]

# TODO calculate subsite or dotlrn package_ids
if {"this" ne $scope } {
    # don't send package_id if its not searching this package
    # set search_package_id "" ;# don't overwrite this, when you are restricting search to package_id
} else {
    set search_node_id [site_node::get_node_id_from_object_id -object_id $search_package_id]
    if {"dotlrn" eq [site_node::get_element -node_id $search_node_id -element package_key]} {
	set search_package_id [site_node::get_children -node_id $search_node_id -element package_id]
    }
}

if {[callback::impl_exists -impl $driver -callback search::search]} {
    # DAVEB TODO Add subsite to the callback def?
    # FIXME do this in the intermedia driver!
    #    set final_query_string [db_string final_query_select "select site_wide_search.im_convert(:q) from dual"]

    array set result [lindex [callback -impl $driver search::search \
                                  -query $q -offset $offset -limit $limit \
				  -user_id $user_id -df $df \
				  -extra_args [list package_ids $search_package_id object_type $object_type]] 0]
} else {
    array set result [acs_sc::invoke -contract FtsEngineDriver -operation search \
			  -call_args $params -impl $driver]
}

set tend [clock clicks -milliseconds]

if { $t eq [_ search.Feeling_Lucky] && $result(count) > 0} {
    set object_id [lindex $result(ids) 0]
    set object_type [acs_object_type $object_id]
    if {[callback::impl_exists -impl $object_type -callback search::url]} {
	set url [callback -impl $object_type search::url -object_id $object_id]
    } else {
	set url [acs_sc::invoke -contract FtsContentProvider -operation url \
		     -call_args [list $object_id] -impl $object_type]
    }
    ad_returnredirect $url
    ad_script_abort
}

set elapsed [format "%.02f" [expr {double(abs($tend - $t0)) / 1000.0}]]
#
# $count is the number of results to be displayed, while
# $result(count) is the total number of results (without taking
# permissions into account)
#
set count [llength $result(ids)]
if { $offset >= $result(count) } { set offset [expr {($result(count) / $limit) * $limit}] }
set low  [expr {$offset + 1}]
set high [expr {$offset + $limit}]
if { $high > $result(count) } { set high $result(count) }

if { $info(automatic_and_queries_p) && "and" in $q } {
    set and_queries_notice_p 1
} else {
    set and_queries_notice_p 0
}

set url_advanced_search ""
append url_advanced_search "advanced-search?q=$urlencoded_query"
if {[info exists ::__csrf_token]} {append url_advanced_search "&__csrf_token=$::__csrf_token"}
if { $num > 0 } { append url_advanced_search "&num=$num" }

set query $q
set nquery [llength [split $q]]
set stopwords $result(stopwords)
set nstopwords [llength $result(stopwords)] 

ns_log Notice "    SELECT COUNT(cr.title)
    FROM cr_items ci,
    cr_revisionsx cr
    WHERE ci.item_id = cr.item_id
    AND ci.content_type = 'qt_vehicle'
    AND cr.title <> 'UNKNOWN'
    AND cr.title <> '111111'
    AND cr.title <> '333333'
    AND cr.title <> 'FBF724'
    $where_clauses
    GROUP BY cr.title
    HAVING COUNT(*) >= 1"

set total_records [db_list select_total_pages "
    SELECT COUNT(cr.title)
    FROM cr_items ci,
    cr_revisionsx cr
    WHERE ci.item_id = cr.item_id
    AND ci.content_type = 'qt_vehicle'
    AND cr.title <> 'UNKNOWN'
    AND cr.title <> '111111'
    AND cr.title <> '333333'
    AND cr.title <> 'FBF724'
    AND cr.title <> 'FBF124'
    $where_clauses
    GROUP BY cr.title
    HAVING COUNT(*) >= 1
"]
append json "\"pages\": [expr [llength $total_records] /10],"

append json "\"plates\": \["
set aux ""
foreach object_id $result(ids) {
    if {[catch {
        set object_type [acs_object_type $object_id]
        if {[callback::impl_exists -impl $object_type -callback search::datasource]} {
            array set datasource [lindex [callback -impl $object_type search::datasource -object_id $object_id] 0]
            set url_one [lindex [callback -impl $object_type search::url -object_id $object_id] 0]
        } else {
            #ns_log warning "SEARCH search/www/search.tcl callback::datasource::$object_type not found"
            array set datasource [acs_sc::invoke -contract FtsContentProvider -operation datasource \
				      -call_args [list $object_id] -impl $object_type]
            
            set url_one [acs_sc::invoke -contract FtsContentProvider -operation url \
			     -call_args [list $object_id] -impl $object_type]
        }
        
        search::content_get txt $datasource(content) $datasource(mime) $datasource(storage_type) $object_id
        if {[callback::impl_exists -impl $driver -callback search::summary]} {
            set title_summary [lindex [callback -impl $driver search::summary -query $q -text $datasource(title)] 0]
            set txt_summary [lindex [callback -impl $driver search::summary -query $q -text $txt] 0]
        
        } else {
            set title_summary [acs_sc::invoke -contract FtsEngineDriver -operation summary \
				   -call_args [list $q $datasource(title)] -impl $driver]
            set txt_summary [acs_sc::invoke -contract FtsEngineDriver -operation summary \
				 -call_args [list $q $txt] -impl $driver]
        
        }
    } errmsg]} {
        ns_log error "search.tcl object_id $object_id object_type $object_type error $errmsg"
    } else {
        set title_summary [string map {"<b>" "" "</b>" ""} $title_summary]
        # set creation_date [lc_time_fmt [db_string select_creation_date { SELECT creation_date FROM acs_objects WHERE object_id = :object_id } -default ""] "%q %X" "es_ES"]
        db_0or1row select_object {
            SELECT o.creation_date, cr.description
            FROM cr_revisions cr, acs_objects o
            WHERE o.object_id = cr.revision_id
            AND cr.revision_id = :object_id 
        }
        
        set occurency [db_string select_revision_count { SELECT COUNT(revision_id) FROM cr_revisions WHERE item_id = (SELECT item_id FROM cr_revisions WHERE revision_id = :object_id) } -default 0]
        
        append json "\{
            \"plate\": \"$title_summary\",
            \"date\": \"[lc_time_fmt $creation_date %Y-%m-%d]\",
            \"time\": \"[lc_time_fmt $creation_date %H:%M]\",
            \"location\": \"4.60971, -74.08175\",
            \"occurency\": \"$occurency\",
            \"client_p\": true,
            \"membership_p\": false
        \},"
    }
}


# order by date DESC, pagination

if { $result(count) eq 0 } {
    set offset [expr $page * 10]
    
    db_foreach select_vehicles "
        SELECT cr.title,
        MAX(cr.creation_date) AS creation_date,
        COUNT(*) AS occurency
        FROM cr_items ci,
        cr_revisionsx cr
        WHERE ci.item_id = cr.item_id
        AND ci.content_type = 'qt_vehicle'
        AND cr.title <> 'UNKNOWN'
        AND cr.title <> '111111'
        AND cr.title <> '333333'
        AND cr.title <> 'FBF724'
        AND cr.title <> 'FBF124'
        $where_clauses 
        GROUP BY cr.title
        HAVING COUNT(*) > 1
        ORDER BY MAX(cr.creation_date) DESC 
        LIMIT 10 OFFSET $offset;
        
    " {
        set description [db_string select_description {
            SELECT cr.description FROM cr_revisionsx cr WHERE cr.title = :title AND cr.creation_date = :creation_date
        } -default ""]
        append json "\{
            \"plate\": \"$title\",
            \"date\": \"[lc_time_fmt $creation_date %Y-%m-%d]\",
            \"time\": \"[lc_time_fmt $creation_date %H:%M:%S]\",
            \"location\": \"4.60971, -74.08175\",
            \"occurency\": \"$occurency\",
            \"client_p\": false,
            \"membership_p\": false
        \},"


    
    }
}


set json [string trimright $json ","]
append json "\]\}"



ns_respond -status 200 -type "application/json" -string $json
ad_script_abort

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
