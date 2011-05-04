<?xml version="1.0"?>

<queryset>
    <rdbms><type>postgresql</type><version>7.1</version></rdbms>

    <fullquery name="select_audios">
      <querytext>
	select DISTINCT a.audio_id,
	  a.package_id,
	  a.audio_name,
	  a.audio_description,
	  a.author,
          acs_object__name(apm_package__parent_id(a.package_id)) as parent_name,
          (select site_node__url(site_nodes.node_id)
            from site_nodes
            where site_nodes.object_id = a.package_id) as url,
	  cr.mime_type
        from audios a, cr_revisions cr
	where a.package_id = :package_id
	and cr.item_id = a.audio_id
        and 't' = acs_permission__permission_p(a.audio_id, :user_id, 'read')
	$query
	[template::list::page_where_clause -name audios -and]
	[template::list::orderby_clause -name audios -orderby]
      	[template::list::filter_where_clauses -and -name audios]
      </querytext>
    </fullquery>
    
</queryset>

