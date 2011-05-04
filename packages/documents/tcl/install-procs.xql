<?xml version="1.0"?>
<queryset>
  <fullquery name="documents::install::after_install.select_node_id">
    <querytext>

        SELECT  node_id
        FROM site_nodes s, apm_packages p, acs_objects o
        WHERE p.package_key = 'acs-subsite'
        AND p.package_id = o.package_id 
        AND s.object_id = o.object_id
        AND parent_id is null

    </querytext>
  </fullquery>

  <fullquery name="documents::install::after_install.select_filestorage_id">
    <querytext>

        SELECT package_id
        FROM acs_objects o, site_nodes s
        WHERE o.object_id = s.object_id
        AND parent_id = :parent_node_id
        AND name = 'file-storage'

    </querytext>
  </fullquery>

</queryset>
