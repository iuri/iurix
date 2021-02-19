---------
-- qt_totals
---------
DROP table qt_face_totals;
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

DROP SEQUENCE qt_face_totals_total_id_seq;
CREATE SEQUENCE qt_face_totals_total_id_seq cache 1000;


DROP table qt_face_range_totals;
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

DROP SEQUENCE qt_face_range_totals_range_id_seq;
CREATE SEQUENCE qt_face_range_totals_range_id_seq cache 1000;



-- create sequence t_qt_total_id_seq;
-- create view qt_total_id_seq as
-- select nextval('t_qt_total_id_seq') as nextval;


DROP FUNCTION qt_face_totals__new (
       integer,
       timestamp, 
       numeric, 
       numeric, 
       numeric,
       numeric,
       varchar,
       varchar
);

SELECT define_function_args('qt_face_totals__new', 'total_id integer, creation_date timestamp, total numeric, total_female numeric, total_male numeric, percentage numeric, hostname varchar, content_type varchar');

CREATE OR REPLACE FUNCTION qt_face_totals__new (
       p_total_id 	   integer,
       p_creation_date	   timestamp, 
       p_total		   numeric, 
       p_total_female	   numeric, 
       p_total_male	   numeric,
       p_percentage	   numeric,
       p_hostname	   varchar,
       p_content_type	   varchar
) RETURNS integer AS $$
  DECLARE
  BEGIN
	INSERT INTO qt_face_totals (
	       total_id,
	       creation_date,
	       total,
	       total_female,
	       total_male,
	       percentage, 
	       hostname,
	       content_type
	) VALUES (
	       nextval('qt_face_totals_total_id_seq'),
	       p_creation_date,
	       p_total,
	       p_total_female,
	       p_total_male,
	       p_percentage,
	       p_hostname,
	       p_content_type
	);

	RETURN 0;
  END; $$ language plpgsql;



DROP FUNCTION qt_face_totals__edit (
       integer,
       numeric, 
       numeric, 
       numeric,
       numeric
);

SELECT define_function_args('qt_face_totals__edit', 'total_id integer, total numeric, total_female numeric, total_male numeric, percentage numeric');

CREATE OR REPLACE FUNCTION qt_face_totals__edit (
       p_total_id 	   integer,
       p_total		   numeric, 
       p_total_female	   numeric, 
       p_total_total	   numeric,
       p_percentage	   numeric
) RETURNS integer AS $$
  DECLARE
  BEGIN
	UPDATE qt_face_totals SET 
	       total = p_total,
	       total_female = p_total_female,
	       total_male = p_total_male,
	       percentage = p_percentage
	WHERE total_id = p_total_id;

	RETURN 0;
  END; $$ language plpgsql;







DROP FUNCTION qt_face_range_totals__new (
       integer,
       varchar,
       timestamp, 
       numeric, 
       numeric, 
       numeric,
       numeric,
       varchar,
       varchar
);

SELECT define_function_args('qt_face_range_totals__new', 'range_id integer, range varchar, creation_date timestamp, total numeric, total_female numeric, total_male numeric, percentage numeric, hostname varchar, content_type varchar');

CREATE OR REPLACE FUNCTION qt_face_range_totals__new (
       p_range_id 	   integer,
       p_range		   varchar,
       p_creation_date	   timestamp, 
       p_total		   numeric, 
       p_total_female	   numeric, 
       p_total_male	   numeric,
       p_percentage	   numeric,
       p_hostname	   varchar,
       p_content_type	   varchar
) RETURNS integer AS $$
  DECLARE
  BEGIN
	INSERT INTO qt_face_range_totals (
	       range_id,
	       range,
	       creation_date,
	       total,
	       total_female,
	       total_male,
	       percentage, 
	       hostname,
	       content_type
	) VALUES (
	       nextval('qt_face_range_totals_range_id_seq'),
	       p_range,
	       p_creation_date,
	       p_total,
	       p_total_female,
	       p_total_male,
	       p_percentage,
	       p_hostname,
	       p_content_type
	);

	RETURN 0;
  END; $$ language plpgsql;



DROP FUNCTION qt_face_range_totals__edit (
       integer,
       varchar,
       numeric, 
       numeric, 
       numeric,
       numeric
);

SELECT define_function_args('qt_face_range_totals__edit', 'range_id integer, range varchar, total numeric, total_female numeric, total_male numeric, percentage numeric');

CREATE OR REPLACE FUNCTION qt_face_range_totals__edit (
       p_range_id 	   integer,
       p_range 	   	   varchar,
       p_total		   numeric, 
       p_total_female	   numeric, 
       p_total_male	   numeric,
       p_percentage	   numeric
) RETURNS integer AS $$
  DECLARE
  BEGIN
	UPDATE qt_face_range_totals SET
	       range_ = p_range,
	       total = p_total,
	       total_female = p_total_female,
	       total_male = p_total_male,
	       percentage = p_percentage
	WHERE range_id = p_range_id;

	RETURN 0;
  END; $$ language plpgsql;
