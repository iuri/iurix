-- /packages/qt-luna-api/sql/postgresql/qt-luna-api-create.sql
--
-- @author Iuri de Araujo (iuri@iurix.com)
-- @creation-date 23 January 2021
--

--
-- Matching 
--
select content_type__create_type (
       'qt_matching',    -- content_type
       'content_revision',       -- supertype. We search revision content 
                                 -- first, before item metadata
       'Qonteo Matching',    -- pretty_name
       'Qonteo Matchings',   -- pretty_plural
       NULL,        -- table_name
       -- IURI: acs_object_types supports a null table name so we do that
       -- instead of passing a false value so we can actually use the
       -- content repository instead of duplicating all the code in file-storage
       NULL,	         -- id_column
       'qt_matching__get_title' -- name_method
);

-- necessary to work around limitation of content repository:
select content_folder__register_content_type(-100,'qt_matching','t');



CREATE TABLE user_ext_info(
    userinfo_id integer
    CONSTRAINT uei_userinfo_id_pk PRIMARY KEY,
    luna_person_id varchar(255),
    luna_descriptor_id varchar(255),
    phonenumber varchar(255),
    location varchar(255),
    user_id integer
    CONSTRAINT uei_user_id_fk REFERENCES users ON DELETE CASCADE
    CONSTRAINT uei_user_id_un UNIQUE

);

CREATE SEQUENCE user_info_id_seq cache 1000;


SELECT define_function_args('userinfo__new','userinfo_id integer, person_id varchar, descriptor_id varchar, phonenumber varchar, location varchar, user_id integer');

CREATE OR REPLACE FUNCTION userinfo__new (
    p_userinfo_id  	integer,
    p_person_id		varchar,
    p_descriptor_id	varchar,
    p_phonenumber  	varchar,
    p_location	   	varchar,
    p_user_id 	   	integer
) RETURNS integer AS $$
  DECLARE

  BEGIN

  INSERT INTO user_ext_info (
    userinfo_id,
    luna_person_id,
    luna_descriptor_id,
    user_id,
    phonenumber,
    location
  ) VALUES (
    p_userinfo_id,
    p_person_id,
    p_descriptor_id,
    p_user_id,
    p_phonenumber,
    p_location
  );

  RETURN 0;
END; $$ language plpgsql;
