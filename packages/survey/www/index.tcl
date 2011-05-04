ad_page_contract {

    Lists all the enabled surveys
    a user is eligable to complete.

    @author  philg@mit.edu
    @author  nstrug@arsdigita.com
    @date    28th September 2000
    @cvs-id  $Id: index.tcl,v 1.3 2005/03/01 00:01:44 jeffd Exp $
} {

} -properties {
    surveys:multirow
}

set package_id [ad_conn package_id]

set user_id [auth::require_login]

set admin_p [ad_permission_p $package_id admin]

db_multirow surveys survey_select {} 


ad_return_template

