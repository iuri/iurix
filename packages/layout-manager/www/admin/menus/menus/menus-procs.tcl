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

ad_proc -public menus::parent_options { 
	{include_empty 0} 
} {
    Returns a list of all menus,
    ordered and indented according to hierarchy.
} {
	set package_id [ad_conn package_id]

    set start_menu_id [db_string start_menu_id "select menu_id from menus where label='top'" -default 0]

    set parent_options_sql "
	select
		m.name,
		m.menu_id,
		m.label,
		length(m.tree_sortkey) as indent_level
	from
		menus m,
		acs_objects ao
	where m.menu_id = ao.object_id 
	and   (ao.package_id = :package_id
	or   m.menu_id = :start_menu_id)
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
    return $parent_options
}


ad_proc -public menus::dropdown { 
	parent_label
	{package_id ""}
	{bind_vars "menu_id"}
} {
    Returns all subitems of a menus as LIs, suitable
    to be added to index screens (costs) etc. 
} {
	
    if {![exists_and_not_null package_id]} {
		set package_id [ad_conn package_id]
    }

    set user_id [ad_get_user_id]
    set parent_menu_id [db_string start_menu_id "select menu_id from menus m, acs_objects ao  where label=:parent_label and ao.object_id = m.menu_id and ao.package_id = :package_id" -default ""]
    set top_menu_sortkey [db_string top_menu_sortkey "select tree_sortkey from menus where menu_id=:parent_menu_id" -default ""]

    set top_menu_sql " 
	m.tree_sortkey like '$top_menu_sortkey%'"

    set menu_select_sql "
        select  m.*,
		length(m.tree_sortkey) as indent_level
        from    menus m,
				acs_objects ao
		where   $top_menu_sql
		and     menu_id <> :parent_menu_id
		and     ao.object_id = m.menu_id
		and     ao.package_id = :package_id
        order by tree_sortkey asc, sort_order
	"


    #and acs_permission__permission_p(m.menu_id, :user_id, 'read') = '1'


    # Start formatting the menu bar
    set parent_menu_id_ref $parent_menu_id 
    set result "\n"
    #set result "<ul class=\"dropdown\" id=\"menu\">\n"
    set ctr 1

    set indent_level_tmp 3
    db_foreach menu_select $menu_select_sql {
		
		set read_p [permission::permission_p -party_id $user_id -object_id $menu_id -privilege read]
	        regsub -all " " $name "_" name_key
		## Bind Vars

		#foreach var [ad_ns_set_keys $bind_vars] {
		#    set value [ns_set get $bind_vars $var]
		#    append url "&$var=[ad_urlencode $value]"
		#}
		if {$read_p} {
			if {$indent_level != $indent_level_tmp} {
				if {$indent_level_tmp > $indent_level} {
					set minus [expr $indent_level_tmp - $indent_level]
				
					
					for {set i 0} {$i < $minus} {incr i} {
						append result "</li></ul>"
					}
				} else {
					append result "<ul>"
				}
				set indent_level_tmp $indent_level
				
			} else {
				append result "</li>\n"
			}
		
			if {$indent_level != 3} {
				set class "class=\"menulink menusub\""
			} else {
				set class "class=\"menulink menuroot\""
			}
	
			append result "<li><a href=\"$url\" $class>[_ $package_name.$name_key]</a>"
		}
    }

    for {set i $indent_level_tmp} {$i > 3} {set i [expr $i -1]} {
	append result "</ul>"
    }

    append result "</li>\n"

    return $result
}


