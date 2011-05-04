<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="grant_permission">
      <querytext>
	select acs_permission__grant_permission(:room_id, :target_user_id, 'chat_room_edit');
	select acs_permission__grant_permission(:room_id, :target_user_id, 'chat_room_view');
	select acs_permission__grant_permission(:room_id, :target_user_id, 'chat_room_delete');
	select acs_permission__grant_permission(:room_id, :target_user_id, 'chat_transcript_create');   
      </querytext>
</fullquery>

</queryset>
