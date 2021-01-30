---------
-- qt_totals
---------
create table qt_totals (
    qt_total_id			integer
    				constraint qt_total_id_pk primary key,
    creation_date		timestamp,
    total1			numeric,
    total2			numeric,
    total3			numeric,
    percentage			numeric,
    hostname			varchar,
    content_type		varchar(1000)
    				CONSTRAINT qt_totals_content_type_fk
				REFERENCES acs_object_types(object_type) ON DELETE CASCADE
);


CREATE SEQUENCE qt_total_id_seq cache 1000;


SELECT define_function_args('qt_totals__new', 'total_id integer, creation_date timestamp, total1 numeric, total2 numeric, total3 numeric, percentage numeric, hostname varchar, content_type varchar');

CREATE OR REPLACE FUNCTION qt_totals__new (
       p_total_id 	   integer,
       p_creation_date	   timestamp, 
       p_total1		   numeric, 
       p_total2		   numeric, 
       p_total3		   numeric,
       p_percentage	   numeric,
       p_hostname	   varchar,
       p_content_type	   varchar
) RETURNS integer AS $$
  DECLARE
  BEGIN
	INSERT INTO qt_totals (
	       qt_total_id,
	       creation_date,
	       total1,
	       total2,
	       total3,
	       percentage, 
	       hostname,
	       content_type
	) VALUES (
	       p_total_id,
	       p_creation_date,
	       p_total1,
	       p_total2,
	       p_total3,
	       p_percentage,
	       p_hostname,
	       p_content_type
	);

	RETURN 0;
  END; $$ language plpgsql;
