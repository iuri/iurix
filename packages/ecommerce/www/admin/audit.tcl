#  /www/[ec_url_concat [ec_url] /admin]/audit.tcl
ad_page_contract {

  Displays the audit info for one id in the id_column of a table and its 
  audit history.

  @author Jesse
  @creation-date 7/17
  @cvs-id $Id: audit.tcl,v 1.4 2008/08/25 12:06:52 torbenb Exp $
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  audit_name:html
  audit_id:sql_identifier,notnull
  audit_id_column:sql_identifier,notnull
  return_url:optional
  audit_tables:notnull
  main_tables:notnull
}

permission::require_permission -party_id [ad_conn user_id] \
    -object_id [ad_conn package_id]  -privilege admin

set title "[ec_system_name] Audit Trail"
set context [list $title]

set counter 0
set main_table_html ""
foreach main_table $main_tables {
    append main_table_html "<h3>$main_table</h3> [ec_audit_trail $audit_id [lindex $audit_tables $counter] $main_table $audit_id_column]"
    incr counter
}

