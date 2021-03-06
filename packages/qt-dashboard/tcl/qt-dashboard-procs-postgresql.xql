<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

   <fullquery name="qt::dashboard::get_types_total_per_day_not_cached.select_types_count">      
      <querytext>
            
	SELECT date, type, count FROM qt_select_types_count  WHERE 1 = 1 $where_clauses;
	
      </querytext>
   </fullquery>

   <fullquery name="qt::dashboard::get_past_totals_per_hour_not_cached.select_past_totals_per_hour">      
      <querytext>
        SELECT EXTRACT('hour' FROM creation_date) AS hour,
	COUNT(1) AS total FROM qt_vehicle_ti
	WHERE title != 'UNKNOWN'
	AND creation_date::date <= :current_date::date - INTERVAL '1 day'
	GROUP BY hour
	ORDER BY hour ASC			
      </querytext>
   </fullquery>  
</queryset>
