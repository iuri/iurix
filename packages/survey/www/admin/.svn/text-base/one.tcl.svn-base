ad_page_contract {

    This page allows the admin to administer a single survey.

    @param  section_id integer denoting survey we're administering

    @author jsc@arsdigita.com
    @author nstrug@arsdigita.com
    @author dave@thedesignexperience.org
    @date   February 9, 2000
    @cvs-id $Id: one.tcl,v 1.8 2005/01/26 21:05:13 jeffd Exp $
} {

    survey_id:integer
    {section_id:integer ""}
}

set package_id [ad_conn package_id]

ad_require_permission $package_id survey_admin_survey

# Get the survey information.
get_survey_info -survey_id $survey_id
if {![info exists survey_info(survey_id)]} {
    ad_return_complaint 1 "[_ survey.lt_Requested_survey_does]"
    ad_script_abort
}

if {$survey_info(description_html_p) == "f"} {   
    set survey_info(description) [ad_text_to_html $survey_info(description)]    
}

# get users and # who responded etc...
if {[apm_package_installed_p dotlrn]} {
    set community_id [dotlrn_community::get_community_id_from_url]
    set n_eligible [db_string n_eligible { 
	select count(*) from dotlrn_member_rels_full
	where rel_type='dotlrn_member_rel'
	and community_id=:community_id}]
}
set return_html ""

set creation_date [util_AnsiDatetoPrettyDate $survey_info(creation_date)]
set user_link [acs_community_member_url -user_id $survey_info(creation_user)]
if {$survey_info(single_response_p) == "t"} {
    set response_limit_toggle "[_ survey.allow_multiple]"
} else {
    set response_limit_toggle "[_ survey.limit_to_one]"
}


# allow site-wide admins to enable/disable surveys directly from here
set target "one?[export_url_vars survey_id]"
set enabled_p $survey_info(enabled_p)
set toggle_enabled_url "survey-toggle?[export_vars {survey_id enabled_p target}]"
if {$enabled_p == "t"} {
    append toggle_enabled_text "[_ survey.disable]"
} else {
    append toggle_enabled_text "[_ survey.enable]"
}


# Display Type (ben)
# provide list survey_display_types to adp process with <list>
set survey_display_types [survey_display_types]


# Questions summary.   
# We need to get the questions for ALL sections.

set context [list $survey_info(name)]

db_multirow -extend { question_display } questions survey_questions "" {set question_display [survey_question_display $question_id]}


set notification_chunk [notification::display::request_widget \
    -type survey_response_notif \
    -object_id $survey_id \
    -pretty_name $survey_info(name) \
    -url [ad_conn url]?survey_id=$survey_id \
]

ad_return_template
