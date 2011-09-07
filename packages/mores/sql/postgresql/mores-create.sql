--
-- The MoReS Package
--
-- @author Breno Assunção (assuncao.b@gmail.com)
-- @creation-date 2010-11-20
--
-- @author Iuri Sampaio (iuri.sampaio@iurix.com)
-- @creation-date 2011-09-07
--
-- create the object types




--
-- Accounts
--
SELECT acs_object_type__create_type (
    'mores_account', 		-- object_type
    'Account',        		-- pretty_name
    'Accounts',        		-- pretty_plural
    'acs_object',       	-- supertype
    'mores_accounts',   	-- table_name
    'account_id',  			-- id_column
    'mores_account.name',   -- name_method
    'f',
    null,
    null
);


CREATE TABLE mores_accounts (
       account_id	    integer primary key
			    constraint account_id_fk 
			    references acs_objects (object_id) on delete cascade,
       name		    varchar NOT NULL,
       description     	    varchar ,
       num_querys	    integer ,
       package_id	    integer NOT NULL
);


CREATE OR REPLACE FUNCTION mores_account__new (
    integer, -- account_id
    varchar, -- name
    varchar, -- description
    integer, -- num_querys
    integer, -- package_id
    timestamp WITH time zone, -- creation_date
    integer, -- creation_user
    varchar, -- creation_ip
    integer  -- context_id
) RETURNS integer AS '
DECLARE
    p_account_id	ALIAS FOR $1;
    p_name       	ALIAS FOR $2;
    p_description      	ALIAS FOR $3;
    p_num_querys	ALIAS FOR $4;
    p_package_id  	ALIAS FOR $5;
    p_creation_date     ALIAS FOR $6;
    p_creation_user     ALIAS FOR $7;
    p_creation_ip       ALIAS FOR $8;
    p_context_id        ALIAS FOR $9;
  
    v_account_id	integer;
BEGIN

	v_account_id := acs_object__new (
		p_account_id, 	 		 -- object_id
		''mores_account'',  	 -- object_type
		p_creation_date,         -- creation_date
		p_creation_user,         -- creation_user
		p_creation_ip,           -- creation_ip
		p_context_id,            -- context_id
	    p_name,                  -- title
        p_package_id             -- package_id
	);

	INSERT INTO mores_accounts
	   (account_id, name, description, num_querys, package_id)
	VALUES
	   (v_account_id, p_name, p_description, p_num_querys, p_package_id);

	RETURN v_account_id;
END;' language 'plpgsql';



CREATE OR REPLACE FUNCTION mores_account__del (integer) 
RETURNS integer AS '
DECLARE
    p_account_id         alias for $1;
BEGIN
    PERFORM acs_object__delete(p_account_id);

    RETURN 0;
END;' language 'plpgsql';



CREATE OR REPLACE FUNCTION mores_account__edit (
    integer, -- account_id
    varchar, -- name
    varchar, -- description
    integer  -- num_querys
)
RETURNS integer AS '
DECLARE
    p_account_id    alias for $1;
    p_name       	alias for $2;
    p_description   alias for $3;
    p_num_querys	alias for $4;
BEGIN
	update mores_accounts
	set name = p_name,
	    description = p_description,
	    num_querys = p_num_querys 	    
	where account_id = p_account_id;
	return 0;
END;' language 'plpgsql';






----
-- Mores_acc_query
----
SELECT acs_object_type__create_type (
    'mores_query', 		-- object_type
    'Mores query',         -- pretty_name
    'Mores Querys',       -- pretty_plural
    'acs_object',       	-- supertype
    'mores_acc_query',   -- table_name
    'query_id',        	-- id_column
    'mores_query.name',   -- name_method
    'f',
    null,
    null
);

CREATE TABLE mores_acc_query (
		query_id	   		   integer 
						   CONSTRAINT mores_query_id_pk 
						   REFERENCES acs_objects (object_id) ON DELETE CASCADE,
		account_id         		   integer NOT NULL,
		query_text       		   varchar NOT NULL,
		isactive	   		   boolean NOT NULL,
		last_request 			   timestamp with time zone DEFAULT now(),
		CONSTRAINT mores_acc_query_unique UNIQUE (account_id, query_text),
		CONSTRAINT mores_acc_query_unique_id UNIQUE (query_id),
		CONSTRAINT mores_acc_query_account_id_fk FOREIGN KEY (account_id) REFERENCES mores_accounts (account_id) ON UPDATE NO ACTION ON DELETE CASCADE
);


