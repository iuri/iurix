<?xml version="1.0"?>
<queryset>

  <fullquery name="alter_table_drop">      
    <querytext>
      -- PostgrSQL 7.1.2 will fail on this query as it doesn't support dropping of constraints --
      alter table ec_custom_product_field_values 
      drop constraint ${field_identifier}_constraint
    </querytext>
  </fullquery>
  
  <fullquery name="alter_table_modify">      
    <querytext>
      -- PostgrSQL 7.1.2 will fail on this query as it can't modify columns --
   	    ALTER TABLE ec_custom_product_field_values
	    ALTER COLUMN $field_identifier TYPE $column_type
    </querytext>
  </fullquery>
  
  <fullquery name="alter_table_modify_audit">      
    <querytext>
      -- PostgrSQL 7.1.2 will fail on this query as it can't modify columns --
	    ALTER TABLE ec_custom_p_field_values_audit
	    ALTER COLUMN $field_identifier TYPE $column_type
    </querytext>
  </fullquery>
  
</queryset>
