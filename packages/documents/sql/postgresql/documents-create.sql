CREATE TABLE document_items (
    document_id	      integer 
		      references cr_revisions on delete cascade,
    name	      varchar(200),
    description	      text,
    user_id	      integer,
    group_id	      integer,
    author	      varchar(200),
    coauthor	      varchar(200),
    language	      varchar(200),
    source	      varchar(200),      
    publish_date      timestamp default now(),
    constraint 	      document_items_pk primary key (document_id),
    constraint	      document_items_fk foreign key (document_id) references acs_objects(object_id)
);

comment on table document_items is 'Table for storing custom fields of documents within content repository.';



CREATE or REPLACE FUNCTION inline_0 () 
returns integer as '
declare 
	v_object_type integer;
begin

	PERFORM acs_object_type__create_type (
	       ''document_item'',	--object_type
	       ''Document Item'',	--pretty_name
	       ''Document Items'',	--pretty_plural
	       ''acs_object'',		--supertype
	       ''document_items'',	--tablename
	       ''document_id'',		--id_column
	       ''documents'',		--package_name
	       ''f'',			--abstract_p
	       null,
	       null
	);

	return 0;

end;' language 'plpgsql';

SELECT inline_0 ();
DROP FUNCTION inline_0 ();
	



CREATE or REPLACE FUNCTION document_item__new (integer, varchar, varchar, integer, varchar, varchar, varchar, varchar, timestamptz, integer, varchar, integer) returns integer as '
declare
	p_document_id    alias for $1;
	p_name           alias for $2; 
	p_description    alias for $3; -- default null
	p_group_id       alias for $4; -- default null
	p_author         alias for $5; -- default null
	p_coauthor       alias for $6; -- default null
	p_language       alias for $7; -- default null
	p_source         alias for $8; -- default null
	p_publish_date   alias for $9; -- default now()
	p_creation_user  alias for $10;
	p_creation_ip	 alias for $11; 
	p_context_id	 alias for $12;
	
	v_document_id integer;
	v_document_type varchar;
    
begin
	v_document_type := ''document_item'';

	v_document_id := acs_object__new(
		      null,
		      v_document_type,
		      now(),
		      p_creation_user,
		      p_creation_ip,
		      p_context_id
	);

	INSERT INTO document_items 
    	   (document_id, name, description, user_id, group_id, author, coauthor, language, source, publish_date) 
	VALUES 
    	   (p_document_id, p_name, p_description, p_creation_user, p_group_id, p_author, p_coauthor, p_language, p_source, p_publish_date);

        RETURN v_document_id;

end;' language 'plpgsql';



CREATE or REPLACE FUNCTION document_item__delete (integer) 
returns integer as '
DECLARE
    p_document_id	alias for $1;

BEGIN
	
    DELETE FROM document_items WHERE document_id = p_document_id;

    PERFORM acs_object__delete(p_document_id);
    
    RETURN 0;
END;' language 'plpgsql';


