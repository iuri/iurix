ad_page_contract {

    Manage a single datasource/pageset binding

    @author Don Baccus (dhogaza@pacifier.com)
    @creation-date 
    @cvs-id $Id: manage-includelets.tcl,v 1.3 2008/12/05 13:59:56 donb Exp $
} {
    pageset_id:naturalnum,notnull
    package_id:naturalnum,notnull
    package_url:notnull
    package_key:notnull
    admin_url:notnull
}

set context [list "[_ layout-managed-subsite.Manage_Includelets]"]

set return_url [ad_conn url]?[ad_conn query]
db_multirow -unclobber -extend {copy_url delete_url} elements get_elements {} {
    set delete_url [export_vars -base [ad_conn package_url]admin/layouts/delete-elements \
                       { pageset_id element_id admin_url return_url}]
    set copy_url [export_vars -base [ad_conn package_url]admin/layouts/copy-elements \
                     { pageset_id element_id admin_url return_url}]
}

template::list::create \
    -name elements \
    -multirow elements \
    -key element_id \
    -bulk_actions "
        {[_ layout-managed-subsite.Delete_checked_elements]}
        [ad_conn package_url]admin/layouts/delete-elements
        {[_ layout-managed-subsite.Delete_checked_elements]}
        {[_ layout-managed-subsite.Copy_checked_elements]}
        [ad_conn package_url]admin/layouts/copy-elements
        {[_ layout-managed-subsite.Copy_checked_elements]}
    " \
    -bulk_action_export_vars {
        package_id element_id admin_url return_url
    } \
    -elements {
        title {
            label {[_ layout-managed-subsite.Title]}
        }
        includelet_name {
            label {[_ layout-managed-subsite.Includelet]}
        }
        state {
            label {[_ layout-managed-subsite.State]}
        }
        actions {
            label {[_ layout-managed-subsite.Action]}
            display_template {
              <a href="@elements.delete_url@" class="button">
                #layout-managed-subsite.Delete#
              </a>
              &nbsp;
              <a href="@elements.copy_url@" class="button">
                #layout-managed-subsite.Copy#
              </a>
            }
        }
    }

# Hide our new elements on the first page of the pageset (dotlrn design hangover)
set page_id [layout::page::get_id -pageset_id $pageset_id]

db_multirow -extend {add_url} includelets get_includelets {} {
    set add_url [export_vars -base [ad_conn package_url]admin/layouts/add-elements \
                    { package_id page_id name title admin_url return_url}]
    set singleton_p [ad_decode $singleton_p t Yes f No $singleton_p]
}

template::list::create \
    -name includelets \
    -multirow includelets \
    -key name \
    -bulk_actions "
        {[_ layout-managed-subsite.Add_checked_includelets]}
        [ad_conn package_url]admin/layouts/add-elements
        {[_ layout-managed-subsite.Add_checked_includelets]}
    " \
    -bulk_action_export_vars {
        package_id page_id return_url admin_url
    } \
    -elements {
        name {
            label {[_ layout-managed-subsite.Includelet]}
        }
        description {
            label {[_ layout-managed-subsite.Description]}
        }
        singleton_p {
            label {[_ layout-managed-subsite.Singleton]}
        }
        add {
            label {[_ layout-managed-subsite.Action]}
            link_url_col add_url
            link_html { title [_ layout-managed-subsite.Add] class button }
            display_template {[_ layout-managed-subsite.Add]}
        }
    }

ad_return_template
