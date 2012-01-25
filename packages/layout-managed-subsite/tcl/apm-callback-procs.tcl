ad_library {
    Installation procs for layout_managed_subsite

    @author Don Baccus (dhogaza@pacifier.com) Furfly (http://furfly.net)
}

namespace eval layout_managed_subsite {}
namespace eval layout_managed_subsite::install {}

ad_proc layout_managed_subsite::install::after_install {} {
    Package after installation callback proc
} {

    db_transaction {
    
        # Define a couple of includelets
    
        layout::includelet::new \
            -name layout_admin_includelet \
            -description "Layout Administration" \
            -title "Layout Administration" \
            -application layout-managed-subsite \
            -template /packages/layout-managed-subsite/lib/layout-admin-includelet \
            -required_privilege admin

        layout::includelet::new \
            -name subsites_includelet \
            -description "Display Subsites" \
            -title "Subsites" \
            -application layout-managed-subsite \
            -template /packages/acs-subsite/lib/subsites
    
        layout::includelet::new \
            -name applications_includelet \
            -description "Display Subsite Applications" \
            -title "Applications" \
            -application layout-managed-subsite \
            -template /packages/acs-subsite/lib/applications

        subsite::new_subsite_theme \
            -key layout_managed_subsite_tabbed \
            -name "Layout Managed Subsite Tabbed" \
            -template /packages/layout-managed-subsite/lib/tabbed-master \
            -css {{{href /resources/openacs-default-theme/styles/default-master.css} {media all}}
                  {{href /resources/acs-templating/forms.css} {media all}}
                  {{href /resources/acs-templating/lists.css} {media all}}} \
            -form_template /packages/acs-templating/resources/forms/standard \
        -list_template /packages/acs-templating/resources/lists/table \
        -list_filter_template /packages/acs-templating/resources/lists/filters 

        subsite::new_subsite_theme \
            -key layout_managed_subsite_plain \
            -name "Layout Managed Subsite Plain" \
            -template /packages/layout-managed-subsite/lib/plain-master \
            -css {{{href /resources/openacs-default-theme/styles/default-master.css} {media all}}
                  {{href /resources/acs-templating/forms.css} {media all}}
                  {{href /resources/acs-templating/lists.css} {media all}}} \
            -form_template /packages/acs-templating/resources/forms/standard \
        -list_template /packages/acs-templating/resources/lists/table \
        -list_filter_template /packages/acs-templating/resources/lists/filters 

    }
}

ad_proc -private layout_managed_subsite::install::after_upgrade {
    {-from_version_name:required}
    {-to_version_name:required}
} {

    Upgrade logic
    
} {
    apm_upgrade_logic \
	-from_version_name $from_version_name \
	-to_version_name $to_version_name \
	-spec {
        }
}
