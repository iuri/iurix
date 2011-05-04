
alter table chat_rooms add column auto_flush_p boolean;
alter table chat_rooms alter column auto_flush_p set default 't';

alter table chat_rooms add column auto_transcript_p boolean;
alter table chat_rooms alter column auto_transcript_p set default 'f';

update chat_rooms set auto_flush_p = 't', auto_transcript_p = 'f';

alter table chat_msgs add column creation_date2 timestamptz;
update chat_msgs set creation_date2 = creation_date;
alter table chat_msgs drop column creation_date;
alter table chat_msgs rename column creation_date2 to creation_date;

create or replace function chat_room__edit (integer, varchar, varchar, boolean, boolean, boolean, boolean, boolean)
returns integer as '
declare
   p_room_id        alias for $1;
   p_pretty_name    alias for $2;
   p_description    alias for $3;
   p_moderated_p    alias for $4;
   p_active_p       alias for $5;
   p_archive_p      alias for $6;
   p_auto_flush_p      alias for $7;
   p_auto_transcript_p      alias for $8;
begin

        update chat_rooms set
            pretty_name = p_pretty_name,
            description = p_description,
            moderated_p = p_moderated_p,
            active_p    = p_active_p,
            archive_p   = p_archive_p,
            auto_flush_p   = p_auto_flush_p,
            auto_transcript_p   = p_auto_transcript_p
        where
            room_id = p_room_id;
        return 0;
end;' language 'plpgsql';

create or replace function chat_room__new (integer, varchar, varchar, boolean, boolean, boolean, boolean, boolean, integer, timestamptz, integer, varchar, varchar)
returns integer as '
declare
   p_room_id        alias for $1;
   p_pretty_name    alias for $2;
   p_description    alias for $3;
   p_moderated_p    alias for $4;
   p_active_p       alias for $5;
   p_archive_p      alias for $6;
   p_auto_flush_p      alias for $7;
   p_auto_transcript_p      alias for $8;
   p_context_id     alias for $9;
   p_creation_date  alias for $10;
   p_creation_user  alias for $11;
   p_creation_ip    alias for $12;
   p_object_type    alias for $13;
   v_room_id        chat_rooms.room_id%TYPE;
begin
   v_room_id := acs_object__new (
     null,
     ''chat_room'',
     now(),
     p_creation_user,
     p_creation_ip,
     p_context_id
   );

   insert into chat_rooms
       (room_id, pretty_name, description, moderated_p, active_p, archive_p, auto_flush_p, auto_transcript_p)
   values
       (v_room_id, p_pretty_name, p_description, p_moderated_p, p_active_p, p_archive_p, p_auto_flush_p, p_auto_transcript_p);

return v_room_id;

end;' language 'plpgsql';

