<?xml version="1.0"?>
<queryset>

<fullquery name="check_photo_id">      
      <querytext>
      select count(*) from cr_items where item_id = :photo_id
      </querytext>
</fullquery>

<fullquery name="get_thumbnail_info">      
  <querytext>	
    select 
      i.image_id as thumb_path,
      i.height as thumb_height,
      i.width as thumb_width
    from cr_items ci,
      cr_items ci2,
      cr_child_rels ccr2,
      images i
    where ccr2.relation_tag = 'thumb'
      and ci.item_id = ccr2.parent_id
      and ccr2.child_id = ci2.item_id
      and ci2.latest_revision = i.image_id
      and ci.latest_revision is not null
      and ci.item_id = :photo_id
  </querytext>
</fullquery>

<fullquery name="get_photo_info">      
      <querytext>
      select 
      ci.item_id,	
      ci.live_revision,
      ci.latest_revision as previous_revision,
      pp.caption as caption,
      pp.story as story,
      cr.title,
      cr.description,
      i.height as height,
      i.width as width,
      i.image_id as image_id
    from cr_items ci,
      cr_revisions cr,
      pa_photos pp,
      cr_items ci2,
      cr_child_rels ccr2,
      images i
    where ci.latest_revision = pp.pa_photo_id
      and ci.latest_revision = cr.revision_id
      and ci.item_id = ccr2.parent_id
      and ccr2.child_id = ci2.item_id
      and ccr2.relation_tag = 'viewer'
      and ci2.latest_revision = i.image_id
      and ci.item_id = :photo_id
      and pp.pa_photo_id = cr.revision_id

      </querytext>
</fullquery>

<fullquery name="get_photo_more_info">
  <querytext>
    
  select photographer, community_id, date_taken 
  from pa_photos pp, cr_revisions cr, cr_items ci
  where pp.pa_photo_id = cr.revision_id 
  and cr.item_id = :photo_id
  and ci.latest_revision = cr.revision_id
  </querytext>  
</fullquery>

<fullquery name="get_next_object_id">      
      <querytext>
      select acs_object_id_seq.nextval 
      </querytext>
</fullquery>

<fullquery name="update_photo_attributes">      
      <querytext>
	    select content_revision__new (
	      :title, -- caption
	      :description, -- description 
      	      :date_timestamp, -- publish_date
      	      null, -- mime_type
      	      null, -- nls_language
              null, -- locale
	      :photo_id, -- item_id 
	      :revision_id, -- revision_id 
	      current_timestamp, -- creation_date 
	      :user_id, -- creation_user
	      :peeraddr -- creation_ip
	    )
	      </querytext>
</fullquery>

<fullquery name="insert_photo_attributes">      
      <querytext>

	insert into pa_photos 
        (pa_photo_id, story, caption, 
	community_id, photographer, date_taken, 
        user_filename, camera_model, flash, 
        aperture, metering, focal_length,exposure_time,
        focus_distance, sha256)
        SELECT :revision_id, :story, :caption, 
	:community_id, :photographer, :date_timestamp, user_filename,
	camera_model, flash, aperture, metering, focal_length, exposure_time,
        focus_distance, sha256
        FROM pa_photos prev
        WHERE prev.pa_photo_id = :previous_revision
        
      </querytext>
</fullquery>


<fullquery name="set_live_revision">      
      <querytext>
	    select content_item__set_live_revision (:revision_id)
      </querytext>
</fullquery>



</queryset>
