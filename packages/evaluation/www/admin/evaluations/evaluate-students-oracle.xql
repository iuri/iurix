<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="get_party_name">      
      <querytext>

			select evaluation.party_name(:party_id,:task_id) from dual
	
      </querytext>
</fullquery>

</queryset>
