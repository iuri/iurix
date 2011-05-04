<?xml version="1.0"?>

<queryset>
    <rdbms><type>postgresql</type><version>8.2</version></rdbms>

    <fullquery name="select_folders">
      <querytext>

    SELECT  ci.item_id, o.title  
    FROM cr_items ci, acs_objects o
    WHERE ci.content_type = 'content_folder' 
    AND ci.parent_id = :root_folder_id
    AND o.object_id = ci.item_id

      </querytext>
   </fullquery>

    <fullquery name="select_folder_content">
      <querytext>

	SELECT cr.revision_id, cr.title, cr.mime_type
	FROM cr_revisions cr, cr_items ci
	WHERE cr.item_id = ci.item_id 
	AND cr.revision_id = ci.live_revision
	AND ci.parent_id = :folder_id 

      </querytext>
   </fullquery>

   <fullquery name="select_most_recent_files">
     <querytext>
       	SELECT cr.revision_id, cr.title, ci.parent_id, cr.mime_type
	FROM cr_revisions cr, cr_items ci
	WHERE cr.revision_id = ci.latest_revision
	AND cr.item_id = ci.item_id
	AND ci.storage_type = 'file'
	AND ci.parent_id IN (SELECT item_id FROM cr_items WHERE parent_id = :root_folder_id)
	ORDER BY cr.publish_date DESC
	LIMIT 10
     </querytext>
   </fullquery>
   
</queryset>

