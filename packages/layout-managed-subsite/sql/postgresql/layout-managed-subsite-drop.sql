-- delete layout-managed-subsite context

CREATE or REPLACE FUNCTION inline_0 () 
returns integer as '
DECLARE 
	row1 RECORD;
	row2 RECORD;
	row3 RECORD;

BEGIN
  FOR row1 IN

    SELECT package_id FROM apm_packages WHERE package_key = ''layout-managed-subsite'';

  LOOP
    FOR row2 IN

      SELECT object_id from acs_objects WHERE context_id = row1.package_id;

    LOOP
	FOR row3 IN 
	
	  SELECT object_id FROM acs_objects WHERE context_id = row2.object_id;

        LOOP
	
	  SELECT acs_rel__delete(row3.object_id);
	  DELETE FROM application_groups WHERE group_id = row3.object_id;
	  SELECT application_group__delete(row3.object_id);

	END LOOP;

    END LOOP;
	  SELECT apm_service__delete(row2.object_id);
	  
  END LOOP;

  RETURN 0;
END;' language 'plpgsql'; 																   	  

SELECT inline_0 ();
DROP FUNCTION inline_0 ();