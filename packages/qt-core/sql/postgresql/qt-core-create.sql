---------
-- qt_totals
---------
create table qt_face_totals (
    total_id			integer
    				constraint qt_ft_total_id_pk primary key,
    creation_date		timestamp,
    total			numeric,
    total_female		numeric,
    total_male			numeric,
    percentage			numeric,
    hostname			varchar,
    content_type		varchar(1000)
    				CONSTRAINT qt_ft_content_type_fk
				REFERENCES acs_object_types(object_type) ON DELETE CASCADE
);



create table qt_face_range_totals (
    range_id			integer
    				constraint qt_frt_range_id_pk primary key,
    range			varchar(100),
    creation_date		timestamp,
    total			numeric,
    total_male			numeric,
    total_female		numeric,
    percentage			numeric,
    hostname			varchar,
    content_type		varchar(1000)
    				CONSTRAINT qt_frt_content_type_fk
				REFERENCES acs_object_types(object_type) ON DELETE CASCADE
);




-- create sequence t_qt_total_id_seq;
-- create view qt_total_id_seq as
-- select nextval('t_qt_total_id_seq') as nextval;

CREATE SEQUENCE qt_totals_total_id_seq cache 1000;


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
	       nextval('qt_totals_total_id_seq'),
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




SELECT define_function_args('qt_totals__edit', 'total_id integer, total1 numeric, total2 numeric, total3 numeric, percentage numeric');

CREATE OR REPLACE FUNCTION qt_totals__edit (
       p_total_id 	   integer,
       p_total1		   numeric, 
       p_total2		   numeric, 
       p_total3		   numeric,
       p_percentage	   numeric
) RETURNS integer AS $$
  DECLARE
  BEGIN
	UPDATE qt_totals SET 
	       total1 = p_total1,
	       total2 = p_total2,
	       total3 = p_total3,
	       percentage = p_percentage
	WHERE qt_total_id = p_total_id;

	RETURN 0;
  END; $$ language plpgsql;
