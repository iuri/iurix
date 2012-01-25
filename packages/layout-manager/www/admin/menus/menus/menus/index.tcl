# /packages/infoseg/www/admin/menus/index.tcl
#
# Copyright (C) 2004 Project/Open
# The code is based on ArsDigita ACS 3.4
#
# This program is free software. You can redistribute it
# and/or modify it under the terms of the GNU General
# Public License as published by the Free Software Foundation;
# either version 2 of the License, or (at your option)
# any later version. This program is distributed in the
# hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
#
# InfoSEG
# The code is based on Project/Open

ad_page_contract {
    Show the permissions for all menus in the system

    @author frank.bergmann@project-open.com

    @param top_menu_id Show only menus below "top_menu_id"
} {
    { return_url "" }
    { top_menu_id 0 }
    { top_menu_label "" }
    { group_id ""}
}

# ------------------------------------------------------
# Defaults & Security
# ------------------------------------------------------

set user_id [ad_maybe_redirect_for_registration]
set user_is_admin_p [permission::permission_p -party_id $user_id -privilege admin -object_id [ad_conn package_id]]
#set user_is_admin_p [acs_user::site_wide_admin_p -user_id $user_id]

set package_id [ad_conn package_id]

if {!$user_is_admin_p} {
    ad_return_complaint 1 "You have insufficient privileges to use this page"
    return
}

if {"" == $return_url} { set return_url [ad_conn url] }

set page_title "Menu Permissions"
set context_bar [list $page_title]
set context ""

subsite::get -array subsite_info
set subsite_url [site_node::get_url_from_object_id -object_id $subsite_info(package_id)]

ns_log notice "teste ----------------->: $subsite_url"

if {$subsite_url == "/"} {  
	set subsite_url ""
}
set menu_url "${subsite_url}/admin/menus/new"
set toggle_url "${subsite_url}/admin/menus/toggle"
set group_url "${subsite_url}/admin/groups/one"

set bgcolor(0) " class=rowodd"
set bgcolor(1) " class=roweven"

# ------------------------------------------------------
# Get the list of all relevant "Profiles"
# and generate the dynamic part of the SQL
# ------------------------------------------------------


if {$group_id == ""} {
	set group_list_sql {
	select DISTINCT
	        g.group_name,
	        g.group_id
	from
    	    acs_objects o,
	        groups g
	where
	        g.group_id = o.object_id
			and group_id in (-1)
	}
} else {
	set group_list_sql {
	select DISTINCT
	        o.title as group_name,
	        o.object_id as group_id
	from
    	    acs_objects o
	where
			object_id = :group_id
	}
}
set group_ids [list]

set group_names [list]
set table_header "
<tr>
  <td width=20></td>
  <td width=20></td>
  <td width=20></td>
  <td width=20></td>
  <td width=20></td>
  <td width=20></td>
  <td width=20></td>
  <td width=20></td>
  <td width=20></td>
  <td class=rowtitle>Package</td>\n"

set main_sql_select ""
set num_profiles 0
db_foreach group_list $group_list_sql {
    lappend group_ids $group_id
    lappend group_names $group_name
    append main_sql_select "acs_permission__permission_p(m.menu_id, $group_id, 'read') as p${group_id}_read_p,\n"
    #append table_header "
    #  <td class=rowtitle><A href=$group_url?group_id=$group_id>[im_gif $profile_gif $group_name]
    #</A></td>\n"
    append table_header "
      <td class=rowtitle><A href=$group_url?group_id=$group_id>$group_name
    </A></td>\n"
    incr num_profiles
}
#append table_header "
#  <td class=rowtitle>[im_gif del "Delete Menu"]</td>
#</tr>"

append table_header "
  <td class=rowtitle>#acs-subsite.Delete_menu#</td>
</tr>"


# ------------------------------------------------------
# Calculate the depth of the menus
# ------------------------------------------------------

# Only start recalculating if there is alteast
# one new menu in the hierarchy...
set altleast_one_new_menu [db_string new_menu "select count(*) from menus where tree_sortkey is null"]

