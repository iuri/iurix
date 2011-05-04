<?xml version="1.0"?>

<queryset>
<rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="select_msg_items">
  <querytext>
	select to_char(creation_date, 'DD.MM.YYYY HH24:MI:SS') as creation_date_pretty, 
	       creation_user, 
	       msg
    from chat_msgs 
    where room_id  = :room_id 
      and rownum <= 20 
    order by creation_date desc
  </querytext>
</fullquery>

</queryset>

