
ad_page_contract {

    Remove a notification request

    @author Ben Adida (ben@openforce.net)
    @creation-date 2002-05-24
    @cvs-id $Id: request-delete.tcl,v 1.7 2018/08/17 13:02:43 hectorr Exp $
} {
    request_id:naturalnum,notnull
    return_url:localurl
}

# Security Check
notification::security::require_admin_request -request_id $request_id

# Actually Delete
notification::request::delete -request_id $request_id

# Redirect
ad_returnredirect $return_url

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
