CREATE OR REPLACE FUNCTION ix_currency_rate__new (
       varchar,	  	   -- currency_code
       varchar,		   -- rate
       timestamptz	   -- date
) RETURNS integer AS '
  DECLARE
	p_currency_code		ALIAS FOR $1;
	p_rate			ALIAS FOR $2;
	p_date			ALIAS FOR $3;
       	v_id			integer;

  BEGIN
	
	SELECT nextval(''ix_currency_rate_id_seq'') INTO v_id;

	INSERT INTO ix_currency_rates (
		rate_id,
		currency_code,
		rate,
		creation_date
	) VALUES (
		v_id,
		p_currency_code,
		p_rate,
		p_date
	);

	RETURN v_id;

END;' language 'plpgsql';
