::xowiki::Package initialize -ad_doc {
  Security management for xowiki pages

  @author Gustaf Neumann (gustaf.neumann@wu-wien.ac.at)
  @creation-date Aug 16, 2006
  @cvs-id $Id: permissions.tcl,v 1.8.2.1 2019/05/08 14:33:40 gustafn Exp $

} -parameter {
  {-item_id:naturalnum,optional}
}

if {[info exists item_id]} {
  set page [::xo::db::CrClass get_instance_from_db -item_id $item_id]
  $page volatile
  set object_id  $item_id
  set page_name [$page name]
  set page_title [_ xowiki.permissions_manage_page]
  set return_url [::$package_id query_parameter return_url [::$package_id package_url]admin/list]
} else {
  set object_id  $package_id
  set package_name [apm_instance_name_from_id $package_id]
  set package_name [::$package_id get_parameter PackageTitle $package_name]
  set page_title [_ xowiki.permissions_manage_package]
  set return_url [::$package_id query_parameter return_url [::$package_id package_url]admin]
}

set context [list $page_title]



# Local variables:
#    mode: tcl
#    tcl-indent-level: 2
#    indent-tabs-mode: nil
# End:
