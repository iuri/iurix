# packages/project-manager-portlet/www/project-manager-admin.tcl

ad_page_contract {
    
    Display Admin Portlet
    
    @author Bjoern Kiesbye (bjoern_kiesbye@web.de)
    @creation-date 2005-06-21
    @arch-tag: 3b8531f0-b578-4cea-8c06-cd66e48566f2
    @cvs-id $Id: project-manager-admin.tcl,v 1.1 2005/07/21 13:41:57 maltes Exp $
} {
    
    cf:required
} -properties {
    admin_href
} 


array set portlet_info $cf

set admin_href "[apm_package_url_from_id $portlet_info(project_manager_id)]admin"

