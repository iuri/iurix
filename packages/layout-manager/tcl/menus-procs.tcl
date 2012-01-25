# /packages/infoseg/tcl/infoseg-menu-procs.tcl
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

ad_library {
    Library with auxillary routines related to menus::

    @author frank.bergmann@project-open.com
    Modified as infoseg package by
    @author orzenil.junior@embrapa.br

	Modified as acs subsite menus by
	@author Alessandro Landim (alessandro.landim@gmail.com)
}

namespace eval menus {} 

###
# Left Menu APIs
###

### from ]PO[
ad_proc -public menus::navbar_tree {
    {-no_cache:boolean}
    {-package_id}
    {-user_id 0}
    {-label ""}
} {
    Creates an <ul> ...</ul> hierarchical list with all major
    objects in the system.
} {
    if {0 == $user_id} { set user_id [ad_get_user_id] }
    set locale [lang::user::locale -user_id $user_id]

    set no_cache_p 1
    if {$no_cache_p} {
        return [menus::navbar_tree_helper -user_id $user_id -locale $locale -label $label -package_id $package_id]
    } else {
        return [util_memoize [list menus::navbar_tree_helper -package_id $package_id -user_id $user_id -locale $locale -label $label] 3600]
    }
}


ad_proc -public menus::navbar_tree_helper {
    -user_id:required
    -package_id:required
    {-locale "" }
    {-label ""}
} {
    Creates an <ul> ...</ul> hierarchical list with all major
    objects in the system.
} {

    ns_log Notice "Running API menus::navbar_tree_helper"

    template::head::add_css -href "/resources/acs-templating/mktree.css"
    template::head::add_javascript -src "/resources/acs-templating/mktree.js" -order 2

    if {"" == $locale} { set locale [lang::user::locale -user_id $user_id] }
    #set wiki [im_navbar_doc_wiki]
    set wiki "" 
    

#    set show_left_functional_menu_p [parameter::get_from_package_key -package_key "layout-manager" -parameter "ShowLeftFunctionalMenupP" -default 0]
#    ns_log Notice "$show_left_functional_menu_p"
    #if {!$show_left_functional_menu_p} { return "" }

    set root_menu_ids [db_list select_root_menu {
	select lm.menu_id from layout_menus lm, acs_objects ao 
	where ao.object_id = lm.menu_id 
        and ao.package_id = :package_id 
        and lm.parent_menu_id = 0 }]
    
    set html "
	<div class=filter-block>
	<ul class=mktree>
    "
    
    foreach item_id $root_menu_ids {
	set html [menus::render_items -item_id $item_id -html $html]
    }

    append html "</div></ul>"
    
    ns_log Notice "$html"

    return $html
}

ad_proc -public menus::render_items {
    {-item_id}
    {-html}
} {
    Returns the html menu renderized

} {

    set menu_item_ids [db_list select_menu_item_ids { select menu_id from layout_menus where parent_menu_id = :item_id }]
    
    if {[exists_and_not_null menu_item_ids]} {
	
	foreach item_id $menu_item_ids {
	    set flag [db_0or1row select_item_id { select menu_id from layout_menus where menu_id = :item_id }]
	    if {$flag} {
		db_1row select_item_info { 
		    select menu_id, url, name, parent_menu_id from layout_menus where menu_id = :item_id order by sort_order
		} -column_array row
	
		append html "
                  <li><a href=\"$row(url)\">$row(name)</a><ul>
	        "
	        set html [menus::render_items -item_id $row(menu_id) -html $html]
		
		append html "</ul></li>"
	     
	    }
	}
	
    }

    return $html
}




ad_proc -public menu_li {
    {-user_id "" }
    {-locale "" }
    {-package_key "layout-manager" }
    {-class "" }
    {-pretty_name "" }
    label
} {
    Returns a <li><a href=URL>Name</a> for the menu.
    Attention, not closing </li>!
} {
    return [util_memoize [list menu_li_helper -user_id $user_id -locale $locale -package_key $package_key -class $class -pretty_name $pretty_name $label]]
}



