---------
-- qt_uptime_resources
---------
DROP table qt_uptime_resources;
create table qt_uptime_resources (
    id			integer
    			constraint qt_ur_id_pk primary key,
    creation_date	timestamp,
    last_modified	timestamp,
    resource		varchar UNIQUE,
    status		boolean DEFAULT FALSE 
);

DROP SEQUENCE qt_uptime_resources_id_seq;
CREATE SEQUENCE qt_uptime_resources_id_seq cache 1000;


DROP FUNCTION uptime_resources__update(integer);
CREATE OR REPLACE FUNCTION uptime_resources__update (
       p_id	  	   integer
) RETURNS integer AS $$
  BEGIN
	UPDATE qt_uptime_resources
	SET last_modified = now(), status = TRUE
	WHERE id = p_id;
	
	RETURN 0;
  END; $$ language plpgsql;



CREATE OR REPLACE FUNCTION inline_0 () RETURNS integer AS $$
  BEGIN
	INSERT INTO qt_uptime_resources (id, creation_date, resource)
	VALUES (nextval('qt_uptime_resources_id_seq'), now(), 'CCPNTTN001');

	INSERT INTO qt_uptime_resources (id, creation_date, resource)
	VALUES (nextval('qt_uptime_resources_id_seq'), now(), 'CCPNTTN002');

	INSERT INTO qt_uptime_resources (id, creation_date, resource)
	VALUES (nextval('qt_uptime_resources_id_seq'), now(), 'CCPNSNR001');

  	RETURN 0;

  END; $$ language plpgsql;
  

SELECT inline_0 ();
DROP FUNCTION inline_0();
