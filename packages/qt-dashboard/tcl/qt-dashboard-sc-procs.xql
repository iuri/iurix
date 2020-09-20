<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>


<fullquery name="qt_datasource">
      <querytext>
	select r.revision_id as object_id,
	       i.name as title,
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
      </querytext>
</fullquery>

<fullquery name="qt_get_package_id">
      <querytext>
        SELECT parent.parent_id AS package_id
         FROM cr_items parent, cr_items children, cr_revisions r
         WHERE children.item_id = r.item_id
         AND r.revision_id = $revision_id
         AND children.tree_sortkey
         BETWEEN parent.tree_sortkey 
         AND tree_right(parent.tree_sortkey) 
       </querytext>
</fullquery>

<fullquery name="qt_get_url_stub">
      <querytext>
        select site_node__url(node_id) as url_stub
        from site_nodes
        where object_id=:package_id
      </querytext>
</fullquery>

</queryset> 
