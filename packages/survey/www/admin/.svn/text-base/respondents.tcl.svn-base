ad_page_contract {
    List respondents to this survey.

    @param section_id which survey we're displaying respondents to

    @author jsc@arsdigita.com
    @author nstrug@arsdigita.com
    @creation-date February 11, 2000
    @version $Id: respondents.tcl,v 1.8 2006/08/08 21:27:13 donb Exp $
} -query {
    survey_id:integer
    {orderby "email"}
    {response_type "responded"}
} -properties {
    survey_name:onevalue
    respondents:multirow
}

ad_require_permission $survey_id survey_admin_survey

# for sloanspace, we can also list users who have NOT responded or
# the entire group.


get_survey_info -survey_id $survey_id
set survey_name $survey_info(name)

set context [list [list "one?[export_url_vars survey_id]" $survey_info(name)] [_ survey.Respondents]]

set table_def [list \
		   [list first_names "[_ survey.First_Name]" {upper(first_names) $order} {<td><a href="one-respondent?[export_vars {user_id survey_id}]">$first_names</a></td>}] \
		   [list last_name "[_ survey.Last_Name]" "" {<td><a href="one-respondent?[export_vars {user_id survey_id}]">$last_name</a></td>}] \
		   [list email "[_ survey.Email_Address]" "" {<td><a href="one-respondent?[export_vars {user_id survey_id}]">$email</a></td>}] \
		   [list actions "[_ survey.Actions]" no_sort {<td><a href="one-respondent?[export_vars {user_id survey_id}]"><img src="../graphics/view.gif" border="0" alt="[_ survey.View]"></a></td>}] \
		   ]

set respondents_table [ad_table -Torderby $orderby -Textra_vars {survey_id} -Tmissing_text "[_ survey.No_data_found]" select_respondents {}  $table_def]

ad_return_template

