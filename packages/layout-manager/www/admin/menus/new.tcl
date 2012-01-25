# /packages/intranet-core/www/admin/menus/new.tcl
#
# Copyright (C) 2003-2004 ]project-open[
#
# All rights reserved. Please check
# http://www.project-open.com/license/ for details.

ad_page_contract {
    Create a new dynamic value or edit an existing one.

    @param form_mode edit or display

    @author frank.bergmann@project-open.com
} {
    menu_id:integer,optional
    return_url
    edit_p:optional
    message:optional
    {url ""}
   { form_mode "edit" }
}


# ------------------------------------------------------------------
# Default & Security
# ------------------------------------------------------------------

set user_id [ad_maybe_redirect_for_registration]
set user_is_admin_p [acs_user::site_wide_admin_p -user_id $user_id]
if {!$user_is_admin_p} {
    ad_return_complaint 1 "You have insufficient privileges to use this page"
    return
}

subsite::get -array subsite_info
set package_id $subsite_info(package_id)
set base_url [site_node::get_url_from_object_id -object_id $package_id]


set action_url [export_vars -base ${base_url}admin/menus/new {}]
set focus "menu.var_name"
set page_title "Edit Menu"
set current_url [ad_conn url]?[ad_conn query]

set object_id 0
if {![info exists menu_id]} { 
    set form_mode "edit" 
    set page_title "New Menu"
} else {
    set object_id $menu_id
}

set context $page_title

# ------------------------------------------------------------------
# Build the form
# ------------------------------------------------------------------

set parent_options [menus::parent_options -package_id $package_id]
set package_options [layout::package_options]

ad_form \
    -name menu \
    -cancel_url $return_url \
    -action $action_url \
    -mode $form_mode \
    -export {next_url user_id return_url} \
    -form {
	menu_id:key
	{name:text(text) {label Name} {html {size 40}}}
	{package_id:integer(select) {label "#layout-manager.Package#"} {options $package_options}}
	{label:text(text) {label Label} {html {size 30}}}
	{url:text(text) {label URL} {value $url} {html {size 100}}}
	{sort_order:text(text) {label "Sort Order"} {html {size 10}}}
	{parent_menu_id:text(select) {label "Parent Menu"} {options $parent_options} }
	{visible_tcl:text(text),optional {label "Visible TCL"} {html {size 100}}}
	{enabled_p:text(radio),optional {label "Enabled?"} {options {{True t} {False f}}} }
	
    }


ad_form -extend -name menu -on_request {
    # Populate elements from local variables

} -select_query {

	select	m.*
	from	layout_menus m
	where	m.menu_id = :menu_id

} -new_data {

    set package_name [apm_package_key_from_id $package_id]

    set menu_id [db_string menu_insert {}]

    db_dml menu_update "
	update layout_menus set
	        package_name    = :package_name,
	        label           = :label,
	        name            = :name,
	        url             = :url,
	        sort_order      = :sort_order,
	        parent_menu_id  = :parent_menu_id,
	        visible_tcl	= :visible_tcl,
		enabled_p	= :enabled_p
	where
		menu_id = :menu_id
    "

} -edit_data {

    set package_name [apm_package_key_from_id $package_id]

    db_dml menu_update "
	update layout_menus set
	        package_name    = :package_name,
	        label           = :label,
	        name            = :name,
	        url             = :url,
	        sort_order      = :sort_order,
	        parent_menu_id  = :parent_menu_id,
	        visible_tcl	= :visible_tcl,
		enabled_p	= :enabled_p
	where
		menu_id = :menu_id
    "

} -on_submit {

	ns_log Notice "new1: on_submit"


} -after_submit {


    # Recalculate the menu hierarchy
    menus::menu_update_hierarchy

    ad_returnredirect $return_url
    ad_script_abort
}