ad_proc -public menu_li_helper {
    {-user_id "" }
    {-locale "" }
    {-package_key "layout-manager" }
    {-class "" }
    {-pretty_name "" }
    label
} {
    Returns a <li><a href=URL>Name</a> for the menu.
    Attention, not closing </li>!
} {
    if {"" == $user_id} { set user_id [ad_get_user_id] }
    if {"" == $locale} { set locale [lang::user::locale -user_id $user_id] }

    set menu_id 0
    db_0or1row menu_info "
        select  m.*
        from    layout_menus m
        where   m.label = :label and
                (m.enabled_p is null or m.enabled_p = 't') and
                acs_permission__permission_p(m.menu_id, :user_id, 'read') = 't'
        order by sort_order
    "

    if {0 == $menu_id} { return "" }

    if {"" != $visible_tcl} {
        set visible 0
        set errmsg ""

        if [catch {
            set visible [expr $visible_tcl]
        } errmsg] {
            ns_log Error "menu_li: Error with visible_tcl: $visible_tcl: '$errmsg'"
        }
        if {!$visible} { return "" }
    }

    set class_html ""
    if {"" != $class} { set class_html "class='$class'" }
    regsub -all {[^0-9a-zA-Z]} $name "_" name_key
    return "<li $class_html><a href=\"$url\">[lang::message::lookup "" "$package_key.$name_key" $name]</a>\n"
}





ad_proc -public menus::menu_update_hierarchy {

} {
    Reprocesses the menu hierarchy to calculate the right menu codes
} {
    # Reset all tree_sortkey to null to indicate that the menu_items                                                                                         
    # need to be "processed"                                                                                                                                 
    db_dml reset_menu_hierarchy "
        update layout_menus
        set tree_sortkey = null
    "

    # Prepare the top menu                                                                                                                                   
    set start_menu_id [db_string start_menu_id "select menu_id from layout_menus where label='top'" -default 0]
    db_dml update_top_menu "update layout_menus set tree_sortkey='.' where menu_id = :start_menu_id"

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
                        layout_menus m,                                                                                                                          
                        layout_menus mm                                                                                                                          
                where                                                                                                                                        
                        m.parent_menu_id = mm.menu_id                                                                                                        
                        and m.tree_sortkey is null                                                                                                           
                        and mm.tree_sortkey is not null                                                                                                      
                order by                                      
                       parent_sortkey                                                                                                                       
        "
	
        set ctr 0
        set old_parent_sortkey ""
        db_foreach update_menus $sql {
	    
            if {$old_parent_sortkey != $parent_sortkey} {
                set old_parent_sortkey $parent_sortkey
                set ctr 0
            }

            # the new tree_sortkey is the parents tree_sortkey plus a                                                                                        
            # current letter starting with "A", "B", ...                                                                                                     
            set tree_sortkey "$parent_sortkey[string range $chars $ctr $ctr]"

            db_dml update_menu "update layout_menus set tree_sortkey=:tree_sortkey where menu_id=:menu_id"
            incr ctr
            set continue 1
	}
	incr level
    }
}
    
   

ad_proc -public menus::parent_options { 
    {-package_id}
    {include_empty 0} 
    
} {
    Returns a list of all menus,
    ordered and indented according to hierarchy.
} {
    set package_id [ad_conn package_id]
    set start_menu_id [db_string start_menu_id "select menu_id from layout_menus where label='top'" -default 0]
    set parent_options_sql "
	select
		m.name,
		m.menu_id,
		m.label,
		length(m.tree_sortkey) as indent_level
	from
		layout_menus m, acs_objects ao
        where 
                m.menu_id = ao.object_id and ao.package_id = :package_id
    "

    set parent_options [list]
    db_foreach parent_options $parent_options_sql {
	set spaces ""
	set name  [lang::util::suggest_key $name]
	for {set i 0} {$i < $indent_level} { incr i } {
	    append spaces "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
	}
	lappend parent_options [list "$spaces[_ acs-subsite.$name] - $label" $menu_id]
    }

    set parent_options [concat [list [list "" 0]] $parent_options]
    return $parent_options
}


ad_proc -public menus::get { 
	{-menu_id:required}
	{-array:required}
} {
    Get information from Menu ID
} {
	upvar 1 $array row


    set parent_options_sql "
		select
			m.name,
			m.menu_id,
			m.label,
			m.url
			from
			layout_menus m
			where menu_id = :menu_id
    	"

    db_1row menu_select $parent_options_sql -column_array row
}

ad_proc -public menus::child_menu_id { 
	{-menu_id:required} 
} {
    Return parent menu.
    ordered and indented according to hierarchy.
} {

    return [db_list menu_id "select menu_id from layout_menus where parent_menu_id =:parent_menu_id"]

}


ad_proc -public menus::get_next_sort_order {
	parent_id
} {
	Return next sort order of parent_menu_id
} {

	set sort_order [db_string next_sort_order {select sort_order 
						   from layout_menus 
						   where parent_menu_id = :parent_id 
						   order by sort_order desc limit 1} -default 0]
	return [expr $sort_order + 1]

}	
	


ad_proc -public navbar_doc_wiki { } {
    Link to ]po[ Wiki. Without trailing "/".
} {
    return "http://www.project-open.org/documentation"
}