if {1} {
    # Reset all tree_sortkey to null to indicate that the menu_items
    # need to be "processed"
    db_dml reset_menu_hierarchy "
	update menus
	set tree_sortkey = null
	where (select package_id from acs_objects where object_id = menus.menu_id) = :package_id
    "

    # Prepare the top menu
    set start_menu_id [db_string start_menu_id "select menu_id from menus where label='top'" -default 0]
    db_dml update_top_menu "update menus set tree_sortkey='.' where menu_id = :start_menu_id"

    set maxlevel 9
    set chars "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz"
    set continue 1
    set level 0
    while {$continue && $level < $maxlevel} {
	set continue 0
	# Get all menu items that have not been processed yet
	# (tree_sortkey is null) with parents that have been
	# processed already (tree_sortkey is not null)
	set sql "
	select
		m.menu_id,
		mm.menu_id as parent_id,
		mm.tree_sortkey as parent_sortkey
	from	
		menus m,
		menus mm
	where
		m.parent_menu_id = mm.menu_id
		and m.tree_sortkey is null
		and mm.tree_sortkey is not null
	order by parent_id, m.sort_order asc
	"

	set ctr 0
	db_foreach update_menus $sql {

	    # the new tree_sortkey is the parents tree_sortkey plus a 
	    # current letter starting with "A", "B", ...
	    set tree_sortkey "$parent_sortkey[string range $chars $ctr $ctr]"
	    
	    db_dml update_menu "update menus set tree_sortkey=:tree_sortkey where menu_id=:menu_id"
	    incr ctr
	    set continue 1
	}
	
	incr level
    }
}


# ------------------------------------------------------
# Main SQL: Extract the permissions for all Menus
# ------------------------------------------------------

# Restrict the list of menus to the tree starting
# with "top_menu_id":
#
set top_menu_sql ""

if {"" != $top_menu_label} {
    set top_menu_id [db_string top_menu_id "select menu_id from menus where label = :top_menu_label" -default 0]
}

if {$top_menu_id} {
    set top_menu_sortkey [db_string top_menu_sortkey "select tree_sortkey from menus where menu_id=:top_menu_id" -default ""]

    set top_menu_sql "and 
	m.tree_sortkey like '$top_menu_sortkey%'"
}

set main_sql "
select
	m.*,
	length(m.tree_sortkey) as indent_level,
	(9-length(m.tree_sortkey)) as colspan_level
from
	menus m,
	acs_objects ao
where
	1=1 $top_menu_sql
and ao.object_id = m.menu_id 
and ao.package_id = :package_id
order by tree_sortkey
"

set table "
<form action=menu-action method=post>
[export_form_vars return_url]
<table class=\"menu_table\">
$table_header\n"

set ctr 0
set old_package_name ""
db_foreach menus $main_sql {
    incr ctr

    append table "\n<tr$bgcolor([expr $ctr % 2])>\n"

    if {0 != $indent_level} {
	append table "\n<td colspan=$indent_level>&nbsp;</td>"
    }

    append table "
  <td colspan=$colspan_level>
    <A href=$menu_url?menu_id=$menu_id&return_url=$return_url>$name</A><br>$label
  </td>
  <td>$package_name</td>
"

    foreach horiz_group_id $group_ids {
    set read_p [permission::permission_p -object_id $menu_id -party_id ${horiz_group_id} -privilege read]
	set object_id $menu_id
	set action "add_readable"
	set letter "r"
        if {$read_p == "1"} {
            set read "<A href=$toggle_url?object_id=$menu_id&action=remove_readable&[export_url_vars horiz_group_id return_url]><b>R</b></A>\n"
	    set action "remove_readable"
	    set letter "<b>R</b>"
        }
	set read "<A href=$toggle_url?[export_url_vars horiz_group_id object_id action return_url]>$letter</A>\n"

        append table "
  <td align=center>
    $read
  </td>
"
    }

    append table "
  <td>
    <input type=checkbox name=menu_id.$menu_id>
  </td>
</tr>
"
}

append table "
<tr>
  <td colspan=[expr $num_profiles + 6] align=right>
    <A href=new?[export_url_vars return_url]>New Menu</a>
  </td>
  <td>
    <input type=submit value='Del'>
  </td>
</tr>
</table>
</form>
"
