#  www/[ec_url_concat [ec_url] /admin]/templates/add-3.tcl
ad_page_contract {

    @param template_id the ID of the template
    @param template_name the name of the template
    @param template 

  @author
  @creation-date
  @cvs-id $Id: add-3.tcl,v 1.4 2005/03/01 00:01:34 jeffd Exp $
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {

    template_id:integer
    template_name
    template:allhtml
}

permission::require_permission -object_id [ad_conn package_id] -privilege admin

# we need them to be logged in
set user_id [ad_conn user_id]

if {$user_id == 0} {
    
    set return_url "[ad_conn url]?[export_url_vars template_id template_name template]"

    ad_returnredirect "/register?[export_url_vars return_url]"
    ad_script_abort
}

set exception_count 0
set exception_text ""

if { ![info exists template_name] || [empty_string_p $template_name] } {
    incr exception_count
    append exception_text "<li>You forgot to enter a template name.\n"
}

if { ![info exists template] || [empty_string_p $template] } {
    incr exception_count
    append exception_text "<li>You forgot to enter anything into the ADP template box.\n"
}

if { $exception_count > 0 } {
    ad_return_complaint $exception_count $exception_text
    ad_script_abort
}



# see if the template's already in there, which means they pushed reload
if { [db_string get_dclick_temp "select count(*) from ec_templates where template_id=:template_id"] > 0 } {
    ad_returnredirect index
    ad_script_abort
}

db_transaction  {
    db_dml insert_new_template {
	INSERT INTO ec_templates
	(template_id, template_name, template, last_modified, last_modifying_user, modified_ip_address)
	VALUES
	(:template_id, :template_name, :template, sysdate, :user_id, '[DoubleApos [ns_conn peeraddr]]')
    }
} 
db_release_unused_handles

ad_returnredirect index
