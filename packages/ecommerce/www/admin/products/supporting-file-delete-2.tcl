#  www/[ec_url_concat [ec_url] /admin]/products/supporting-file-delete-2.tcl
ad_page_contract {
  Delete a file.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id: supporting-file-delete-2.tcl,v 1.2 2002/09/10 22:22:45 jeffd Exp $
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  product_id:integer,notnull
  file
}


permission::require_permission -party_id [ad_conn user_id] \
    -object_id [ad_conn package_id]  -privilege admin

if { [regexp {/} $file] } {
    error "Invalid filename."
}

set dirname [db_string dirname_select "select dirname from ec_products where product_id=:product_id"]
db_release_unused_handles

set subdirectory [ec_product_file_directory $product_id]

set full_dirname "[ec_data_directory][ec_product_directory]$subdirectory/$dirname"

ns_unlink $full_dirname/$file

ad_returnredirect "supporting-files-upload.tcl?[export_url_vars product_id]"
