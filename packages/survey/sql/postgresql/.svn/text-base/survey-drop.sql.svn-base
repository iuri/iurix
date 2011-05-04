--
-- drop SQL for survey package
--
-- by nstrug@arsdigita.com on 29th September 2000
--
-- $Id: survey-drop.sql,v 1.3 2002/11/30 17:49:43 jeffd Exp $

select drop_package('survey_response');
select drop_package('survey_question');
select drop_package('survey_section');
select drop_package('survey');

drop view survey_responses_latest;
drop view survey_ques_responses_latest;
drop table survey_question_responses;
drop table survey_responses;
drop table survey_question_choices;
drop view survey_choice_id_sequence;
drop sequence survey_choice_id_seq;
drop table survey_questions;
drop table survey_sections;
drop table surveys;

-- nuke all created objects
-- need to do this before nuking the types
delete from acs_objects where object_type = 'survey_response';
delete from acs_objects where object_type = 'survey_question';
delete from acs_objects where object_type = 'survey_section';
delete from acs_objects where object_type = 'survey';

create function inline_0 ()
returns integer as '
begin

  PERFORM acs_object_type__drop_type (''survey_response'',''f'');
  PERFORM acs_object_type__drop_type (''survey_question'',''f'');
  PERFORM acs_object_type__drop_type (''survey_section'',''f'');
  PERFORM acs_object_type__drop_type (''survey'',''f'');

  PERFORM acs_privilege__remove_child (''admin'',''survey_admin_survey'');
  PERFORM acs_privilege__remove_child (''read'',''survey_take_survey'');
  PERFORM acs_privilege__remove_child (''survey_admin_survey'',''survey_delete_question'');
  PERFORM acs_privilege__remove_child (''survey_admin_survey'',''survey_modify_question'');
  PERFORM acs_privilege__remove_child (''survey_admin_survey'',''survey_create_question'');
  PERFORM acs_privilege__remove_child (''survey_admin_survey'',''survey_delete_survey'');
  PERFORM acs_privilege__remove_child (''survey_admin_survey'',''survey_modify_survey'');
  PERFORM acs_privilege__remove_child (''survey_admin_survey'',''survey_create_survey'');
  
  PERFORM acs_privilege__drop_privilege(''survey_admin_survey''); 
  PERFORM acs_privilege__drop_privilege(''survey_take_survey''); 
  PERFORM acs_privilege__drop_privilege(''survey_delete_question''); 
  PERFORM acs_privilege__drop_privilege(''survey_modify_question''); 
  PERFORM acs_privilege__drop_privilege(''survey_create_question''); 
  PERFORM acs_privilege__drop_privilege(''survey_delete_survey''); 
  PERFORM acs_privilege__drop_privilege(''survey_modify_survey''); 
  PERFORM acs_privilege__drop_privilege(''survey_create_survey''); 

  return 0;
end;' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();

-- gilbertw - logical_negation is defined in utilities-create.sql in acs-kernel
-- drop function logical_negation(boolean);


