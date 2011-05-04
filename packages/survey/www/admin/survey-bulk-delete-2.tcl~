ad_page_contract {

    This page allows the admin to delete survey and all responses.

    @param survey_id

    @author dave@thedesignexperience.org
    @date   August 7, 2002
    @cvs-id $Id: survey-delete.tcl,v 1.4 2005/01/21 17:24:28 jeffd Exp $
} {

   survey_id:integer

}

set package_id [ad_conn package_id]
ad_require_permission $package_id survey_admin_survey

get_survey_info -survey_id $survey_id

set questions_count ""
set responses_count ""

ad_form -name confirm_delete -form {
    {survey_id:text(hidden) {value $survey_id}}
    {warning:text(inform) {label "[_ survey.Warning_1]"} {value "[_ survey.lt_Deleting_this_surve]"}}
    {confirmation:text(radio) {label " "}
	{options
	    {{"[_ survey.Continue_with_Delete]" t }
	     {"[_ survey.lt_Cancel_and_return_to__1]" f }}	}
	    {value f}
    }

} -on_submit {
    if {$confirmation} {
	db_exec_plsql delete_survey {}
	ad_returnredirect "."
        ad_script_abort
    } else {
	ad_returnredirect "one?[export_vars survey_id]"
        ad_script_abort
    }
}

set context [_ survey.Delete_Survey]
