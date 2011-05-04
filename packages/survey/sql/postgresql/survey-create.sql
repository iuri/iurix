 -- ported to OpenACS 4 by Gilbert Wong (gwong@orchardlabs.com) on 2001-05-20
--
-- based on student work from 6.916 in Fall 1999
-- which was in turn based on problem set 4
-- in http://photo.net/teaching/one-term-web.html
--
-- by philg@mit.edu and raj@alum.mit.edu on February 9, 2000
-- converted to ACS 4.0 by nstrug@arsdigita.com on 29th September 2000
-- modified for dotLRN/OpenACS4.5 and renamed from "simple-survey" to "survey" 
--    by dave@thedesignexperience.org on 13 July 2002
--
-- $Id: survey-create.sql,v 1.9 2003/06/12 03:54:46 daveb Exp $

create function inline_0 ()
returns integer as '
begin
        PERFORM acs_privilege__create_privilege(''survey_create_survey'', null, null);
        PERFORM acs_privilege__create_privilege(''survey_modify_survey'', null, null);
        PERFORM acs_privilege__create_privilege(''survey_delete_survey'', null, null);
        PERFORM acs_privilege__create_privilege(''survey_create_question'', null, null);
        PERFORM acs_privilege__create_privilege(''survey_modify_question'', null, null);
        PERFORM acs_privilege__create_privilege(''survey_delete_question'', null, null);
        PERFORM acs_privilege__create_privilege(''survey_take_survey'', null, null);
        PERFORM acs_privilege__create_privilege(''survey_admin_survey'', null, null);

        return 0;

end;' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();


begin;

        select acs_privilege__add_child('survey_admin_survey','survey_create_survey');
        select acs_privilege__add_child('survey_admin_survey','survey_modify_survey');
        select acs_privilege__add_child('survey_admin_survey','survey_delete_survey');
        select acs_privilege__add_child('survey_admin_survey','survey_create_question');
        select acs_privilege__add_child('survey_admin_survey','survey_modify_question');
        select acs_privilege__add_child('survey_admin_survey','survey_delete_question');

        select acs_privilege__add_child('read','survey_take_survey');
        select acs_privilege__add_child('admin','survey_admin_survey');

end;



create function inline_1 ()
returns integer as '
begin

  PERFORM acs_object_type__create_type (
    ''survey'',
    ''Survey'',
    ''Surveys'',
    ''acs_object'',
    ''surveys'',
    ''survey_id'',
    null,
    ''f'',
    null,
    null
   );

  PERFORM acs_object_type__create_type (
    ''survey_section'',
    ''Survey Section'',
    ''Survey Sections'',
    ''acs_object'',
    ''survey_sections'',
    ''section_id'',
    null,
    ''f'',
    null,
    null
   );

  PERFORM acs_object_type__create_type (
    ''survey_question'',
    ''Survey Question'',
    ''Survey Questions'',
    ''acs_object'',
    ''survey_questions'',
    ''question_id'',
    null,
    ''f'',
    null,
    null
  );

  PERFORM acs_object_type__create_type (
    ''survey_response'',
    ''Survey Response'',
    ''Survey Responses'',
    ''acs_object'',
    ''survey_responses'',
    ''response_id'',
    null,
    ''f'',
    null,
    null
  );

  return 0;

end;' language 'plpgsql';

select inline_1 ();
drop function inline_1 ();

create table surveys (
        survey_id               integer constraint surveys_survey_id_fk
                                references acs_objects (object_id)
                                on delete cascade
                                constraint surveys_pk
                                primary key,
        name                    varchar(4000)
                                constraint surveys_name_nn
                                not null,
        description             text
                                constraint surveys_desc_nn
                                not null,
        description_html_p      boolean not null,
        enabled_p               boolean not null,
        -- limit to one response per user
        single_response_p       boolean not null,
        editable_p              boolean not null,
	single_section_p	boolean not null,
        type                    varchar(20),               
        display_type            varchar(20),
        package_id              integer constraint surveys_package_id_nn 
                                not null
                                constraint surveys_package_id_fk 
                                references apm_packages (package_id) on delete cascade
);
         

create table survey_sections (
	section_id		integer constraint survey_sections_section_id_fk
				references acs_objects (object_id)
                                constraint survey_sections_pk
				primary key,
	survey_id		integer
				constraint survey_sections_survey_id_nn
				not null
				constraint survey_sections_survey_id_fk
				references surveys,
	name			varchar(4000)
				constraint survey_sections_name_nn
				not null,
	description		text 
				constraint survey_sections_desc_nn
				not null,
        description_html_p      boolean
);

