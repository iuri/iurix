
#DragDrop JS Library
template::head::add_css -href "/resources/layout-manager/css/dragdrop.css"
template::head::add_javascript -src "/resources/layout-manager/js/jquery-1.2.3.min.js" -order 1
template::head::add_javascript -src "/resources/layout-manager/js/interface.js" -order 2
template::head::add_javascript -src "/resources/layout-manager/js/prototype.js" -order 3


set package_id [ad_conn package_id] 
set base_url [site_node::get_url_from_object_id -object_id $package_id]

set return_url [ad_return_url]

set pageset_id [db_list get_pageset_id {select pageset_id from layout_pagesets where package_id = :package_id and owner_id = 0}]
set page_url [file tail [ad_conn url]]
set page_id [db_list get_page_id { select page_id from layout_pages where url_name = :page_url  and pageset_id = :pageset_id}]

set element_modify_url [export_vars -base ${base_url}admin/element-modify {}]