ad_page_contract {} {
} -properties {
    context_bar
}

set package_id [ad_conn package_id]

permission::require_permission \
    -object_id $package_id \
    -privilege admin]

set context [list]

set title "Administration"

set parameters_url [export_vars -base "/shared/parameters" {
    package_id { return_url [ad_return_url] }
}]
