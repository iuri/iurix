-- Create custom sort function 
CREATE OR REPLACE FUNCTION custom_sort(text[], timestamptz)
RETURNS INT AS $$
  DECLARE
    v_pos integer;
    
  BEGIN
  
    RAISE NOTICE 'VALUE: %', $2;
    FOR i in array_lower($1, 1)..array_upper($1, 1) LOOP
      RAISE NOTICE 'DOW: %', $1[i];
    END LOOP;
    
    SELECT j INTO v_pos  FROM (
      SELECT generate_series(array_lower($1,1),array_upper($1,1))
    ) g(j)
    WHERE $1[j] = EXTRACT('dow' FROM $2::date)::text
    LIMIT 1;

    RAISE NOTICE 'RESULT: %', v_pos;

    RETURN v_pos;
    
  END;
$$ LANGUAGE plpgsql;
	    
