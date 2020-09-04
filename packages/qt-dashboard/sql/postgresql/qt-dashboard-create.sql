-- /packages/qt-dashboard/sql/postgresql/qt-dashboard-create.sql
--
-- @author Iuri de Araujo (iuri@iurix.com)
-- @creation-date 13 July 2020
--


--
-- Faces
--
select content_type__create_type (
       'qt_face',    -- content_type
       'content_revision',       -- supertype. We search revision content 
                                 -- first, before item metadata
       'Qonteo Face',    -- pretty_name
       'Qonteo Faces',   -- pretty_plural
       NULL,        -- table_name
       -- IURI: acs_object_types supports a null table name so we do that
       -- instead of passing a false value so we can actually use the
       -- content repository instead of duplicating all the code in file-storage
       NULL,	         -- id_column
       'qt_face__get_title' -- name_method
);

-- necessary to work around limitation of content repository:
select content_folder__register_content_type(-100,'qt_face','t');


--
-- Vehicles
--
select content_type__create_type (
       'qt_vehicle',    -- content_type
       'content_revision',       -- supertype. We search revision content 
                                 -- first, before item metadata
       'Qonteo Vehicle',    -- pretty_name
       'Qonteo Vehicles',   -- pretty_plural
       NULL,        -- table_name
       -- IURI: acs_object_types supports a null table name so we do that
       -- instead of passing a false value so we can actually use the
       -- content repository instead of duplicating all the code in file-storage
       NULL,	         -- id_column
       'qt_vehicle__get_title' -- name_method
);

-- necessary to work around limitation of content repository:
select content_folder__register_content_type(-100,'qt_vehicle','t');




CREATE FUNCTION dynamic_pivot(central_query text, headers_query text)
 RETURNS refcursor AS
 $$
 DECLARE
   left_column text;
     header_column text;
       value_column text;
         h_value text;
	   headers_clause text;
	     query text;
	       j json;
	         r record;
		   curs refcursor;
		     i int:=1;
		     BEGIN
		       -- find the column names of the source query
		         EXECUTE 'select row_to_json(_r.*) from (' ||  central_query || ') AS _r' into j;
			   FOR r in SELECT * FROM json_each_text(j)
			     LOOP
			         IF (i=1) THEN left_column := r.key;
				       ELSEIF (i=2) THEN header_column := r.key;
				             ELSEIF (i=3) THEN value_column := r.key;
					         END IF;
						     i := i+1;
						       END LOOP;

  --  build the dynamic transposition query (based on the canonical model)
    FOR h_value in EXECUTE headers_query
      LOOP
          headers_clause := concat(headers_clause,
	       format(chr(10)||',min(case when %I=%L then %I::text end) as %I',
	                  header_column,
				   h_value,
					   value_column,
						   h_value ));
						     END LOOP;

  query := format('SELECT %I %s FROM (select *,row_number() over() as rn from (%s) AS _c) as _d GROUP BY %I order by min(rn)',
             left_column,
		   headers_clause,
			   central_query,
				   left_column);

  -- open the cursor so the caller can FETCH right away
    OPEN curs FOR execute query;
    RETURN curs;
  END
$$ LANGUAGE plpgsql;
