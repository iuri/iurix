CREATE TABLE audios(
       audio_id			integer
       	      constraint audios_audio_fk 
	      references cr_items on delete cascade
              constraint audios_audio_pk 
	      primary key,
       audio_name  		varchar(255)
              constraint audios_audio_name_nn not null,
       audio_description	text,
       audio_date		timestamptz default now(),
       package_id   		integer
              constraint audios_package_id_fk 
	      references apm_packages on delete cascade,
       creator_id		integer,
       group_id		        integer,
       author			varchar(255),
       coauthor			varchar(255),
       source 		        varchar(255)
);

create table audio_queue (
    item_id                         integer
                                    constraint audios_queue_item_id_fk
                                    references cr_items (item_id)
);

CREATE TABLE audio_rank (
       item_id		integer
			constraint audios_rank_item_id_fk
			references cr_items (item_id),
       rank		integer
);

SELECT content_type__create_type (
       'audio_object',		-- content_type
       'content_revision',	-- supertype
       'Audio Object',		-- pretty_name
       'Audio Objects',		-- pretty_plural
       'audios',		-- table_name
       'audio_id',		-- id_column
       'audio__get_titile'	-- name_method
);


	


SELECT content_folder__register_content_type(-100,'audio_object','t');


CREATE OR REPLACE FUNCTION tags__delete(int4)
  RETURNS int4 AS '
  
    DECLARE
      p_item_id		alias for $1;

    BEGIN

	delete from tags_tags
	where item_id = p_item_id;

	RETURN 0;

    END;' language 'plpgsql';


CREATE OR REPLACE FUNCTION audio__delete (integer)
RETURNS integer AS '
DECLARE
	p_item_id alias for $1;

	row_messages	record;

BEGIN
	PERFORM tags__delete(p_item_id);

	FOR row_messages IN
            SELECT message_id FROM acs_messages m, acs_objects o WHERE o.object_id = m.message_id AND o.object_type = ''acs_message''
    	LOOP	
		PERFORM acs_message__delete(row_messages.message_id);
	END LOOP;



	DELETE FROM audio_queue where item_id = p_item_id;
	DELETE FROM audio_rank where item_id = p_item_id;
	DELETE FROM audios WHERE audio_id = p_item_id;

	PERFORM content_item__delete(p_item_id);

	RETURN 0;
END;' language 'plpgsql';


CREATE OR REPLACE FUNCTION audio__new (integer,varchar,varchar,timestamp,integer,integer,integer,varchar,varchar,varchar)
RETURNS integer AS '
DECLARE
    p_audio_id 			alias for $1;
    p_audio_name		alias for $2;
    p_audio_description		alias for $3;
    p_audio_date		alias for $4;
    p_package_id 		alias for $5;
    p_creator_id		alias for $6;
    p_group_id			alias for $7;
    p_author			alias for $8;
    p_coauthor			alias for $9;
    p_source			alias for $10;
        
    
BEGIN
 	--insert into audios a new audio
	INSERT INTO audios (audio_id, 
			    audio_name, 
			    audio_description,
			    audio_date,
			    package_id,
			    creator_id,
			    group_id,
			    author,
			    coauthor,
			    source
        ) VALUES (
			    p_audio_id, 
			    p_audio_name, 
			    p_audio_description,
			    p_audio_date,
			    p_package_id,
			    p_creator_id,
			    p_group_id,
			    p_author,
			    p_coauthor,
			    p_source
        );
	
      
        RETURN 0;
END;' LANGUAGE 'plpgsql' VOLATILE;

\i audios-notifications-create.sql

