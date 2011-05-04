<?xml version="1.0"?>

<queryset>
    <rdbms><type>postgresql</type><version>7.1</version></rdbms>
    <fullquery name="select_related_audios">
        <querytext>
	    select audio_id,
		   package_id,
		   audio_name,
	           audio_description as hr,
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
	    and audio_id in (
	    select item_id from tags_tags where tag in 
	    (select tag from tags_tags where item_id = :audio_id))
            order by parent_name, a.audio_name
	    limit 20
        </querytext>
    </fullquery>

</queryset>
