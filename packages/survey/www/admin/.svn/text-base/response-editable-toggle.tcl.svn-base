ad_page_contract {

    Toggles a survey between allowing a user to
    edit to or not.

    @param  section_id survey we're dealing with

    @author Jin Choi (jsc@arsdigita.com)
    @author nstrug@arsdigita.com
    @cvs-id $Id: response-editable-toggle.tcl,v 1.1 2002/09/16 00:00:24 daveb Exp $
} {

    survey_id:integer

}

ad_require_permission $survey_id survey_admin_survey

db_dml survey_response_editable_toggle ""

db_release_unused_handles
ad_returnredirect "one?[export_url_vars survey_id]"