create index survey_sections_survey_id_fk on survey_sections(survey_id);
-- each question can be 

create table survey_questions (
        question_id             integer constraint survey_q_question_id_fk
                                references acs_objects (object_id)
                                on delete cascade
                                constraint survey_q_question_id_pk
                                primary key,
        section_id               integer constraint survey_q_section_id_fk
                                references survey_sections
                                on delete cascade,
        sort_order                integer
                                constraint survey_q_sort_order_nn
                                not null,
        question_text           text
                                constraint survey_q_question_text_nn
                                not null,
        abstract_data_type      varchar(30)
                                constraint survey_q_abs_data_type_ck
                                check (abstract_data_type in ('text', 'shorttext', 'boolean', 'number', 'integer', 'choice','date','blob')),
        required_p              boolean,
        active_p                boolean,
        presentation_type       varchar(20)
                                constraint survey_q_pres_type_nn
                                not null
                                constraint survey_q_pres_type_ck
                                check(presentation_type in ('textbox','textarea','select','radio', 'checkbox', 'date', 'upload_file')),
        -- for text, "small", "medium", "large" sizes
        -- for textarea, "rows=X cols=X"
        presentation_options    varchar(50),
        presentation_alignment  varchar(15)
                                constraint survey_q_pres_alignment_ck
                                check(presentation_alignment in ('below','beside'))    
);


create index survey_q_sort_order on survey_questions(sort_order);
create index survey_q_active_p on survey_questions(active_p);

-- for when a question has a fixed set of responses

create sequence survey_choice_id_seq;
create view survey_choice_id_sequence as select nextval('survey_choice_id_seq') as nextval;

create table survey_question_choices (
        choice_id       integer constraint survey_qc_choice_id_nn 
                        not null 
                        constraint survey_qc_choice_id_pk
                        primary key,
        question_id     integer constraint survey_qc_question_id_nn
                        not null 
                        constraint survey_qc_question_id_fk
                        references survey_questions
                        on delete cascade,
        -- human readable 
        label           varchar(500) constraint survey_qc_label_nn
                        not null,
        -- might be useful for averaging or whatever, generally null
        numeric_value   numeric,
        -- lower is earlier 
        sort_order      integer
);


create index survey_q_c_question_id on survey_question_choices(question_id);
create index survey_q_c_sort_order on survey_question_choices(sort_order);

-- this records a response by one user to one survey
-- (could also be a proposal in which case we'll do funny 
--  things like let the user give it a title, send him or her
--  email if someone comments on it, etc.)
create table survey_responses (
        response_id             integer constraint survey_resp_response_id_fk
                                references acs_objects (object_id)
                                on delete cascade
                                constraint survey_resp_response_id_pk
                                primary key,
	initial_response_id     integer constraint survey_resp_initial_fk
                                references survey_responses(response_id),
        survey_id              integer constraint survey_resp_survey_id_fk
                                references surveys
                                on delete cascade,
        title                   varchar(100),
        notify_on_comment_p     boolean
);


-- this view contains only the most recently edited version
-- of each survey response.



-- this table stores the answers to each question for a survey
-- we want to be able to hold different data types in one long skinny table 
-- but we also may want to do averages, etc., so we can't just use CLOBs

create table survey_question_responses (
        response_id             integer constraint survey_qr_response_id_nn
                                not null 
                                constraint survey_qr_response_id_fk
                                references survey_responses
                                on delete cascade,
        question_id             integer constraint survey_qr_question_id_nn
                                not null 
                                constraint survey_qr_question_id_fk
                                references survey_questions
                                on delete cascade,
        -- if the user picked a canned response
        choice_id               integer constraint survey_qr_choice_id_fk
                                references survey_question_choices
                                on delete cascade,
        boolean_answer          boolean,
        clob_answer             text,
        number_answer           numeric,
        varchar_answer          text,
        date_answer             timestamptz,
	attachment_answer       integer
				constraint survey_q_response_item_id_fk
                                references cr_revisions(revision_id)
                                on delete cascade
);

create index survey_q_r_choice_id on survey_question_responses(choice_id);
create index survey_q_r_attachment_answer on survey_question_responses(attachment_answer);
create index survey_response_index on survey_question_responses (response_id, question_id);

-- We create a view that selects out only the last response from each
-- user to give us at most 1 response from all users.
-- create or replace view survey_question_responses_un as 
-- select qr.* 
--  from survey_question_responses qr, survey_responses_unique r
--  where qr.response_id=r.response_id;


