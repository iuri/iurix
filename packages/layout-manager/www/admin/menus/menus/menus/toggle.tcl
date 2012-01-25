# /packages/intranet-core/www/admin/toggle.tcl
#
# Copyright (C) 2004 Project/Open 
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

ad_page_contract {
    Add or remove "Menu" permissions<br>
    (permissions for members of one group to manage the members
    of another group).

    @author Frank Bergmann (frank.bergmann@project-open.com)
    @author Juanjo Ruiz (juanjoruizx@yahoo.es)
} {
    horiz_group_id:integer
    object_id:integer
    action
    { return_url "index"}
}

set current_user_id [ad_maybe_redirect_for_registration]
set current_user_is_admin_p [permission::permission_p -party_id $current_user_id -object_id [ad_conn package_id] -privilege admin]

if {!$current_user_is_admin_p} {
    ad_return_complaint 1 "You have insufficient privileges to use this page"
    return
}

switch $action {
    add_viewable {
	db_exec_plsql grant_viewable "select acs_permission__grant_permission($object_id,$horiz_group_id,'view')"
    }
    add_readable {
        db_exec_plsql grant_readable "select acs_permission__grant_permission($object_id,$horiz_group_id,'read')"
    }
    add_writable {
	db_exec_plsql grant_writable "select acs_permission__grant_permission($object_id,$horiz_group_id,'write')"
    }
    add_administratable {
	db_exec_plsql grant_administratable "select acs_permission__grant_permission($object_id,$horiz_group_id,'admin')"
    }
    remove_viewable {
	db_exec_plsql revoke_viewable "select acs_permission__revoke_permission($object_id,$horiz_group_id,'view')"
    }
    remove_readable {
        db_exec_plsql revoke_readable "select acs_permission__revoke_permission($object_id,$horiz_group_id,'read')"
    }
    remove_writable {
	db_exec_plsql revoke_writable "select acs_permission__revoke_permission($object_id,$horiz_group_id,'write')"
    }
    remove_administratable {
	db_exec_plsql revoke_administratable "select acs_permission__revoke_permission($object_id,$horiz_group_id,'admin')"
    }
    default {
	ad_return_complaint 1 "Unknown action: '$action'"
	return
    }
}

# Flush the global permissions cache so that the
# new changes become active.
#permission_flush
util_memoize_flush_regexp "ad.*"
util_memoize_flush_regexp "im.*"
util_memoize_flush_regexp "db.*"
util_memoize_flush_regexp "acs.*"
util_memoize_flush_regexp "file.*"

ad_returnredirect $return_url
