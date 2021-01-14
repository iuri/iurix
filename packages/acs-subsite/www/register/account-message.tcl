ad_page_contract {
    Inform the user of an account status message.
    
    @cvs-id $Id: account-message.tcl,v 1.3 2017/08/07 23:47:59 gustafn Exp $
} {
    {message:html ""}
    {return_url:localurl ""}
}

set page_title "Logged in"
set context [list $page_title]

set system_name [ad_system_name]


# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
