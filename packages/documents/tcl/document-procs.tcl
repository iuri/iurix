ad_library {

    Documents Library

    @creation-date 2010-09-20
    @author iuri sampaio <iuri.sampaio@gmail.com>

}

namespace eval documents {}


ad_proc -public documents::new {
    {-document_id:required}
    {-name:required}
    {-description ""}
    {-group_id ""}
    {-author ""}
    {-coauthor ""}
    {-language ""}
    {-source ""}
    {-publish_date ""}
    {-creation_user ""}
    {-creation_ip ""}
    {-context_id ""}
} {
    
    inserts a new document
    @author iuri sampaio (iuri.sampaio@gmail.com)
    @date 2010-10-06

} {
    
    ns_log Notice "$document_id | $name | $description | $creation_user | $group_id | $author | $coauthor | $language | $source | $publish_date"

    if {[exists_and_not_null creation_user]} {
	set creation_user [ad_conn user_id]
    }
    
    if {[string equal $creation_ip ""]} {
	set creation_ip [ad_conn peeraddr]
    }

    if {[exists_and_not_null context_id]} {
	set context_id [ad_conn package_id]
    }
    
    set publish_date "[lindex $publish_date 0]-[lindex $publish_date 1]-[lindex $publish_date 2]"

    db_transaction {
	db_exec_plsql new_document {}
    }


    #db_dml insert_document "
#	insert into documents (document_id, name, description, user_id, group_id, author, coauthor, language, source, publish_date)
#	values (:document_id, :name, :description, :user_id, :group_id, :author, :coauthor, :language, :source, now())"

    

}


ad_proc -public documents::edit {
    {-document_id:required}
    {-name:required}
    {-description ""}
    {-group_id ""}
    {-author ""}
    {-coauthor ""}
    {-language ""}
    {-source ""}
    {-publish_date ""}
    {-creation_user ""}
} {
    
    edit document info
    @author iuri sampaio (iuri.sampaio@gmail.com)
    @date 2010-10-06
} {

    ns_log Notice "$document_id | $name | $description | $creation_user | $group_id | $author | $coauthor | $language | $source | $publish_date"

    if {![string equal $publish_date ""]} {
	set publish_date "[lindex $publish_date 0]-[lindex $publish_date 1]-[lindex $publish_date 2]"
    }

    db_dml update_info {} 
    
}


ad_proc -public documents::delete {
    -document_id:required
} {
    delete a document 

    @author iuri sampaio (iuri.sampaio@gmail.com)
    @date 2010-10-06
} {

    db_exec_plsql delete_document {}
}


ad_proc -public documents::get_group_id {
    -package_id
} {
    Returns the package_id as group_id 
} {


    db_1row select_subsite_id {
	select context_id as group_id 
	from acs_objects 
	where package_id = :package_id 
	and object_type = 'apm_package'
    }
    
    if {![info exists $group_id]} {
	set dotlrn_p [apm_package_installed_p dotlrn]
	if {$dotlrn_p} {
	    #get communities and subsites
	    
	    db_1row select_community_id {
		select package_id as group_id
		from dotlrn_communities 
		where archived_p = 'f'
		
	    }
	}
    }
    
    return $group_id
}



ad_proc -public documents::get_group_options {
} { 
    Returns community and subsite options to a select widget
} {
    
    set subsites [db_list_of_lists select_subsites {
	select instance_name, package_id
	from apm_packages ap
	where package_key = 'acs-subsite'
	order by lower(instance_name)
    }]
    
    set dotlrn_p [apm_package_installed_p dotlrn]
    if {$dotlrn_p} {
	#get communities and subsites
	set community_id [dotlrn_community::get_community_id]  

	set groups [db_list_of_lists select_communities {
	    select pretty_name, community_id
	    from dotlrn_communities 
	    where archived_p = 'f'
	    and community_id = :community_id

	}]
			
	
	lappend $subsites $groups
    }

    return $subsites
}




ad_proc -public documents::get_categories {
    {-package_id ""}
} {
   Returns cateogories 
} {

    set locale [ad_conn locale]
    set category_trees [category_tree::get_mapped_trees $package_id]

    if {[exists_and_not_null category_trees]} {
	
	set tree_id [lindex [lindex $category_trees 0] 0]
	set cat_ids [category_tree::get_categories -tree_id $tree_id]
	set categories [list]
	foreach cat_id $cat_ids {
	    set cat_name [category::get_name $cat_id]
	    lappend categories $cat_id
	    lappend categories $cat_name
	}
	
	return $categories
    }

    return
}



ad_proc -public documents::get_subcategories {
    -category_id:required
} {
   Returns subcateogories 
} {
    ns_log Notice "Running API documents::get_subcategories"
    set locale [ad_conn locale]

    set children [category::get_children -category_id $category_id]

    set categories [list]
    foreach child $children {
	ns_log Notice "$child"
	lappend categories $child
       	lappend categories [category::get_name  $child "pt_BR"]
	
    }
    ns_log Notice "$categories"

    return $categories
}


ad_proc -public documents::category_get_options {
    {-parent_id:required}
} {
    @return Returns the category types for this instance as an
    array-list of { parent_id1 heading1 parent_id2 heading2 ... }
} {

    set children_ids [category::get_children -category_id $parent_id]
    
    set children [list]
    foreach child_id $children_ids {
	set child_name [category::get_name $child_id]
	set temp "$child_name $child_id"
	lappend children $temp
    }

    return $children
}   