-- API for survey objects

create or replace function survey__new (integer,varchar,text,boolean,boolean,boolean,boolean,boolean,varchar,varchar,integer,integer,integer)
returns integer as '
declare
  new__survey_id                alias for $1;  -- default null
  new__name                     alias for $2;
  new__description              alias for $3;
  new__description_html_p       alias for $4;  -- default f
  new__single_response_p        alias for $5;  -- default f
  new__editable_p               alias for $6;  -- default t
  new__enabled_p                alias for $7;  -- default f
  new__single_section_p         alias for $8;  -- default t
  new__type                     alias for $9;  -- default general
  new__display_type             alias for $10;
  new__package_id               alias for $11;
  new__creation_user            alias for $12; -- default null
  new__context_id               alias for $13; -- default null
  v_survey_id                   integer;
begin
    v_survey_id := acs_object__new (
        new__survey_id,
        ''survey'',
        now(),
        new__creation_user,
        null,
        new__context_id
    );

    insert into surveys
    (survey_id, name, description, 
    description_html_p, single_response_p, editable_p, 
    enabled_p, single_section_p, type, display_type, package_id)
    values
    (v_survey_id, new__name, new__description, 
    new__description_html_p, new__single_response_p, new__editable_p, 
    new__enabled_p, new__single_section_p, new__type, new__display_type, new__package_id);

    return v_survey_id;

end;' language 'plpgsql';
 

create or replace function survey__remove (integer)
returns integer as '
declare
  remove__survey_id             alias for $1;
  v_response_row                survey_responses%ROWTYPE;
  v_section_row                 survey_sections%ROWTYPE;
begin

    for v_response_row in SELECT
		response_id	
               from survey_responses
               where survey_id=remove__survey_id
               and initial_response_id is NULL
    loop
	PERFORM survey_response__remove(v_response_row.response_id);
    end loop;

    for v_section_row in select section_id
		from survey_sections
		where survey_id=remove__survey_id
    loop
	PERFORM survey_section__remove(v_section_row.section_id);
    end loop;

    delete from surveys
    where survey_id = remove__survey_id;

    PERFORM acs_object__delete(remove__survey_id);

    return 0;

end;' language 'plpgsql';


-- API for survey_section objects

create or replace function survey_section__new (integer,integer,varchar,text,boolean,integer,integer)
returns integer as '
declare
  new__section_id               alias for $1;  -- default null
  new__survey_id                alias for $2;  -- default null
  new__name                    alias for $3;  -- default null
  new__description              alias for $4;  -- default null
  new__description_html_p       alias for $5;  -- default f
  new__creation_user            alias for $6;  -- default null
  new__context_id               alias for $7;  -- default null
  v_section_id                  integer;
begin
    v_section_id := acs_object__new (
        new__section_id,
        ''survey_section'',
        now(),
        new__creation_user,
        null,
        new__context_id
    );

    insert into survey_sections
    (section_id, survey_id, name, description, description_html_p)
    values
    (v_section_id, new__survey_id, new__name, new__description, new__description_html_p);

    return v_section_id;

end;' language 'plpgsql';

create or replace function survey_section__remove (integer)
returns integer as '
declare
  remove__section_id             alias for $1;
  v_question_row         	 survey_questions%ROWTYPE;
begin
    for v_question_row in select question_id
		from survey_questions
		where section_id=remove__section_id
    loop
	PERFORM survey_question__remove(v_question_row.question_id);
    end loop;

    delete from survey_sections
    where section_id = remove__section_id;

    PERFORM acs_object__delete(remove__section_id);

    return 0;

end;' language 'plpgsql';

create or replace function survey_question__new (integer,integer,integer,text,varchar,boolean,boolean,varchar,varchar,varchar,integer,integer)
returns integer as '
declare
  new__question_id              alias for $1; -- default null
  new__section_id                alias for $2; -- default null
  new__sort_order                 alias for $3; -- default null
  new__question_text            alias for $4; -- default null
  new__abstract_data_type       alias for $5; -- default null
  new__required_p               alias for $6; -- default t
  new__active_p                 alias for $7; -- default 
  new__presentation_type        alias for $8; -- default null
  new__presentation_options     alias for $9; -- default null
  new__presentation_alignment   alias for $10; -- default below
  new__creation_user            alias for $11; -- default null
  new__context_id               alias for $12; -- default null
  v_question_id                 integer;
