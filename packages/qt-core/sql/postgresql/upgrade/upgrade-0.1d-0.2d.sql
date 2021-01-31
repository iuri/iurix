DROP FUNCTION qt_totals__new (timestamp, numeric, numeric, numeric, numeric, varchar, varchar);

SELECT define_function_args('qt_totals__new', 'creation_date timestamp, total1 numeric, total2 numeric, total3 numeric, percentage numeric, hostname varchar, content_type varchar');

CREATE OR REPLACE FUNCTION qt_totals__new (
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






DROP FUNCTION qt_totals__edit (integer, numeric, numeric, numeric, numeric);

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
