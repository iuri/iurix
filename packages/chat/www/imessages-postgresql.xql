<?xml version="1.0"?>

<queryset>
<rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="rooms_list">
  <querytext>
    select rm.room_id, 
           rm.pretty_name, 
           rm.description, 
           rm.moderated_p, 
           rm.active_p, 
           rm.archive_p,
           obj.creation_user as author_id,
           u.first_names || ' ' || u.last_name as author,
           acs_permission__permission_p(rm.room_id, :user_id, 'chat_room_admin') as admin_p,
           acs_permission__permission_p(rm.room_id, :user_id, 'chat_read') as user_p,           
           (select site_node__url(site_nodes.node_id)
                   from site_nodes
                   where site_nodes.object_id = obj.context_id) as base_url
    from chat_rooms rm, 
         acs_objects obj,
         cc_users u,
         chat_instant_rooms cir
    where rm.room_id = obj.object_id
    and rm.room_id = cir.room_id
    and   obj.context_id = :package_id
    and   obj.creation_user = u.user_id
    order by rm.pretty_name
  </querytext>
</fullquery>

</queryset>

