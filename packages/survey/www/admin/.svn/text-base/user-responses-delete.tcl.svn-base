ad_page_contract {

    This page allows the admin to delete survey and all responses.

    @param survey_id

    @author dave@thedesignexperience.org
    @date   August 7, 2002
    @cvs-id $Id: user-responses-delete.tcl,v 1.4 2005/01/21 17:24:28 jeffd Exp $
} {
    survey_id:integer
    user_id:integer
}

set package_id [ad_conn package_id]
ad_require_permission $package_id survey_admin_survey

db_multirow responses get_response_info {}

set response_count [template::multirow size responses]
ad_form -name confirm_delete -form {
    {survey_id:text(hidden) {value $survey_id}}
    {user_id:text(hidden) {value $user_id}}
    {warning:text(inform) {label "[_ survey.Warning_1]"} {value "[_ survey.lt_This_will_remove_respo]"}}
    {confirmation:text(radio) {label " "}
	{options
	    {{"[_ survey.Continue_with_Delete]" t }
	     {"[_ survey.lt_Cancel_and_return_to_]" f }}	}
	    {value f}
    }

} -on_submit {
    if {$confirmation} {
	template::multirow foreach responses {
	    if {[empty_string_p $initial_response_id]} {
		db_exec_plsql delete_response {}
	    }
	}
    } 
    ad_returnredirect "one-respondent?[export_vars {survey_id user_id}]"
    ad_script_abort
}

set context [_ survey.Delete_Response]
