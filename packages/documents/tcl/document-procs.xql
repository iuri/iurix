<?xml version="1.0"?>
<queryset>
  <fullquery name="documents::new.new_document">
    <querytext>
	SELECT document_item__new (
	:document_id, 
	:name, 
	:description, 
	:group_id, 
	:author, 
	:coauthor, 
	:language, 
	:source,
	:publish_date,
	:creation_user,
	:creation_ip,
	:context_id)
    </querytext>
  </fullquery>

  <fullquery name="documents::edit.update_info">
    <querytext>
      UPDATE document_items SET 
	name = :name, 
	description = :description, 
	group_id = :group_id, 
	author = :author, 
	coauthor = :coauthor, 
	language = :language, 
	source = :source,
        publish_date = :publish_date,
	user_id = :creation_user
      WHERE document_id = :document_id
    </querytext>
  </fullquery>
  
  <fullquery name="documents::delete.delete_document">
    <querytext> 
      SELECT document_item__delete(:document_id)
    </querytext>
  </fullquery>




  <fullquery name="documents::create_folder.select_node_id">
    <querytext>

        SELECT  node_id
        FROM site_nodes s, apm_packages p, acs_objects o
        WHERE p.package_key = 'acs-subsite'
        AND p.package_id = o.package_id 
        AND s.object_id = o.object_id
        AND parent_id is null

    </querytext>
  </fullquery>

  <fullquery name="documents::create_folder.select_filestorage_id">
    <querytext>

        SELECT package_id
        FROM acs_objects o, site_nodes s
        WHERE o.object_id = s.object_id
        AND parent_id = :parent_node_id
        AND name = 'file-storage'

    </querytext>
  </fullquery>



</queryset>
