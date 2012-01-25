<?xml version="1.0"?>
<queryset>

    <fullquery name="audios::new.insert_audio">
        <querytext>
            SELECT audio__new (
	    :item_id,
	    :name,
	    :description,
	    :date,
	    :package_id,
	    :creation_user,
	    :group_id,
	    :author,
	    :coauthor,
	    :source)
        </querytext>
    </fullquery>
    

    <fullquery name="audios::insert_audio_queue.insert_audio_queue">
        <querytext>
            insert into audio_queue (item_id)
	    values (:item_id) 
        </querytext>
    </fullquery>
    

    <fullquery name="audios::delete_audio_queue.delete_audio_queue">
        <querytext>
            delete from audio_queue
	    where item_id = :item_id
        </querytext>
    </fullquery>

    <fullquery name="audios::convert.get_live_revision">
      <querytext>
	select revision_id
	from cr_revisions
	where item_id = :item_id
	order by revision_id asc
	limit 1
      </querytext>
    </fullquery>
      
    <fullquery name="audios::convert.write_file_content">
      <querytext>
        select :path || content
	from cr_revisions
	where revision_id = :revision_id
      </querytext>
    </fullquery>
    

    <fullquery name="audios::get.select_audio">
      <querytext>
	select  ci.item_id,
        a.audio_description,
        a.audio_name,
	a.audio_date,
        a.package_id,
	a.group_id,
	a.author,
	a.coauthor,
	a.source,
	o.creation_user,
	o.creation_ip
        from    cr_items ci,
        audios a,
	acs_objects o
        where   ci.item_id = :item_id
        and     a.audio_id = ci.item_id
	and     o.object_id = ci.item_id
      </querytext>
    </fullquery>
    

  <fullquery name="audios::edit.update_audio">
    <querytext>
      UPDATE audios SET 
      audio_name = :name,
      audio_description = :description,
      audio_date = :date,
      group_id = :group_id,
      author = :author,
      coauthor = :coauthor,
      source = :source
      WHERE audio_id = :item_id
    </querytext>
  </fullquery>
  
  <fullquery name="audios::new.create_tag">      
    <querytext>
      insert into tags_tags ( 
      item_id,
      user_id,
      package_id,
      tag,
      time
      ) values (
      :item_id,
      :creation_user,
      :package_id,
      :tag,
      current_timestamp
      )
    </querytext>
  </fullquery>
    
</queryset>
