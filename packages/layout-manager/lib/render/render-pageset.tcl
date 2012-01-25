set admin_p [permission::permission_p -object_id [ad_conn package_id] -privilege admin]
set package_id [ad_conn package_id] 
set pageset_id [db_list get_pageset_id {select pageset_id from layout_pagesets where package_id = :package_id and owner_id = 0}]
set customize_p [layout::customize_p -pageset_id $pageset_id]


set return_url [ad_return_url]
set base_url [site_node::get_url_from_object_id -object_id $package_id]



set customize_turn_url [export_vars -base "admin/layout-customize-turn" {pageset_id return_url}]


set vertical_menu_p [parameter::get -package_id [ad_conn package_id] -parameter "ShowLeftFunctionalMenupP"]
set menu_turn_url [export_vars -base "admin/menus/menu-turn" {return_url}]

if {$vertical_menu_p} {
    set vertical_menu [menus::navbar_tree -label main -package_id $package_id]
} else {
    set vertical_menu ""
}



if {$customize_p} {
    set page_name ""
    set page_url [file tail [ad_conn url]]
    set page_id [db_list get_page_id { select page_id from layout_pages where url_name = :page_url  and pageset_id = :pageset_id}]
    set page_name ""
    set edit_theme_url [export_vars -base "admin/change-theme" {return_url}]
    set edit_layout_url [export_vars -base "admin/change-layout" {return_url pageset_id page_id}]
    set edit_page_url [export_vars -base "admin/page-ae" {return_url page_id pageset_id}]
    set edit_menu_url [export_vars -base "admin/menus/index" {return_url}]
    set add_item_url [export_vars -base "admin/menus/choose-parent" {page_name page_url return_url}]
    set add_page_url [export_vars -base "admin/page-ae" {pageset_id return_url}]


    template::multirow create hidden_elements_list element_id element_name show_url
    foreach element_list [layout::hidden_elements_list_not_cached -pageset_id $pageset_id] {
	util_unlist $element_list element_id element_name show_url
	set show_url [export_vars -base ${base_url}pageset-configure-2 {return_url {op show_here} pageset_id element_id page_id}]
	template::multirow append hidden_elements_list $element_id $element_name $show_url
    }
    
    
    template::multirow create layouts_list layout_id name image
    foreach layout_list [layout::layouts] {
	util_unlist $layout_list element_id name
	set name_splited [split $name .]
	### get theme zen layouts. Only!
	if {[lsearch $name_splited "#theme-zen"] != -1} {
	    util_unlist $layout_list layout_id name
	    set layout_image [string trim [lindex $name_splited 1] "#"]
	    template::multirow append  layouts_list $layout_id $name $layout_image
	}
    }
}



array set pageset [layout::pageset::get_render_data -pageset_id $pageset_id -page_num $page_num]


ad_return_template