ad_proc -public menus::dropdown_with_key { 
	parent_label
	{package_id ""}
	{bind_vars "menu_id"}
} {
    Returns all subitems of a menus as LIs, suitable
    to be added to index screens (costs) etc. 
} {
	
    if {![exists_and_not_null package_id]} {
		set package_id [ad_conn package_id]
    }

    set user_id [ad_get_user_id]
    set parent_menu_id [db_string start_menu_id "select menu_id from menus m, acs_objects ao  where label=:parent_label and ao.object_id = m.menu_id and ao.package_id = :package_id" -default ""]
    set top_menu_sortkey [db_string top_menu_sortkey "select tree_sortkey from menus where menu_id=:parent_menu_id" -default ""]

    set top_menu_sql " 
	m.tree_sortkey like '$top_menu_sortkey%'"

    set menu_select_sql "
        select  m.*,
		length(m.tree_sortkey) as indent_level
        from    menus m,
				acs_objects ao
		where   $top_menu_sql
		and     menu_id <> :parent_menu_id
		and     ao.object_id = m.menu_id
		and     ao.package_id = :package_id
        order by tree_sortkey asc, sort_order
	"


    #and acs_permission__permission_p(m.menu_id, :user_id, 'read') = '1'


    # Start formatting the menu bar
    set parent_menu_id_ref $parent_menu_id 
    set result "\n"
    #set result "<ul class=\"dropdown\" id=\"menu\">\n"
    set ctr 1

    set indent_level_tmp 3
    db_foreach menu_select $menu_select_sql {
		
		set read_p [permission::permission_p -party_id $user_id -object_id $menu_id -privilege read]
	        regsub -all " " $name "_" name_key
		## Bind Vars

		#foreach var [ad_ns_set_keys $bind_vars] {
		#    set value [ns_set get $bind_vars $var]
		#    append url "&$var=[ad_urlencode $value]"
		#}
		if {$read_p} {
			if {$indent_level != $indent_level_tmp} {
				if {$indent_level_tmp > $indent_level} {
					set minus [expr $indent_level_tmp - $indent_level]					
					for {set i 0} {$i < $minus} {incr i} {
						append result "</li></ul>"
					}
				} else {
					append result "<ul>"
				}
				set indent_level_tmp $indent_level
				
			} else {
				append result "</li>\n"
			}
		
			if {$indent_level != 3} {
				set class "class=\"menulink menusub\""
			} else {
				set class "class=\"menulink menuraiz\""
			}
	
			set value [value_if_exists "label"]
			set url "[ad_urlencode $value]"
			append result "<li><a href=\"$url\" $class>[_ $package_name.$name_key]</a>"
		}
    }

    for {set i $indent_level_tmp} {$i > 3} {set i [expr $i -1]} {
	append result "</ul>"
    }

    append result "</li>\n"

    return $result
}

ad_proc -public menus::dropdown_child { 
	parent_menu_id
 } {
    Returns all subitems of a menus as LIs, suitable
    to be added to index screens (costs) etc. 
} {
    set user_id [ad_get_user_id]

    set menu_select_sql "
        select  m.*
        from    menus m
		where   parent_menu_id = :parent_menu_id
        order by sort_order
	"


    #and acs_permission__permission_p(m.menu_id, :user_id, 'read') = '1'


    # Start formatting the menu bar
	set parent_menu_id_ref $parent_menu_id 
    set result "<ul>\n"
    set ctr 1
    db_foreach menu_select $menu_select_sql {
			set read_p [permission::permission_p -party_id $user_id -object_id $menu_id -privilege read]
	        regsub -all " " $name "_" name_key
			
			if {$read_p} {
				append result "<li class=\"sub\"><a href=\"$url\">[_ acs-subsite.$name_key]</a>"
				append result "</li>\n"
			}
    }

    append result "</ul>\n"

	if {$result == "<ul>\n</ul>\n"} {
		set result ""
	}

    return $result

}

ad_proc -public menus::li {
	parent_menu_id
	var
} {
    Returns all subitems of a menus as LIs, suitable
    to be added to index screens (costs) etc. 
} {

    set user_id [ad_get_user_id]

    set menu_select_sql "
        select  m.*
        from    menus m
		where   parent_menu_id = :parent_menu_id
        order by sort_order
	"


    #and acs_permission__permission_p(m.menu_id, :user_id, 'read') = '1'


    # Start formatting the menu bar
    set result ""
    db_foreach menu_select $menu_select_sql {
			set read_p [permission::permission_p -party_id $user_id -object_id $menu_id -privilege read]
	        regsub -all " " $name "_" name_key

			set value [value_if_exists $var]
			set url "[ad_urlencode $value]"
	    	   
			if {$read_p} {
				append result "<li><a href=\"$url\">[_ acs-subsite.$name_key]</a></li>\n"
			}


	}

    append result ""

    return $result
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
			menus m
			where menu_id = :menu_id
    	"

    db_1row menu_select $parent_options_sql -column_array row
}

ad_proc -public menus::parent_menu_id { 
	{-menu_id:required} 
} {
    Return parent menu.
    ordered and indented according to hierarchy.
} {

    return [db_string menu_id "select parent_menu_id from menus where menu_id=:menu_id"]

}

ad_proc -public menus::child_menu_id { 
	{-menu_id:required} 
} {
    Return parent menu.
    ordered and indented according to hierarchy.
} {

    return [db_list menu_id "select menu_id from menus where parent_menu_id =:parent_menu_id"]

}


ad_proc -public menus::get_next_sort_order {
	parent_id
} {
	Return next sort order of parent_menu_id
} {

	set sort_order [db_string next_sort_order {select sort_order 
						   from menus 
						   where parent_menu_id = :parent_id 
						   order by sort_order desc limit 1} -default 0]
	return [expr $sort_order + 1]

}	
	