CREATE OR REPLACE FUNCTION mores_query__new (
    integer, -- query_id
    integer, -- account_id
    varchar, -- query_text
    boolean, -- isactive
    timestamp with time zone, -- last_request
    integer, -- package_id
    timestamp with time zone, -- creation_date
    integer, -- creation_user
    varchar, -- creation_ip
    integer  -- context_id
) RETURNS integer AS '
DECLARE
	p_query_id		ALIAS FOR $1;
	p_account_id       	alias for $2;
	p_query_text   	    	alias for $3;
	p_isactive 	    	alias for $4;
	p_last_request		alias for $5;
	p_package_id          	alias for $6;
	p_creation_date        	alias for $7;
	p_creation_user         alias for $8;
    	p_creation_ip           alias for $9;
    	p_context_id            alias for $10;
  
	v_query_id   integer;
BEGIN

	v_query_id := acs_object__new (
		p_query_id,  			 -- object_id
		''mores_query'',    	 -- object_type
		p_creation_date,         -- creation_date
		p_creation_user,         -- creation_user
		p_creation_ip,           -- creation_ip
		p_context_id,            -- context_id
	    p_query_text,                  -- title
        p_package_id             -- package_id
	);

	insert into mores_acc_query
	   (query_id, account_id, query_text, isactive, last_request)
	values
	   (v_query_id, p_account_id, p_query_text, p_isactive, p_last_request);

	RETURN v_query_id;
END;' language 'plpgsql';



CREATE OR REPLACE FUNCTION mores_query__del (
    integer -- query_id
) RETURNS integer AS '
DECLARE
    p_query_id         alias for $1;
BEGIN
    perform acs_object__delete(p_query_id);
	return 0;
END;' language 'plpgsql';

CREATE OR REPLACE FUNCTION mores_query__edit( 
       integer, -- query_id
       varchar -- query_text
) RETURNS integer AS '
DECLARE
    p_query_id    alias for $1;
    p_query_text       	alias for $2;

BEGIN
	update mores_acc_query
	set query_text = p_query_text
	where query_id = p_query_id;
	return 0;
END;' LANGUAGE 'plpgsql' VOLATILE;

CREATE OR REPLACE FUNCTION mores_query__last_request (
    integer, -- query_id
    timestamp WITH time zone -- last_request
) RETURNS integer AS '
DECLARE 
    p_query_id    		alias for $1;
    p_last_request     	alias for $2;

BEGIN
	update mores_acc_querys
	set last_request = p_last_request
	where query_id = p_query_id;
	return 0;
END;' language 'plpgsql';




CREATE OR REPLACE FUNCTION mores_query__change_state (
    integer, -- query_id
    boolean -- isactive t or f (true- active false deactive)
) RETURNS integer AS '
DECLARE
    p_query_id 		alias for $1;
    p_isactive     	alias for $2;

BEGIN
	update mores_acc_query
	set isactive = p_isactive
	where query_id = p_query_id;

	RETURN 0;
END;' language 'plpgsql';



---
-- mores_aux
---
CREATE TABLE mores_aux (
       attribute       character varying,
       value_char      character varying,
       value_int       integer,
       value_date      timestamp without time zone,
       CONSTRAINT mores_aux_unique UNIQUE (attribute)
);


----
-- items
----

CREATE TABLE mores_items(
       mores_post_id 	  serial NOT NULL
       			  CONSTRAINT mores_items_pk PRIMARY KEY,
       query_id		  integer NOT NULL,
       user_id 		  character varying,
       user_nick 	  character varying,
       user_name 	  character varying,
       profile_img 	  character varying,
       post_id 		  character varying NOT NULL,
       created_at 	  timestamp with time zone NOT NULL,
       updated_at 	  timestamp with time zone,
       title 		  character varying,
       text		  character varying NOT NULL,
       lang 		  character varying,
       source 		  character varying NOT NULL,
       favicon 		  character varying,
       domain		  character varying NOT NULL,
       post_url		  character varying NOT NULL,
       post_img		  character varying,
       to_user		  character varying,
       type		  character varying,
       feeling		  smallint NOT NULL DEFAULT 0,
       likes		  integer,
       comments		  integer,
       CONSTRAINT mores_items_query_id_key UNIQUE (query_id, created_at, source, post_id)
) WITH (
  OIDS=TRUE
);


CREATE TABLE mores_items_tmp (
       user_id		     varchar,
       user_nick	     varchar,
       user_name	     varchar,
       profile_img	     varchar,
       post_id		     varchar NOT NULL,
       created_at	     timestamp WITH time zone NOT NULL,
       text		     varchar NOT NULL,
       lang		     varchar,
       post_url		     varchar NOT NULL,
       type		     varchar,
       followers	     integer, 
       following	     integer,
       favorites	     integer,
       statuses		     integer,
       verified		     integer,
       CONSTRAINT mores_items_tmp_post_id_key UNIQUE (post_id)
);




