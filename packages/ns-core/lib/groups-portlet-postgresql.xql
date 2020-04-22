<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

   <fullquery name="groups_select">      
     <querytext>
    
       SELECT DISTINCT g.group_name, g.group_id
       FROM acs_objects o, groups g,  application_group_element_map app_group
       WHERE g.group_id = o.object_id  and o.object_type = 'application_group'
       AND g.group_id != 762 AND g.group_id != -2
       ORDER BY group_id DESC

    </querytext>
   </fullquery>
</queryset>
