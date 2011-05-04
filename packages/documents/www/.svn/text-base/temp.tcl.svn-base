ad_page_contract {

    @date 2010
} {
}

array set node [site_node::get -node_id 835]

ns_log Notice "[parray node]"

set package_id [ad_conn package_id]
set folder_id [db_list select_folder_id { 
    select folder_id from cr_folders where package_id = :package_id
}]

set subfolders [db_list_of_lists select_subfolders {
    select item_id, name from cr_items where parent_id = :folder_id
}]


set tree_id [lindex [lindex [category_tree::get_mapped_trees $package_id] 0] 0]

set categories [db_list_of_lists select_categories {
      SELECT ct.category_id, ct.name from category_translations ct
        INNER JOIN categories c ON (ct.category_id = c.category_id)
        WHERE c.parent_id = (
                     select c2.category_id from categories c2
                     inner join category_translations ct2 ON (c2.category_id = ct2.category_id)
                     where c2.parent_id is null
                     and ct2.name = 'Tipo'
                     and tree_id = :tree_id)

}]

foreach id $subfolders {
}

ns_log Notice " $categories | $subfolders"