
#    Display a questionnaire for one survey.

#    @param  section_id   id of displayed survey

#    @author philg@mit.edu
#    @author nstrug@arsdigita.com
#    @date   28th September 2000
#    @cvs-id $Id: respond.tcl,v 1.8 2005/03/01 00:01:44 jeffd Exp $

    
#    survey_id:integer,notnull
#    {section_id:integer 0}
#    {response_id:integer 0}
#    return_url:optional


if {![exists_and_not_null section_id]} {
	set section_id 0
}

if {![exists_and_not_null response_id]} {
	set response_id 0
}

get_survey_info -survey_id $survey_id
set single_section_p $survey_info(single_section_p)
if {$section_id==0 && $single_section_p=="t"} {
    set section_id $survey_info(section_id)
}
set name [list $survey_info(name)]
set description $survey_info(description)
set description_html_p $survey_info(description_html_p)
set single_response_p $survey_info(single_response_p)
set editable_p $survey_info(editable_p)
set display_type $survey_info(display_type)

if {$description_html_p != "t"} {
    set description [ad_text_to_html $description]
} 


ad_require_permission $survey_id survey_take_survey

set context $name
set button_label "[_ survey.Submit_response]"
if {$editable_p == "t"} {
    if {$response_id > 0} {
	set button_label "[_ survey.lt_Modify_previous_respo]"
	db_1row get_initial_response ""
    }
}

# Set the max number of answers for the javascript code
set javascript_load ""
db_foreach select_max_answers {} {
	append javascript_load "disableHandler('responses', $num_answers, $question_id); "
}

# Body onload handler
template::add_body_handler -event onload -script $javascript_load


# build a list containing the HTML (generated with survey_question_display) for each question
set rownum 0
# for double-click protection
set new_response_id [db_nextval acs_object_id_seq]    
set questions [list]

db_foreach survey_sections {} {

    db_foreach question_ids_select {} {
		lappend questions [survey_question_display $question_id $response_id]
    }

    # return_url is used for infoshare - if it is set
    # the survey will return to it rather than
    # executing the survey associated with the logic
    # after the survey is completed
    #
    if ![info exists return_url] {
		set return_url {}
    }
}
set form_vars [export_form_vars section_id survey_id new_response_id]
ad_return_template

