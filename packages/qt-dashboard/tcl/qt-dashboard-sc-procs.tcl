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
    ns_log Notice "Running TCL ad_prc qt_face__datasource"
    
    db_0or1row qt_face_datasource "
	select r.revision_id as object_id,
        i.name as title,
        case i.storage_type
        when 'lob' then r.lob::text
        when 'file' then '[cr_fs_path]' || r.content
        else r.content
        end as content,
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
    ns_log Notice "Running TCL ad_prc qt_face__url"

    db_1row qt_face_get_package_id "
	SELECT f.package_id as package_id
        FROM fs_root_folders f,
        (SELECT parent.parent_id
         FROM cr_items parent, cr_items children, cr_revisions r
         WHERE children.item_id = r.item_id
         AND r.revision_id = $revision_id
         AND children.tree_sortkey
         BETWEEN parent.tree_sortkey 
         AND tree_right(parent.tree_sortkey) ) AS i
        WHERE f.folder_id = i.parent_id
    "

    db_1row fs_get_url_stub "
        SELECT site_node__url(node_id) AS url_stub
        FROM site_nodes
        WHERE object_id = :package_id
    "

    return "${url_stub}/one?version_id=$revision_id"
}


ad_proc qt_vehicle__datasource {
    revision_id
} {
    @author Iuri Sampaio (iuri@iurix.com)
    @creation-date 2020-08-02
} {
    ns_log Notice "Running TCL ad_prc qt_vehicle__datasource"

    db_0or1row qt_vehicle_datasource "
	SELECT r.revision_id AS object_id,
        i.name AS title,
        case i.storage_type
        when 'lob' then r.lob::text
        when 'file' then '[cr_fs_path]' || r.content
        else r.content
        end as content,
        r.mime_type as mime,
        '' AS keywords,
        i.storage_type as storage_type
	FROM cr_items i, cr_revisions r
	WHERE r.item_id = i.item_id
	AND r.revision_id = :revision_id
    " -column_array datasource
    
    return [array get datasource]
}

ad_proc qt_vehicle__url {
    revision_id
} {
    @author Iuri Sampaio (iuri@iurix.com)
    @creation-date 2020-08-02
} {
    ns_log Notice "Running TCL ad_proc qt_vehicle__url $revision_id"

    db_1row qt_vehicle_get_package_id "
        SELECT parent.parent_id AS package_id
         FROM cr_items parent, cr_items children, cr_revisions r
         WHERE children.item_id = r.item_id
         AND r.revision_id = $revision_id
         AND children.tree_sortkey
         BETWEEN parent.tree_sortkey 
         AND tree_right(parent.tree_sortkey) 
    "
    ns_log Notice "BEFORE URL STUB"
    
    db_1row qt_vehicle_get_url_stub "
        SELECT site_node__url(node_id) AS url_stub
        FROM site_nodes
        WHERE object_id = :package_id
    "

    ns_log Notice "URL STUB $url_stub"
    return "/primax/one?version_id=$revision_id"
}


# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
