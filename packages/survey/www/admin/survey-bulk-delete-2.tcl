#/survey/www/admin/survey-bulk-delete-2.tcl
ad_page_contract {
    Delete surveys

    @author Iuri Sampaio (iuri.sampaio@gmail.com)
    @creation-date 2011-03-14
} {
    survey_id:notnull
    {return_url ""}
    {cancel.x:optional}
}

if {![info exists cancel.x]} {

    foreach id $survey_id {    
	db_exec_plsql delete_survey {}

    }
}
ad_returnredirect $return_url






