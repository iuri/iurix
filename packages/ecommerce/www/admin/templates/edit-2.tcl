#  www/[ec_url_concat [ec_url] /admin]/templates/edit-2.tcl
ad_page_contract {
    @param template_id
    @param template_name
    @param template

  @author
  @creation-date
  @cvs-id $Id: edit-2.tcl,v 1.3 2002/09/18 21:33:56 jeffd Exp $
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    template_id:integer
    template_name
    template:allhtml
}

permission::require_permission -party_id [ad_conn user_id] \
    -object_id [ad_conn package_id]  -privilege admin


# check the template for the execution of functions

set f [ec_adp_function_p $template]
ns_log Notice "ADP_FUNCTION_P $f"
if {$f != 0} {
    ad_return_complaint 1 "
    <P>We're sorry, but files edited here cannot
    have functions in them for security reasons. Only HTML and 
    <%= \$variable %> style code may be used.
    This template appears to contain <tt>$f</tt>."
    ad_script_abort
}

db_dml update_ec_templates "update ec_templates
set template_name=:template_name, template=:template
where template_id=:template_id"
db_release_unused_handles

ad_returnredirect index
