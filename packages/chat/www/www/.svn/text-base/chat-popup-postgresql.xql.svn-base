<?xml version="1.0"?>

<queryset>
<rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="select_msg_items">
  <querytext>
	select to_char(creation_date, 'DD.MM.YYYY hh24:mi:ss') as creation_date_pretty, 
	       creation_user, 
	       msg
    from chat_msgs 
    where room_id  = :room_id 
    order by creation_date desc
    limit 20 
  </querytext>
</fullquery>

</queryset>

