#/packages/acs-lang/tcl/lang-message-procs.tcl
ad_library {

    Auditing of lang_messages

    @creation-date 3 December 2002
    @author Peter Marklund (peter@collaboraid.biz)
    @cvs-id $Id: lang-audit-procs.tcl,v 1.6 2017/08/07 23:47:56 gustafn Exp $
}

namespace eval lang::audit {

    ad_proc -public changed_message { 
        old_message
        package_key
        message_key
        locale
        comment
        deleted_p
        sync_time
        conflict_p
        upgrade_status
    } {
      Save a message that is overwritten.
      @author Peter Marklund
    } {
        # Save the old message in the audit table
        set overwrite_user [ad_conn user_id]

        db_dml lang_message_audit {} -clobs [list $old_message $comment]
    }    
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
