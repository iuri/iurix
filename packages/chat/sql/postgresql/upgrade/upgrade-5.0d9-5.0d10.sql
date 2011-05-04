-- @author iuri sampaio ( iuri.sampaio@gmail.com )

CREATE TABLE chat_invitation_queue (
       id serial primary key,
       sender_user_id integer NOT NULL REFERENCES users(user_id),
       target_user_id integer NOT NULL REFERENCES users(user_id),
       room_id	      integer NOT NULL REFERENCES chat_rooms(room_id),
       ip 	      character varying (50),
       date_time      timestamptz,
       content	      text
);

       	
CREATE TABLE chat_instant_rooms (
       id serial primary key,
       user_id integer NOT NULL REFERENCES users(user_id),
       room_id integer NOT NULL REFERENCES chat_rooms(room_id)
);




CREATE TABLE chat_availability (
       id serial primary key,
       user_id integer NOT NULL REFERENCES users(user_id),
       active_p boolean DEFAULT 'f'
);



CREATE OR REPLACE FUNCTION chat_availability_switch (integer) 
RETURNS integer AS '
DECLARE
	p_user_id	ALIAS FOR $1;
	v_status	boolean;
	v_user_id	integer;
BEGIN 
      SELECT user_id INTO v_user_id FROM chat_availability WHERE user_id = p_user_id;
      IF v_user_id IS NULL THEN
      	 INSERT INTO chat_availability (user_id, active_p) VALUES (p_user_id,''f'');
      END IF;
      

      SELECT active_p INTO v_status FROM chat_availability WHERE user_id = p_user_id;

      IF v_status THEN
      	 UPDATE chat_availability SET active_p = ''f'' WHERE user_id = p_user_id;
      ELSE 
      	 UPDATE chat_availability SET active_p = ''t'' WHERE user_id = p_user_id;
      END IF; 
      
      RETURN 0;
      
END;' language 'plpgsql';


CREATE OR REPLACE FUNCTION chat_invitation__new (integer,integer,integer,varchar,timestamptz,varchar)
RETURNS integer AS '
DECLARE

	p_room_id		ALIAS for $1;
	p_sender_user_id	ALIAS for $2;
	p_target_user_id	ALIAS for $3;
	p_ip_addr		ALIAS for $4;
	p_date			ALIAS for $5;
	p_content		ALIAS for $6;
	
BEGIN
	INSERT INTO chat_invitation_queue (
		id, sender_user_id, target_user_id, ip, date, content
	) VALUES (
	  	p_room_id, p_sender_user_id, p_target_user_id, p_ip_addr, p_date, p_content
	);

	RETURN 0;

END;' language 'plpgsql';

CREATE OR REPLACE FUNCTION chat_invitation__delete (integer)
RETURNS integer AS '
DECLARE
	p_id	integer;
BEGIN
	DELETE FROM chat_invitation_queue WHERE id = p_id;
	
	RETURN 0;
END;' language 'plpgsql';

create or replace function chat_room__del (integer)
returns integer as '
declare
   p_room_id        alias for $1;
begin

    -- First erase all the messages relate to this chat room.
    delete from chat_msgs where room_id = p_room_id;

     -- Delete all privileges associate with this room
     delete from acs_permissions where object_id = p_room_id;

    -- Delete all transcripts  related to this chat room
    delete from chat_transcripts where room_id = p_room_id;

     -- Now delete the chat room itself.
     delete from chat_rooms where room_id = p_room_id;

     PERFORM acs_object__delete(p_room_id);

   return 0;
end;' language 'plpgsql';
