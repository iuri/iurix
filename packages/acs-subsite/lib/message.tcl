ad_page_contract {
    This include expects "message" to be set as html
    and if no title is present uses "Message".  Used to inform of actions
    in registration etc.

    @cvs-id $Id: message.tcl,v 1.3 2017/08/07 23:47:57 gustafn Exp $
}
if {(![info exists title] || $title eq "")} {
    set page_title Message
}
set context [list $title]

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