ad_proc documents::get_category_child_mapped {
    {-category_id:required}
    {-object_id:required}
} {
    Return the category child  mapped to the video item 
} {

    #Get category children mapped to the object_id
    set children_ids [db_list get_child "select category_id from category_object_map where object_id = :object_id"]
    
    #Verify which child has the parent category that matches with the category_id passed as argument
    foreach child_id $children_ids {
	if {$category_id eq [category::get_parent -category_id $child_id]} {
	    return $child_id
	}
    }
    return 
}


ad_proc -public documents::from_sql_datetime {
    {-sql_date:required}
    {-format:required}
} {
    
} {
    # for now, we recognize only "YYYY-MM-DD" "HH12:MIam" and "HH24:MI". 
    set date [template::util::date::create]

    switch -exact -- $format {
        {YYYY-MM-DD} {
            regexp {([0-9]*)-([0-9]*)-([0-9]*)} $sql_date all year month day

            set date [template::util::date::set_property format $date {DD MONTH YYYY}]
            set date [template::util::date::set_property year $date $year]
            set date [template::util::date::set_property month $date $month]
            set date [template::util::date::set_property day $date $day]
        }

        {HH12:MIam} {
            regexp {([0-9]*):([0-9]*) *([aApP][mM])} $sql_date all hours minutes ampm
            
            set date [template::util::date::set_property format $date {HH12:MI am}]
            set date [template::util::date::set_property hours $date $hours]
            set date [template::util::date::set_property minutes $date $minutes]                
            set date [template::util::date::set_property ampm $date [string tolower $ampm]]
        }

        {HH24:MI} {
            regexp {([0-9]*):([0-9]*)} $sql_date all hours minutes

            set date [template::util::date::set_property format $date {HH24:MI}]
            set date [template::util::date::set_property hours $date $hours]
            set date [template::util::date::set_property minutes $date $minutes]
        }

        {HH24} {
            set date [template::util::date::set_property format $date {HH24:MI}]
            set date [template::util::date::set_property hours $date $sql_date]
            set date [template::util::date::set_property minutes $date 0]
        }
        default {
            set date [template::util::date::set_property ansi $date $sql_date]
        }
    }

    return $date
}


ad_proc -public documents::get_fs_package_id {
    {-package_id}
} {
    Return the package_id of the filestorage instance that documents runs
} {
    
    db_1row select_package_id {
	select object_id as fs_package_id from site_nodes sn where sn.parent_id = (select node_id from site_nodes where object_id = :package_id);
    }

    return $fs_package_id

}


ad_proc -public documents::mount_file_storage {
    -package_id
    -node_id
} {
    Mounts a file-storage application under documents application
} {
    ns_log Notice "Running API documents::mount_file_storage"
    
    array set node [site_node::get -node_id $node_id]

    site_node::instantiate_and_mount \
	-parent_node_id $node_id \
	-node_name "$node(name)-storage" \
	-package_name "$node(instance_name) Storage" \
	-package_key "file-storage"

    documents::create_folder -package_id $package_id -node_id $node_id
}

ad_proc -private documents::create_folder {
    -package_id 
    -node_id
} {
    Set up documents package to be used together with file-storage package
} {
    
    ns_log Notice "Running API documents::create_folder"
    array set node [site_node::get -node_id $node_id]
    
    
    db_1row select_package_id {
	select object_id as fs_package_id from site_nodes sn where sn.parent_id = (select node_id from site_nodes where object_id = :package_id);
    }
    
    ns_log Notice "$fs_package_id"
    
    
    # Create Document's Root Folder
    set folder_id [fs::get_root_folder -package_id $fs_package_id]
		       
    # Create Article's subfolder
    set subfolder1_id [fs::new_folder -name "[_ documents.articles]" \
			   -pretty_name "[_ documents.Articles]" \
			   -parent_id $folder_id \
			   -package_id $fs_package_id \
			   -creation_user [ad_conn user_id] \
			   -creation_ip [ad_conn peeraddr] \
			   -description "[_ documents.article_desc]"]
    
    # Create Documentation's subfolder
    set subfolder2_id [fs::new_folder -name "[_ documents.documentation]" \
			   -pretty_name "[_ documents.Documentation]" \
			   -parent_id $folder_id \
			   -package_id $fs_package_id \
			   -creation_user [ad_conn user_id] \
			   -creation_ip [ad_conn peeraddr] \
			   -description "[_ documents.documentation_desc]"]
    
    # Create Legislation's subfolder
    set subfolder1_id [fs::new_folder -name "[_ documents.legislation]" \
			   -pretty_name "[_ documents.Legislation]" \
			   -parent_id $folder_id \
			   -package_id $fs_package_id \
			   -creation_user [ad_conn user_id] \
			   -creation_ip [ad_conn peeraddr] \
			   -description "[_ documents.legislation_desc]"]
}



ad_proc -private documents::map_folder_category {
    -package_id
    -node_id
} {
    Maps folders to categories
    
    @author iuri sampaio (iuri.sampaio@gmail.com)
    @date 2010-11-28
} {

    array set node [site_node::get -node_id $node_id]

    

    
}