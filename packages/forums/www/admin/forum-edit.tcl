ad_page_contract {
    
    Edit a Forum

    @author Ben Adida (ben@openforce.net)
    @creation-date 2002-05-25
    @cvs-id $Id: forum-edit.tcl,v 1.15.2.2 2016/05/20 20:38:58 gustafn Exp $

} {
    forum_id:naturalnum,notnull
    {return_url:localurl "."}
}

# Select the info
set package_id [ad_conn package_id]
forum::get -forum_id $forum_id -array forum

# Proper scoping?
if {$package_id != $forum(package_id)} {
    ns_log Error "Forum Administration: Bad Scoping of Forum #$forum_id in Forum Editing"
    ad_returnredirect "./"
    ad_script_abort
}

set context [list [_ forums.Edit_forum]]

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
