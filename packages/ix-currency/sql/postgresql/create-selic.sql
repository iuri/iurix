
CREATE TABLE ix_selic_rates (
       rate_id		      integer
       			      CONSTRAINT ix_rate_id_pk PRIMARY KEY,
       rate      	      numeric,
       type		      varchar(1),
       date	      	      timestamp
);




CREATE SEQUENCE ix_selic_rate_id_seq;

CREATE TABLE ix_selic_results (
       result_id	      integer
       			      CONSTRAINT ix_result_id_pk PRIMARY KEY,
       value     	      numeric,
       value_tax	      numeric,
       value_fee	      numeric,
       tax_fee		      numeric,       
       subtotal		      numeric,
       total		      numeric,       
       creation_date	      timestamp,
       ack_date		      timestamp,
       expiration_date	      timestamp       
);




CREATE SEQUENCE ix_selic_result_id_seq;


------------------------------------
-- Object Type: ix_selic_rate
------------------------------------

CREATE OR REPLACE FUNCTION ix_selic_rate__new (
       numeric,	  	   -- rate
       varchar,		   -- type
       timestamp   	   -- date
) RETURNS integer AS '
  DECLARE
	p_rate			ALIAS FOR $1;
	p_type			ALIAS FOR $2;
	p_date			ALIAS FOR $3;
       	v_id			integer;

  BEGIN
	
	SELECT nextval(''ix_selic_rate_id_seq'') INTO v_id;

	INSERT INTO ix_selic_rates (
		rate_id,
		rate,
		type,
		date
	) VALUES (
		v_id,
		p_rate,
		p_type,
		p_date	
	);

	RETURN v_id;

END;' language 'plpgsql';



CREATE OR REPLACE FUNCTION ix_selic_rate__delete (
       integer		   -- rate_id
) RETURNS integer AS '
  DECLARE
	p_rate_id			ALIAS FOR $1;

  BEGIN

  	DELETE FROM ix_rates WHERE rate_id = p_rate_id;
	

	RETURN 0;
  END;' language 'plpgsql';



