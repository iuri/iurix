# /packages/acs-subsite/www/admin/groups/one.tcl

ad_page_contract {
    Change join policy of a group.

    @author Oumi Mehrotra (oumi@arsdigita.com)

    @creation-date 2001-02-23
    @cvs-id $Id: change-join-policy-2.tcl,v 1.7 2018/06/07 17:30:17 hectorr Exp $
} {
    group_id:naturalnum,notnull
    join_policy:notnull
    {return_url:localurl ""}
} -validate {
    groups_exists_p -requires {group_id:notnull} {
        if { ![permission::permission_p -object_id $group_id -privilege "admin"] } {
            ad_complain "The group either does not exist or you do not have permission to administer it"
        }
    }
    group_in_scope_p -requires {group_id:notnull} {
        if { ![application_group::contains_party_p -party_id $group_id]} {
            ad_complain "The group either does not exist or does not belong to this subsite."
        }
    }
}



db_dml update_join_policy {
    update groups
    set join_policy = :join_policy
    where group_id = :group_id
}

if {$return_url eq ""} {
    set return_url one?group_id=@group_id@
}

ad_returnredirect $return_url
ad_script_abort

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
