ad_page_contract {

    Set the display type

    @param section_id survey whose properties we're changing
    @cvs-id response-limit-toggle.tcl,v 1.2.2.6 2000/07/21 04:04:21 ron Exp

} {
    survey_id:integer
    display_type:notnull
}

ad_require_permission $survey_id survey_admin_survey

if {[lsearch [survey_display_types] $display_type] > -1} {
    db_dml survey_display_type_edit ""
}

db_release_unused_handles
ad_returnredirect "one?[export_url_vars survey_id]"
