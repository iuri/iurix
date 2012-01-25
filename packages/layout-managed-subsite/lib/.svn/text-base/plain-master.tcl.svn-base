ad_page_contract {

  Plain master.  The only function of this is to wrap application pages with the theme
  assigned to the page.  No navigation widget is built.

  @author Don Baccus (dhogaza@pacifier.com)

  $Id: plain-master.tcl,v 1.2 2009/09/28 17:18:43 donb Exp $
}

set user_id [ad_conn user_id]

set layout_manager_id [layout::package_id]
set layout_manager_node_id [site_node::get_node_id_from_object_id -object_id $layout_manager_id]
set layout_manager_url [site_node::get_url_from_object_id -object_id $layout_manager_id]
set pageset_id [layout::pageset::get_user_pageset_id -package_id $layout_manager_id]

# set a default title in case an included application page doesn't set it.  Should move
# to the doc() array approach in the future.
set title ""

# No expr tag in the templating system ...
set main_content_p [expr { ![info exists page_num] }]

if { $main_content_p } {
    array set theme \
        [layout::theme::get \
            -name [layout::pageset::get_column_value -pageset_id $pageset_id -column theme]]
}
