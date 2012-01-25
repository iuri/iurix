ad_page_contract {
    Configure the layout managed subsite package's look and feel.
} {
}

ad_form -name configure-subsite-integration -form {
    {template_style:integer(radio)
        {options {{"[_ layout-managed-subsite.tabbed_navigation]" 0}
                  {"[_ layout-managed-subsite.plain_navigation]" 1}
                  {"[_ layout-managed-subsite.use_existing_master]" 2}}}
        {values {0}}
        {label "[_ layout-managed-subsite.choose_master]"}
    }
    {show_single_button_navbar_p:boolean(radio)
        {options {{Yes 1} {No 0}}}
        {values {0}}
        {label "[_ layout-managed-subsite.show_single_tab]"}
    }
    {show_empty_pages_p:boolean(radio)
        {options {{Yes 1} {No 0}}}
        {values {0}}
        {label "[_ layout-managed-subsite.show_empty_pages]"}
    }
    {show_applications_p:boolean(radio)
        {options {{Yes 1} {No 0}}}
        {values {1}}
        {label "[_ layout-managed-subsite.show_applications]"}
    }
} -on_submit {

    switch $template_style {

        0 {subsite::set_theme -theme layout_managed_subsite_tabbed}

        1 {subsite::set_theme -theme layout_managed_subsite_plain}

        2 {}

    }

    parameter::set_value \
        -parameter ShowSingleButtonNavbar \
        -package_id [ad_conn package_id] \
        -value $show_single_button_navbar_p

    parameter::set_value \
        -parameter ShowEmptyPages \
        -package_id [ad_conn package_id] \
        -value $show_empty_pages_p

    parameter::set_value \
        -parameter ShowApplications \
        -package_id [ad_conn package_id] \
        -value $show_applications_p

    template::wizard::forward
}

template::wizard::submit configure-subsite-integration -buttons {back next}
