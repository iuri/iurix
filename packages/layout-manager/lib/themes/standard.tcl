

# template::head::add_css -href "/resources/openacs-default-theme/styles/default-master.css"



if {[info exists element_id]} {
    set element_id_p 1
    set page_id [db_list select_page_id { select page_id from layout_elements where element_id = :element_id }]
} else {
    set element_id_p 0
}

if {![info exists ds_name]} {set ds_name ""}

switch $ds_name {
    calendar_portlet {set image appointment-new.png}
    calendar_list_portlet {set image office-calendar.png}
    dotlrn_main_portlet {set image system-users.png}
    news_portlet {set image internet-news-reader.png}
    chat_portlet {set image internet-group-chat.png}
    faq_portlet {set image help-browser.png}
    dotlrn_members_portlet {set image Address-Book-32x32.png}
    calendar_full_portlet {set image x-office-calendar.png}
    default {set image window-new.png} 
}
set package_id [ad_conn package_id]
set pageset_id [db_list select_pageset_id { select pageset_id from layout_pagesets where package_id = :package_id and owner_id = 0; }]

set customize 0
set customize_p [layout::customize_p -pageset_id $pageset_id]

set admin_p [permission::permission_p -object_id [ad_conn package_id] -privilege admin] 

if {$admin_p && $customize_p} {
    set customize 1
}


set return_url [ad_return_url]
set base_url [site_node::get_url_from_object_id -object_id $package_id]

set hide_url [export_vars -base ${base_url}pageset-configure-2 \
		  {{op hide} pageset_id element_id page_id return_url}]


set save_url [export_vars -base ${base_url}admin/element-modify \
		  {return_url column sort_key pageset_id page_id element_id}]