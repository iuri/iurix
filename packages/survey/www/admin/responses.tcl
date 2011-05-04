ad_page_contract {

    View summary of all responses to one survey.

    @param   section_id       survey for which we're building list of responses
    @param   unique_users_p  whether we will display only latest response for each user

    @author  jsc@arsdigita.com
    @author  nstrug@arsdigita.com
    @date    February 11, 2000
    @cvs-id  $Id: responses.tcl,v 1.3 2005/01/21 17:24:28 jeffd Exp $
} {

    survey_id:integer

}

ad_require_permission $survey_id survey_admin_survey

set user_id [ad_get_user_id]

# nstrug - 12/9/2000
# Summarise scored responses for all users

get_survey_info -survey_id $survey_id
set survey_name $survey_info(name)
set type $survey_info(type)

set return_html ""

# mbryzek - 3/27/2000
# We need a way to limit the summary page to 1 response from 
# each user. We use views to select out only the latest response
# from any given user


set results ""

db_foreach survey_question_list {} {
    append results "<li>#$sort_order $question_text
<blockquote>
"
    switch -- $abstract_data_type {
	"date" -
	"text" -
	"shorttext" {
	    append results "<a href=\"view-text-responses?question_id=$question_id\">[_ survey.View_responses]</a>\n"
	}
	
	"boolean" {

	    db_foreach survey_boolean_summary "" { 
		append results "[survey_decode_boolean_answer -response $boolean_answer -question_id $question_id]: <a href=\"[export_vars -base response-drill-boolean {boolean_answer question_id}]\">$n_responses</a><br>\n"
	    }
	}
	"integer" -
	"number" {
	    db_foreach survey_number_summary "" {
               append results "$number_answer: $n_responses<br>\n"
            }
            db_1row survey_number_average "" 
         append results "<p>[_ survey.Mean] $mean<br>[_ survey.Standard_Dev]: $standard_deviation<br>\
\n"
	    
        }
	"choice" {
	    db_foreach survey_section_question_choices "" {
             append results "$label: <a href=\"response-drill-down?[export_url_vars question_id choice_id]\">$n_responses</a><br>\n"
             }
	 }
	"blob" {
	    db_foreach survey_attachment_summary {} {
	        append results "<a href=\"../view-attachment?response_id=$response_id&question_id=$question_id\">$title</a><br />"
	    }
	}
    }
    append results "</blockquote>\n"
}
 


set n_responses [db_string survey_number_responses {} ]

if { $n_responses == 1 } {
    set response_sentence "[_ survey.lt_There_has_been_1_resp]"
} else {
 	set response_sentence "[_ survey.lt_There_have_been_n]"
}

set context [list [list "one?[export_url_vars survey_id]" $survey_info(name)] "[_ survey.Responses]"]

ad_return_template
