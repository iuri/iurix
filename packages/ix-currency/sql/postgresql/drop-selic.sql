


DROP FUNCTION ix_selic_rate__new (
       numeric,	  	   -- rate
       varchar,		   -- type
       timestamp   	   -- date
);

DROP FUNCTION ix_selic_rate__delete (
       integer		   -- rate_id
);


DROP SEQUENCE ix_selic_rate_id_seq;

DROP TABLE ix_selic_rates;



DROP TABLE ix_selic_results;




DROP SEQUENCE ix_selic_result_id_seq;
