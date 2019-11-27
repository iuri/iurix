ad_page_contract -properties {
    context_bar
} {
    @author bdolicki@branimir.com
    @cvs-id $Id: migrate-categories.tcl,v 1.5 2013/09/11 07:23:43 gustafn Exp $
} {}

set package_id [ad_conn package_id]

set admin_p [permission::require_permission -object_id $package_id -privilege admin]

set context {{Categories Migration}}

set title "[_ lars-blogger.Categories_Migration]"

set fp [open $::acs::pageroot/../packages/lars-blogger/www/admin/migrate-categories-1.tcl]
set meat [read $fp]
close $fp
