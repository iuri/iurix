-- Delete audio schema
-- iuri sampaio (iuri.sampaio@gmail.com)
-- date 2010-11-19


\i audios-notifications-drop.sql

CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS integer AS '
DECLARE

	row 	  record;
BEGIN 

      FOR row IN 
            SELECT audio_id FROM audios
      LOOP   
	    PERFORM content_item__delete(row.audio_id);
	    DELETE FROM audio_queue WHERE item_id = row.audio_id;
	    DELETE FROM audios WHERE audio_id = row.audio_id;
      END LOOP;
           
      RETURN 0;
END;' language 'plpgsql';

SELECT inline_0 ();
DROP FUNCTION inline_0 ();

SELECT content_type__drop_type('audio_object','t','t','t');
SELECT content_folder__unregister_content_type(-100,'audio_object','t');


DROP FUNCTION audio__new(integer,varchar,varchar,timestamp,integer,integer,integer,varchar,varchar,varchar);
DROP FUNCTION audio__delete(integer);

DROP TABLE audio_rank;
DROP TABLE audio_queue;
-- DROP TABLE audios CASCADE;
