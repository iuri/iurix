<?xml version="1.0"?>
<queryset>

<fullquery name="get_question_text">      
      <querytext>
      
select section_id, question_text, section_id
from survey_questions
where question_id = :question_id

      </querytext>
</fullquery>

 
<fullquery name="get_response_text">      
      <querytext>
    
select label as response_text
from survey_question_choices
where choice_id = :choice_id
      </querytext>
</fullquery>

<fullquery name="all_users_for_response">      
      <querytext>
      
select
  first_names || ' ' || last_name as responder_name,
  p.email,
  person_id as user_id,
  to_char(creation_date,'YYYY-MM-DD HH24:MI:SS') as creation_date
from
  acs_objects,
  survey_responses sr,
  persons u,
  parties p,
  survey_ques_responses_latest qr
where
  qr.response_id = sr.response_id
  and qr.response_id = object_id
  and creation_user = person_id
  and person_id = p.party_id
  and qr.question_id = :question_id
  and qr.choice_id = :choice_id
order by responder_name
      </querytext>
</fullquery>

 
</queryset>
