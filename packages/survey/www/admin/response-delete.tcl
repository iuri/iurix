ad_page_contract {

    This page allows the admin to delete survey and all responses.

    @param survey_id

    @author dave@thedesignexperience.org
    @date   August 7, 2002
    @cvs-id $Id: response-delete.tcl,v 1.3 2005/01/21 17:24:28 jeffd Exp $
} {
   response_id:integer,optional
}

set package_id [ad_conn package_id]
ad_require_permission $package_id survey_admin_survey

db_1row get_response_info {}

ad_form -name confirm_delete -form {
    {response_id:text(hidden) {value $response_id}}
    {survey_id:text(hidden) {value $survey_id}}
    {user_id:text(hidden) {value $user_id}}
    {warning:text(inform) {value "[_ survey.lt_Completely_delete [list user_name_var user_name response_date_var response_date]]"}
    {label "[_ survey.Warning]"}}
    {confirmation:text(radio) {label " "}
	{options
	    {{"[_ survey.Continue_with_Delete]" t }
	     {"[_ survey.lt_Cancel_and_return_to_]" f }}	}
	    {value f}
    }

} -on_submit {
    if {$confirmation} {
	db_exec_plsql delete_response {}
    } 
    ad_returnredirect -message "[_ survey.Response_Deleted]" "one-respondent?[export_vars {survey_id user_id}]"
}

set context [_ survey.Delete_Response]
