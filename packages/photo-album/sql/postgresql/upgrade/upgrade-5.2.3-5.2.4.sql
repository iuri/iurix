-- add more columns on table pa_photos
-- @author iuri sampaio
-- @cvs-id $id$

ALTER TABLE pa_photos ADD COLUMN group_id integer default null;

--drop function pa_photo__new (varchar,integer,integer,integer,timestamptz, integer, varchar, varchar, integer, varchar, varchar, boolean, timestamptz, varchar, varchar, text);

create or replace function pa_photo__new (varchar,integer,integer,integer,timestamptz, integer, varchar, varchar, integer, varchar, varchar, boolean, timestamptz, varchar, varchar, text, varchar, integer) returns integer as '
  declare 
    new__name		alias for $1;
    new__parent_id	alias for $2; -- default null
    new__item_id	alias for $3; -- default null
    new__revision_id	alias for $4; -- default null
    new__creation_date  alias for $5; -- default now()
    new__creation_user  alias for $6; -- default null
    new__creation_ip    alias for $7; -- default null
    new__locale         alias for $8; -- default null
    new__context_id     alias for $9; -- default null
    new__title          alias for $10; -- default null
    new__description    alias for $11; -- default null
    new__is_live        alias for $12; -- default f
    new__publish_date	alias for $13; -- default now()
    new__nls_language	alias for $14; -- default null
    new__caption	alias for $15; -- default null
    new__story		alias for $16; -- default null
    new__photographer   alias for $17; -- default null
    new__group_id	alias for $18; -- default null

    -- mime_type determined by image content_type
    new__mime_type	varchar default null;
    -- the same as title
    -- user_filename	in pa_photos.user_filename%TYPE default null
    new__content_type  varchar default ''pa_photo'';	
    new__relation_tag  varchar default null;	
    
    v_item_id		cr_items.item_id%TYPE;
    v_revision_id	cr_revisions.revision_id%TYPE;
  begin
    
    v_item_id := content_item__new (
      new__name,
      new__parent_id,
      new__item_id,
      new__locale,
      new__creation_date,
      new__creation_user,	
      new__context_id,
      new__creation_ip,
      ''content_item'',
      new__content_type,
      null,
      null,
      null,
      null,
      null
    );

      -- not needed in the new call to content_item__new
      -- new__relation_tag,

    v_revision_id := content_revision__new (
      new__title,
      new__description,
      new__creation_date,
      new__mime_type,
      new__nls_language,
      null,
      v_item_id,
      new__revision_id,
      new__creation_date,
      new__creation_user,
      new__creation_ip

    );

    insert into pa_photos
    (pa_photo_id, caption, story, user_filename, date_taken, photographer, group_id)
    values
    (v_revision_id, new__caption, new__story, new__title, new__publish_date, new__photographer, new__group_id);

    if new__is_live = ''t'' then
       PERFORM content_item__set_live_revision (v_revision_id);
    end if;

    return v_item_id;
end; ' language 'plpgsql';



-- Create relation between photo and subsite in the acs_rel_types datamodel
-- select acs_rel_type__create_type('photo_subsite','Photo Subsite', 'Photo Subsite', null, null, null,'photo-album', 'pa_photo',null, 0, 1, 'apm_package', null, '0', '1');