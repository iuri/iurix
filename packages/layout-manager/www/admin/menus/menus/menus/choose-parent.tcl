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
}


# ------------------------------------------------------
# Defaults & Security
# ------------------------------------------------------

set top_menu_sql ""
set url [ns_set get [ad_conn headers] Referer]
set url [string trim $url "http://"]
set start [string first "/" $url]

set referal_url [string range $url $start [expr [string length $url] - 1]]


set user_id [ad_maybe_redirect_for_registration]
set user_is_admin_p [permission::permission_p -party_id $user_id -object_id [ad_conn package_id] -privilege admin]
if {!$user_is_admin_p} {
	ad_script_abort
}

set package_id [ad_conn package_id]
set menu_url "choose-parent2"
set return_url ""
set num_profiles 0

set context ""
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
  \n"

set bgcolor(0) " class=rowodd"
set bgcolor(1) " class=roweven"



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
<table>
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
    <A href=$menu_url?parent_menu_id=$menu_id&url=$referal_url>$name</A><br>$label
  </td>
"

    append table "
</tr>
"
}

append table "
</table>
</form>
"
