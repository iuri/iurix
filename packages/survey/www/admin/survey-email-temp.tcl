ad_page_contract {

    this page offers options for sending a survey by email 
    to various groups

    @param survey_id
    
    @author iuri.sampaio@gmail.com
    @creation-date   2011-04-14
} {
    { survey_id ""}
    { package_id:integer 0}
    { to "responded"}  
    { user_id:multiple "" } 
    { groups:multiple "" }
    { spam_all 0 }
    
}


# Debug form! This chunk must be erased later                                                                                                                
set myform [ns_getform]
if {[string equal "" $myform]} {
    ns_log Notice "No Form was submited"
} else {
    ns_log Notice "FORM"
    ns_set print $myform
    for {set i 0} {$i < [ns_set size $myform]} {incr i} {
	set varname [ns_set key $myform $i]
	set $varname [ns_set value $myform $i]
    }
}

set package_id [ad_conn package_id]
set user_id [ad_conn user_id]
set sender_id [ad_conn user_id]

ad_require_permission $survey_id survey_admin_survey

get_survey_info -survey_id $survey_id

set survey_name $survey_info(name)
db_1row select_sender_info {}


ad_form -name send-mail -form {
    {to:text(radio) {options {
	{"[_ survey.lt_Everyone_eligible_to_]" "all"}
	{"[_ survey.lt_Everyone_who_has_alre]" "responded"}
	{"[_ survey.lt_Everyone_who_has_not_]" "not_responded"}}}
	{label "[_ survey.Send_mail_to]"}
	{value $to}
    }
    {subject:text(text) {value $survey_name} {label "[_ survey.Message_Subject]"} {html {size 50}}}
    {message:text(textarea) {label "[_ survey.Enter_Message]"} {html {rows 15 cols 60}}}
    {survey_id:text(hidden) {value $survey_id}}
    {package_id:text(hidden) {value $package_id}}
} -on_submit {
    
    bulk_mail::new \
	-package_id $package_id \
	-from_addr $sender_email \
	-subject $subject \
	-message $message \
	-query $query

    ad_returnredirect "one?survey_id=$survey_id"
    ad_script_abort
}

set context [_ survey.Send_Mail]
ad_return_template


