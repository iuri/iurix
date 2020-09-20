ad_library {
    Site-wide search procs for qt-dashboard
    Implements OpenFTS Search service contracts
    
    @author Iuri Sampaio (iuri@iurix.com)
    @creation-date 2020-08-02
}



ad_proc qt_face__datasource {
    revision_id
} {
    @author Iuri Sampaio (iuri@iurix.com)
    @creation-date 2020-08-02
} {
    
    db_0or1row qt_datasource "
        select r.revision_id as object_id,
        r.title as title,
        (case i.storage_type
                when 'lob' then r.lob::text
                when 'file' then '[cr_fs_path]' || r.content
                else r.content
	        end) as content,
        r.mime_type as mime,
        '' as keywords,
        i.storage_type as storage_type
	from cr_items i, cr_revisions r
	where r.item_id = i.item_id
	and   r.revision_id = :revision_id


    " -column_array datasource
    
    return [array get datasource]
}

ad_proc qt_face__url {
    revision_id
} {
    @author Iuri Sampaio (iuri@iurix.com)
    @creation-date 2020-08-02
} {
    db_1row qt_get_package_id "
        SELECT parent.parent_id AS package_id
         FROM cr_items parent, cr_items children, cr_revisions r
         WHERE children.item_id = r.item_id
         AND r.revision_id = $revision_id
         AND children.tree_sortkey
         BETWEEN parent.tree_sortkey 
         AND tree_right(parent.tree_sortkey) 

    "
    
    db_1row qt_get_url_stub "
        select site_node__url(node_id) as url_stub
        from site_nodes
        where object_id=:package_id

    "

    return "${url_stub}/one?version_id=$revision_id"
}


ad_proc qt_vehicle__datasource {
    revision_id
} {
    @author Iuri Sampaio (iuri@iurix.com)
    @creation-date 2020-08-02
} {

    db_0or1row qt_datasource "
     	select r.revision_id as object_id,
        r.title as title,
	       (case i.storage_type
		     when 'lob' then r.lob::text
		     when 'file' then '[cr_fs_path]' || r.content
	             else r.content
	        end) as content,
	        r.mime_type as mime,
	        '' as keywords,
	        i.storage_type as storage_type
	from cr_items i, cr_revisions r
	where r.item_id = i.item_id
	and   r.revision_id = :revision_id
   
    " -column_array datasource
    
    return [array get datasource]
}

ad_proc qt_vehicle__url {
    revision_id
} {
    @author Iuri Sampaio (iuri@iurix.com)
    @creation-date 2020-08-02
} {
    
    db_1row qt_get_package_id "
        SELECT parent.parent_id AS package_id
         FROM cr_items parent, cr_items children, cr_revisions r
         WHERE children.item_id = r.item_id
         AND r.revision_id = $revision_id
         AND children.tree_sortkey
         BETWEEN parent.tree_sortkey 
         AND tree_right(parent.tree_sortkey) 

    "
    db_1row qt_get_url_stub "
        select site_node__url(node_id) as url_stub
        from site_nodes
        where object_id=:package_id


    "

    return "/primax/one?version_id=$revision_id"
}


# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