CREATE OR REPLACE FUNCTION mores_items__new (
       integer, 					-- query_id
       varchar, 					-- user_id
       integer, 					-- user_nick
       varchar, 					-- user_name   
       varchar, 					--	profile_img	
       integer, 					--	post_id     
       timestamp with time zone, 	--	created_at 	
       timestamp with time zone, 	--	updated_at  
       varchar, 					--	title       
       varchar ,					-- text        
       varchar,					--  lang       
       varchar ,					--  source      
       varchar,					--  favicon    
       varchar ,					-- 	domain      		
       varchar ,					--  post_url    
       varchar,  					--	post_img    
       varchar, 					--	to_user     
       varchar						--	type        
) RETURNS integer AS '
DECLARE
	p_query_id			alias for $1;
	p_user_id			alias for $2;
	p_user_nick			alias for $3;
	p_user_name			alias for $4;
	p_profile_img		alias for $5;
	p_post_id			alias for $6;
	p_created_at		alias for $7;
	p_updated_at		alias for $8;
	p_title				alias for $9;
	p_text				alias for $10;
	p_lang				alias for $11;
	p_source			alias for $12;
	p_favicon 			alias for $13;
	p_domain			alias for $14;
	p_post_url			alias for $15;
	p_post_img 			alias for $16;
	p_to_user			alias for $17;
	p_type				alias for $18;
  
begin

	insert into mores_items
	   (query_id,user_id, user_nick, user_name, profile_img, post_id, created_at, updated_at, title, text, lang, source, favicon, domain, post_url, post_img, to_user, type)
	values
	   (p_query_id,	p_user_id, p_user_nick, p_user_name, p_profile_img, p_post_id,p_created_at,p_updated_at, p_title, p_text, p_lang, p_source, p_favicon, p_domain, p_post_url, p_post_img, p_to_user, p_type);

	return 1;
end;
' language 'plpgsql';

-- arg. query_id
CREATE OR REPLACE FUNCTION mores_items__del_from_query_id (integer)
RETURNS integer AS '
DECLARE 
    p_query_id         alias for $1;
BEGIN
    DELETE FROM mores_items WHERE query_id = p_query_id;
    
    RETURN 0;
END;' language 'plpgsql';







CREATE TABLE mores_users_twitter (
       user_id			 character varying, 
       user_name 		 character varying, 
       followers 		 integer, 
       following 		 integer, 
       listed 			 integer, 
       tweets			 integer, 
       name 			 character varying, 
       account_id integer NOT NULL, 
       CONSTRAINT "mores_users_twitter_PK" PRIMARY KEY (user_id, account_id), 
       CONSTRAINT "mores_users_twitter_account_id_FK" FOREIGN KEY (account_id) REFERENCES mores_accounts (account_id) ON UPDATE NO ACTION ON DELETE CASCADE
) WITH (
  OIDS = FALSE
);


CREATE TABLE mores_stat_source (
       account_id 	       integer,
       source 		       character varying,
       qtd 		       integer,
       lang	  	       character varying,
       updated_at 	       date
) WITH (
  OIDS=FALSE
);

CREATE TABLE mores_stat_twt_usr (
       account_id		integer NOT NULL,
       user_id 			character varying NOT NULL,
       qtd 			integer,
       lang	  	      	character varying,
       query_id			integer,
       updated_at 		date
) WITH (
  OIDS=FALSE
);


   
CREATE TABLE mores_stat_graph (
       query_id 	      integer,
       data 		      character varying NOT NULL,
       qtd 		      integer,
       tipo 		      character varying,
       updated_at 	      timestamp without time zone DEFAULT now(),
       lang	  	      character varying,
       source		      character varying,
       account_id	      integer,
       date 		      date
) WITH (
  OIDS=FALSE
);




CREATE TABLE mores_stat_source_query (
       account_id		     integer,
       query_id			     integer,
       source 			     character varying,
       qtd			     integer,
       lang	  	      	     character varying,
       updated_at		     date
) WITH (
  OIDS=TRUE
);




CREATE TABLE mores_feeling (
       query_id		      integer NOT NULL,
       lang		      character varying,
       source		      character varying NOT NULL,
       mores_post_id	      integer NOT NULL,
       feeling		      smallint NOT NULL DEFAULT 0)
WITH (
  OIDS=TRUE
);
