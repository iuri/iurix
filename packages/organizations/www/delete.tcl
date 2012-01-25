ad_page_contract {
    Delete an organization
    
    @author Jade Rubick (jade@rubick.com)
    @creation-date 2003-05-29
    @cvs-id $Id: delete.tcl,v 1.2 2004/01/26 15:39:47 jeffd Exp $
} {
    organization_id:integer
}

permission::require_permission -object_id $organization_id -privilege delete

db_exec_plsql organization_delete { }

ad_returnredirect .
