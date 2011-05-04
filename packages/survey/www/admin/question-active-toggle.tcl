# /www/survsimp/admin/question-active-toggle.tcl
ad_page_contract {

    Toggles if a response to required for a given question.

    @param  section_id    survey we're operating with
    @param  question_id  denotes which question in survey we're updating

    @cvs-id question-active-toggle.tcl,v 1.5.2.4 2000/07/21 04:04:11 ron Exp
} {

    section_id:integer
    question_id:integer

}

ad_require_permission $section_id survey_admin_survey

db_dml survey_question_required_toggle "update survey_questions set active_p = util.logical_negation(active_p)
where section_id = :section_id
and question_id = :question_id"

db_release_unused_handles
get_survey_info -section_id $section_id
set survey_id $survey_info(survey_id)
ad_returnredirect "one?[export_url_vars survey_id]"

