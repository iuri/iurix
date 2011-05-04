ad_page_contract {

    Lists all the enabled surveys
    a user is eligable to complete.

    @author  philg@mit.edu
    @author  nstrug@arsdigita.com
    @date    28th September 2000
    @cvs-id  $Id: one-survey.tcl,v 1.3 2005/03/01 00:01:44 jeffd Exp $
} {
    survey_id:integer,notnull
} -properties {
    survey_details:multirow
}

set package_id [ad_conn package_id]

set user_id [auth::require_login]

set take_survey_p [ad_permission_p $survey_id survey_take_survey]

set admin_p [ad_permission_p $survey_id survey_admin_survey]

db_multirow survey_details get_survey_details {} 

ad_return_template

