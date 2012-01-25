ad_page_contract {

    Generate a list of applications that have supporting portlets.

    The user's returned to the current page after installing the select application(s).

    @author Don Baccus (dhogaza@pacifier.com)
    @creation-date 
    @cvs-id $Id: add-applications.tcl,v 1.2 2008/11/30 13:15:02 donb Exp $

}

set subsite_id [ad_conn subsite_id]
set subsite_url [ad_conn subsite_url]
set subsite_node_id [ad_conn subsite_node_id]

if { ![info exists pageset_id] } {
    set pageset_id [layout::pageset::get_master_template_id -package_id $subsite_id]
}

if { ![info exists return_url] } {
    set return_url [ad_conn url]?[ad_conn query]
}

db_multirow -extend {manage_url package_url includelets} services get_services {} {
    set manage_url [export_vars -base [ad_conn package_url]admin/layouts/manage-includelets \
                    { pageset_id {package_url $subsite_url} {package_id $subsite_id}
                      package_key {admin_url $return_url} }]
    set includelets {}
    foreach includelet [db_list_of_lists get_service_includelets {}] {
        if { [lindex $includelet 1] == 1 } {
            lappend includelets [lindex $includelet 0]
        } else {
            lappend includelets "[lindex $includelet 0]([lindex $includelet 1])"
        }
    }
    set includelets [join $includelets ", "]
}

template::list::create \
    -name services \
    -multirow services \
    -key package_key \
    -elements {
        package_key {
            label {[_ layout-managed-subsite.Service]}
        }
        includelets {
            label {[_ layout-managed-subsite.Active_Includelets]}
        }
        manage {
            label {[_ layout-managed-subsite.Action]}
            link_url_col manage_url
            link_html { title #layout-managed-subsite.Manage_Includelets# class button }
            display_template { [_ layout-managed-subsite.Manage_Includelets] }
        }
    }

set package_id_list [site_node::get_children \
                        -node_id [ad_conn subsite_node_id] \
                        -package_type apm_application \
                        -element package_id]

set package_key_list [site_node::get_children \
                         -node_id [ad_conn subsite_node_id] \
                         -package_type apm_application \
                         -element package_key]

db_multirow -extend {manage_url package_url includelets} mounted_applications get_mounted_applications {} {
    set package_url [site_node::get_url_from_object_id -object_id $package_id]
    set manage_url [export_vars -base [ad_conn package_url]admin/layouts/manage-includelets \
                    { pageset_id package_id package_url package_key {admin_url $return_url} }]
    set includelets {}
    foreach includelet [db_list_of_lists get_mounted_includelets {}] {
        if { [lindex $includelet 1] == 1 } {
            lappend includelets [lindex $includelet 0]
        } else {
            lappend includelets "[lindex $includelet 0]([lindex $includelet 1])"
        }
    }
    set includelets [join $includelets ", "]
}

template::list::create \
    -name mounted_applications \
    -multirow mounted_applications \
    -key package_key \
    -elements {
        package_key {
            label {[_ layout-managed-subsite.Application]}
        }
        package_url {
            label {[_ layout-managed-subsite.URL]}
        }
        includelets {
            label {[_ layout-managed-subsite.Active_Includelets]}
        }
        manage {
            label {[_ layout-managed-subsite.Action]}
            link_url_col manage_url
            link_html { title #layout-managed-subsite.Manage_Includelets# class button }
            display_template { [_ layout-managed-subsite.Manage_Includelets] }
        }
    }

db_multirow -extend {add_url includelets} available_applications get_available_applications {} {
    set add_url [export_vars -base [ad_conn package_url]admin/layouts/add-applications-2 \
                    { pageset_id package_key return_url }]
    set includelets [join [db_list get_available_includelets {}] ", "]
}

template::list::create \
    -name available_applications \
    -multirow available_applications \
    -key package_key \
    -bulk_actions "
        {[_ layout-managed-subsite.Add_checked_applications]}
        [ad_conn package_url]admin/layouts/add-applications-2
        {[_ layout-managed-subsite.Add_checked_applications]}
    " \
    -bulk_action_export_vars {
        package_key pageset_id return_url
    } \
    -elements {
        package_key {
            label {[_ layout-managed-subsite.Application]}
        }
        includelets {
            label {[_ layout-managed-subsite.Supported_Includelets]}
        }
        add {
            label {[_ layout-managed-subsite.Action]}
            link_url_col add_url
            link_html { title [_ layout-managed-subsite.Add_single_application] class button }
            display_template {[_ layout-managed-subsite.Add]}
        }
    }

# Now, if we're in the template wizard, generate the wizard form and buttons.
set wizard_p [template::wizard::exists]
if { $wizard_p } {

    ad_form -name add-applications -form {
        foo:text(hidden),optional
    } -on_submit {
        template::wizard::forward
    }

    template::wizard::submit add-applications -buttons {back next}
}

ad_return_template
