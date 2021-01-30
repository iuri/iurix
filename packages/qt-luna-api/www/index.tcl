ad_page_contract {} {
} -properties {
    context_bar
}

set context [list]

set title "Main"

set package_id [ad_conn package_id]
set package_name [apm_instance_name_from_id $package_id]
set package_url [apm_package_url_from_id $package_id]

ns_log Notice "$package_name $package_url"


set admin_p [permission::permission_p -object_id $package_id \
		 -privilege admin -party_id [ad_conn untrusted_user_id]]

if { $admin_p } {
    set admin_url "admin"
    set admin_title Administration
}



