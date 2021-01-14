ad_page_contract {
    Lets the admin change a user's password.

    @cvs-id $Id: password-update.tcl,v 1.7 2018/06/29 17:27:18 hectorr Exp $
} {
    {user_id:naturalnum,notnull}
    {return_url:localurl ""}
    {password_old ""}
}

set email [party::get -party_id $user_id -element email]
set context [list [list "./" "Users"] [list "user.tcl?user_id=$user_id" $email] "Update Password"]

set site_link [ad_site_home_link]

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
