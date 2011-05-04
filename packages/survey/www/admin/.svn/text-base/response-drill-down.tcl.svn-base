ad_page_contract {

  Display the list of users who gave a particular answer to a
  particular question.

  @param   question_id  question for which we're drilling down responses
  @param   choice_id    we're seeking respondents who selected this choice
                        as an answer to question

  @author  philg@mit.edu
  @author  jsc@arsdigita.com
  @author  nstrug@arsdigita.com
  @date    February 16, 2000
  @cvs-id  $Id: response-drill-down.tcl,v 1.3 2005/01/21 17:24:28 jeffd Exp $

} {

  question_id:integer,notnull
  choice_id:integer,notnull
  csv:optional 
}

ad_require_permission $question_id survey_admin_survey

# get the prompt text for the question and the ID for survey of 
# which it is part

set question_exists_p [db_0or1row get_question_text ""]
get_survey_info -section_id $section_id
set survey_name $survey_info(name)
set survey_id $survey_info(survey_id)

if { !$question_exists_p }  {
    db_release_unused_handles
    ad_return_error "[_ survey.lt_Survey_Question_Not_F]" "[_ survey.lt_Could_not_find_a_surv] #$question_id"
    return
}

set response_exists_p [db_0or1row get_response_text ""]

if { !$response_exists_p } {
    db_release_unused_handles
    ad_return_error "[_ survey.Response_Not_Found]" "[_ survey.lt_Could_not_find_the_re] #$choice_id"
    return
}

# Get information of users who responded in particular manner to
# choice question.

set action_url [export_vars -base [ad_conn url] {{csv yes} question_id choice_id}]
set actions [list "CSV" "$action_url" "[_ dotlrn.Comma_Separated_Values]"]

template::list::create \
	-name user_responses \
	-key user_id \
	-actions $actions \
	-elements {
		responder_name {
			label "[_ acs-subsite.Name]"
			link_url_eval $link
		}
		email {
			label "[_ acs-subsite.Email]"
			link_url_eval $link
		}
		creation_date {
			label "[_ survey.Date]"
		}
	} -selected_format csv -formats {
			    csv { output csv }
	}


set now [clock_to_ansi [clock seconds]]
db_multirow -extend {
	link		
} user_responses all_users_for_response {} {
	set link "one-respondent?user_id=$user_id&survey_id=$survey_id"
	set creation_date [util::age_pretty -timestamp_ansi $creation_date -sysdate_ansi $now]
}

set context [list \
     [list "one?[export_url_vars survey_id]" $survey_info(name)] \
     [list "responses?[export_url_vars survey_id]" "[_ survey.Responses]"] \
     "[_ survey.One_Response]"]

if { [exists_and_not_null csv] } {
    template::list::write_output -name user_responses
}