begin
    v_question_id := acs_object__new (
        new__question_id,
        ''survey_question'',
        now(),
        new__creation_user,
        null,
        new__context_id
    );

    insert into survey_questions
    (question_id, section_id, sort_order, question_text, 
    abstract_data_type, required_p, active_p, 
    presentation_type, presentation_options,
    presentation_alignment)
    values
    (v_question_id, new__section_id, new__sort_order, new__question_text, 
    new__abstract_data_type, new__required_p, new__active_p, 
    new__presentation_type, new__presentation_options,
    new__presentation_alignment);

    return v_question_id;

end;' language 'plpgsql';

create or replace function survey_question__remove (integer)
returns integer as '
declare
  remove__question_id           alias for $1;
begin

	delete from survey_question_responses
	    where question_id=remove__question_id;

	delete from survey_question_choices
	    where question_id=remove__question_id;

	delete from survey_questions
            where question_id = remove__question_id;

    PERFORM acs_object__delete(remove__question_id);

    return 0;

end;' language 'plpgsql';


-- create or replace package body survey_response
-- procedure new
create or replace function survey_response__new(integer,integer,varchar,boolean,integer,varchar,integer,integer)
returns integer as '
declare
  new__response_id              alias for $1; -- default null
  new__survey_id                alias for $2; -- default null
  new__title                    alias for $3; -- default null
  new__notify_on_comment_p      alias for $4; -- default f
  new__creation_user            alias for $5; -- default null
  new__creation_ip              alias for $6; -- default null
  new__context_id               alias for $7; -- default null
  new__initial_response_id      alias for $8; -- default null
  v_response_id                 integer;
begin
    v_response_id := acs_object__new (
        new__response_id,
        ''survey_response'',
        now(),
        new__creation_user,
        new__creation_ip,
        new__context_id
    );

    insert into survey_responses 
    (response_id, survey_id, title, notify_on_comment_p, initial_response_id)
    values
    (v_response_id, new__survey_id, new__title, new__notify_on_comment_p, new__initial_response_id);

    return v_response_id;

end;' language 'plpgsql';

--function initial_response_id
create or replace function survey_response__initial_response_id(integer)
returns integer as '
declare
  p_response_id		alias for $1;
  v_initial_response_id		integer;
begin
  select into v_initial_response_id initial_response_id from
	survey_responses where response_id = p_response_id;
  if v_initial_response_id is NULL then
	v_initial_response_id := p_response_id;
  end if;
  return v_initial_response_id;
end;' language 'plpgsql';

create or replace function survey_response__initial_user_id (integer)
returns integer as '
declare
p_response_id 	alias for $1;
v_user_id	integer;
begin
	select into v_user_id o.creation_user
	from acs_objects o,
	     survey_responses s
        where
	object_id = coalesce(s.initial_response_id, s.response_id)
	and s.response_id = p_response_id;
return v_user_id;
end;' language 'plpgsql';

-- procedure delete 
create or replace function survey_response__remove(integer)
returns integer as '
declare
  remove__response_id           alias for $1;
  v_response_row                survey_responses%ROWTYPE;
begin
    for v_response_row in select response_id from survey_responses
	where initial_response_id=remove__response_id
    loop
	PERFORM survey_response__del(v_response_row.response_id);
    end loop;

    return 0;

end;' language 'plpgsql';

create or replace function survey_response__del (integer)
returns integer as '
declare
	del__response_id        alias for $1;
	v_question_response_row record;
begin

	for v_question_response_row in select item_id
		from survey_question_responses, cr_revisions
		where response_id=del__response_id
		and attachment_answer=revision_id
	loop
		PERFORM content_item__delete(v_question_response_row.item_id);
	end loop;
	
	delete from survey_question_responses
		where response_id=del__response_id;
	delete from survey_responses
		where response_id=del__response_id;
	PERFORM acs_object__delete(del__response_id);
    return 0;

end;' language 'plpgsql';

create view survey_responses_latest as
select sr.*, o.creation_date, 
       o.creation_user,
       survey_response__initial_user_id(sr.response_id) as initial_user_id
  from survey_responses sr 
  join acs_objects o
    on (sr.response_id = o.object_id)
  join (select max(response_id) as response_id
          from survey_responses
         group by survey_response__initial_response_id(response_id)) latest
    on (sr.response_id = latest.response_id);

create view survey_ques_responses_latest as
select qr.*
  from survey_question_responses qr, survey_responses_latest r
 where qr.response_id=r.response_id;  

\i survey-notifications-init.sql
