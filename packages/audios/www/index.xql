<?xml version="1.0"?>

<queryset>
    <rdbms><type>postgresql</type><version>8.2</version></rdbms>
    <fullquery name="select_recent_audios">
      <querytext>
	select a.audio_id,
	  a.package_id,
	  a.audio_name,
	  a.author,
          acs_object__name(apm_package__parent_id(a.package_id)) as parent_name,
          (select site_node__url(site_nodes.node_id)
            from site_nodes
            where site_nodes.object_id = a.package_id) as url,
	r.mime_type
        from audios a, cr_revisions r
	where a.package_id = :package_id
	and  r.item_id = a.audio_id
	and r.publish_date = (select min(publish_date) from cr_revisions where item_id = a.audio_id)
        and 't' = acs_permission__permission_p(a.audio_id, :user_id, 'read')
	limit 5

      </querytext>
    </fullquery>

    <fullquery name="select_popular_audios">
      <querytext>
	select DISTINCT a.audio_id,
	  a.package_id,
	  a.audio_name,
	  a.author,
          acs_object__name(apm_package__parent_id(a.package_id)) as parent_name,
          (select site_node__url(site_nodes.node_id)
            from site_nodes
            where site_nodes.object_id = a.package_id) as url,
	  r.mime_type
        from audios a, audio_rank ar, cr_revisions r
	where a.package_id = :package_id
	and r.item_id = a.audio_id
	and r.publish_date = (select min(publish_date) from cr_revisions where item_id = a.audio_id)
	and ar.item_id = a.audio_id
	and ar.rank > 2
        and 't' = acs_permission__permission_p(a.audio_id, :user_id, 'read')
	limit 10

      </querytext>
    </fullquery>


    <fullquery name="select_audios">
      <querytext>
	select a.audio_id,
	  a.package_id,
	  a.audio_name,
	  a.audio_description,
	  a.author,
          acs_object__name(apm_package__parent_id(a.package_id)) as parent_name,
          (select site_node__url(site_nodes.node_id)
            from site_nodes
            where site_nodes.object_id = a.package_id) as url,
	  r.mime_type
        from audios a, cr_revisions r
	where a.package_id = :package_id
	and r.item_id = a.audio_id
	and r.publish_date = (select min(publish_date) from cr_revisions where item_id = a.audio_id)
        and 't' = acs_permission__permission_p(a.audio_id, :user_id, 'read')
	order by random()
	limit 2
	
      </querytext>
    </fullquery>
</queryset>
