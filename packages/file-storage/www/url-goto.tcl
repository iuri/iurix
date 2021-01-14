ad_page_contract {
    go to a URL

    @author Ben Adida (ben@openforce.net)
    @creation-date 01 April 2002
    @cvs-id $Id: url-goto.tcl,v 1.9 2018/01/19 14:18:32 gustafn Exp $
} {
    url_id:naturalnum,notnull
} 

# Check for read permission on this url
permission::require_permission -object_id $url_id -privilege read

# Check the URL
set url [db_string select_url {} -default {}]

if {$url ne ""} {
    ad_returnredirect $url
    ad_script_abort

} else {
    return -code error [_ file-storage.no_such_URL]
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
