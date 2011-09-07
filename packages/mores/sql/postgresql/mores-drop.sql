DROP FUNCTION mores_account__new (integer, varchar, varchar, integer, integer, timestamp with time zone, integer, varchar, integer);

DROP FUNCTION mores_account__del (integer);

DROP FUNCTION mores_account__edit (integer, varchar, varchar, integer);

DROP FUNCTION mores_query__new (integer, integer, varchar, boolean, timestamp with time zone, integer,timestamp with time zone, integer, varchar, integer);

DROP FUNCTION mores_query__del (integer );

DROP FUNCTION mores_query__edit (integer, varchar);

DROP FUNCTION mores_query__last_request (integer, timestamp with time zone);

DROP FUNCTION mores_query__change_state (integer, boolean);

DROP FUNCTION mores_items__new (integer,varchar,integer,varchar,varchar,integer,timestamp with time zone,timestamp with time zone, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar);

DROP FUNCTION mores_items__del_from_query_id (integer);

CREATE FUNCTION inline_0 ()
RETURNS integer AS '
BEGIN
    PERFORM acs_object_type__drop_type (''mores_account'', ''f'');

    RETURN NULL;
END;' language 'plpgsql';

SELECT inline_0();
DROP FUNCTION inline_0 ();

CREATE FUNCTION inline_0 ()
RETURNS integer AS '
BEGIN
    PERFORM acs_object_type__drop_type (''mores_query'', ''f'');

    RETURN NULL;
END;' language 'plpgsql';

SELECT inline_0 ();
DROP FUNCTION inline_0 ();



DROP TABLE mores_accounts cascade;
DROP TABLE mores_acc_query;
DROP TABLE mores_aux;    
DROP TABLE mores_items;    
DROP TABLE mores_items_tmp;    
DROP TABLE mores_users_twitter;
DROP TABLE mores_stat_source;
DROP TABLE mores_stat_twt_usr;
DROP TABLE mores_stat_graph;
DROP TABLE mores_feeling;
DROP TABLE mores_stat_source_query; 





   

