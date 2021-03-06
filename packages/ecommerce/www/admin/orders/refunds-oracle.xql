<?xml version="1.0"?>
<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<partialquery name="last_24">
      <querytext>
      and sysdate-r.refund_date <= 1
      </querytext>
</partialquery>


<partialquery name="last_week">
      <querytext>
      and sysdate-r.refund_date <= 7
      </querytext>
</partialquery>


<partialquery name="last_month">
      <querytext>
      and months_between(sysdate,r.refund_date) <= 1
      </querytext>
</partialquery>

 
</queryset>
