ad_page_contract {
    author iuri sampaio (iuri.sampaio@gmail.com)
} {
    {return_url ""}
    {pageset_id ""}
    {page_id ""}
    {page_count ""}
}






if {[exists_and_not_null page_id]} {
    set page_edit_p 1

} else {
    set page_edit_p 0
    
    set admin_p [permission::permission_p -object_id [ad_conn package_id] -privilege admin]
    set package_id [ad_conn package_id]
    set pageset_id [db_list get_pageset_id {select pageset_id from layout_pagesets where package_id = :package_id and owner_id = 0}]
    set customize_p [layout::customize_p -pageset_id $pageset_id]
    
    set base_url [site_node::get_url_from_object_id -object_id $package_id]
    
    set customize_turn_url [export_vars -base ${base_url}admin/layouts/layout-customize-turn {pageset_id return_url}]
    
    set page_name ""
    set page_url [ad_conn url]
    set edit_theme_url [export_vars -base ${base_url}admin/themes/change-theme {return_url}]
    set add_item_url [export_vars -base ${base_url}admin/menus/choose-parent {page_name page_url return_url}]
    set add_page_url [export_vars -base ${base_url}admin/page-add {pageset_id return_url}]
    
    
    
    
    
    
    ad_form -name page-add -cancel_url $return_url -form {
	{info:text(inform)
	    {label "  <h1>#layout-manager.Add_new_page#</h1>"}
	}
	{name:text(text)
	    {label "#layout-manager.Name#"}
	}
	{pageset_id:integer(hidden)
	    {value $pageset_id}
	}
	{return_url:text(hidden)
	    {value $return_url}
	}
    } -on_submit { 
	layout::page::new -pageset_id $pageset_id -name $name
	ad_returnredirect $return_url
    }

}