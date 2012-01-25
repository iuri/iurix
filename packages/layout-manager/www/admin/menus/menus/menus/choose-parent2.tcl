# /packages/intranet-core/www/admin/menus/new.tcl
#
# Copyright (C) 2003-2004 Project/Open
#
# All rights reserved. Please check
# http://www.project-open.com/license/ for details.

ad_page_contract {
    Create a new dynamic value or edit an existing one.

    @param form_mode edit or display

    @author frank.bergmann@project-open.com
} {
    menu_id:integer,optional
    parent_menu_id
    url
    {return_url ""}
}


# ------------------------------------------------------------------
# Default & Security
# ------------------------------------------------------------------

set user_id [ad_maybe_redirect_for_registration]
set user_is_admin_p [permission::permission_p -party_id $user_id -object_id [ad_conn package_id] -privilege admin]
if {!$user_is_admin_p} {
    ad_return_complaint 1 "You have insufficient privileges to use this page"
    return
}

set package_id [ad_conn package_id]

set action_url "/admin/menus/new"
set focus "menu.var_name"
set page_title "New Menu"
set context [list $page_title]

if {![info exists menu_id]} { set form_mode "edit" }


# ------------------------------------------------------------------
# Build the form
# ------------------------------------------------------------------

set parent_options [menus::parent_options]

ad_form \
    -name menu \
    -cancel_url $return_url \
    -export {return_url package_id} \
    -form {
	menu_id:key
	{name:text(text) {label Name} {html {size 40}}}
	{url:text(hidden) {value $url}}
	{parent_menu_id:text(hidden) {value $parent_menu_id} }
    }


ad_form -extend -name menu -on_request {
    # Populate elements from local variables

} -select_query {

	select	m.*
	from	menus m
	where	m.menu_id = :menu_id

} -new_data {
    set label [lang::util::suggest_key $name]


    regsub -all " " $name "_" messagekey

    ## Create Message Key for this menu. Only in en_US.
    lang::message::register en_US acs-subsite $messagekey $name

    set package_name "acs-subsite"
    set sort_order [menus::get_next_sort_order $parent_menu_id]

    db_exec_plsql menu_insert {}

} -edit_data {

	set label [lang::util::suggest_key $name]
    regsub -all " " $name "_" messagekey

    ## Create Message Key for this menu. Only in en_US.
    lang::message::register en_US acs-subsite $messagekey $name


    db_dml menu_update "
	update menus set
	        package_name    = :package_name,
	        label           = :label,
	        name            = :name,
	        url             = :url,
	        sort_order      = :sort_order,
	        parent_menu_id  = :parent_menu_id,
	        visible_tcl	= :visible_tcl
	where
		menu_id = :menu_id
"
} -on_submit {

	ns_log Notice "new1: on_submit"


} -after_submit {

	ad_returnredirect $url
	ad_script_abort
}

