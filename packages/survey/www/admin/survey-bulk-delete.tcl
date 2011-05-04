#/survey/www/survey-bulk-delete.tcl
ad_page_contract {
    Display delete confirmation.

    @author Iuri Sampaio (iuri.sampaio@gmail.com)
    @creation-date 2011-03-14
} {
    survey_id:integer,multiple,notnull
    {return_url ""}
} -properties {
    pretty_name:onevalue
    context_bar:onevalue
}

set context_bar [list "[_ survey.Delete_surveys]"]

ns_log Notice "RETURN $return_url"

#set delete_p [permission::permission_p -object_id [ad_conn package_id] -privilege "surveydelete"]
set delete_p 1 

if {$delete_p eq 0} {
    ad_returnredirect unauthorized-delete
    ad_script_abort
}

set survey_ids $survey_id
foreach element $survey_ids {
    lappend survey_ids "'[DoubleApos $element]'"
}

set survey_ids [join $survey_ids ","]

db_multirow surveys surveys "
    select survey_id, name from surveys where survey_id in ($survey_ids)
"

set hidden_vars [export_form_vars survey_id return_url]
