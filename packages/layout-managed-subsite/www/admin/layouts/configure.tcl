ad_page_contract {

    Main configuration page for the layout manager package.  Defines the configuration
    wizard and tracks state.

    @author Don Baccus (dhogaza@pacifier.com)
    @creation-date 
    @cvs-id $Id: configure.tcl,v 1.3 2008/12/03 09:22:00 donb Exp $
}

# Now set up the wizard and off we go into configuration ecstasy!

layout::pageset::initialize -package_id [ad_conn package_id]

template::wizard::create -action configure -name configure -params {} -steps {
    1 -label "[_ layout-managed-subsite.Welcome]" -url /packages/layout-managed-subsite/lib/configure-help
    2 -label "[_ layout-managed-subsite.Configure_Private_Page_Sets]" -url /packages/layout-managed-subsite/lib/configure-private-pagesets
    3 -label "[_ layout-managed-subsite.Configure_User_Control]" -url /packages/layout-managed-subsite/lib/configure-configurability
    4 -label "[_ layout-managed-subsite.Add_Applications_and_Includelets]" -url /packages/layout-managed-subsite/lib/add-applications
    5 -label "[_ layout-managed-subsite.Configure_Master]" -url /packages/layout-manager/lib/pageset-configure
    6 -label "[_ layout-managed-subsite.Configure_Subsite]" -url /packages/layout-managed-subsite/lib/configure-subsite-integration
    100 -label "[_ layout-managed-subsite.Congratulations]" -url /packages/layout-managed-subsite/lib/configure-finish
}
template::wizard::get_current_step

# Beautify the context bar and title with the current wizard step's label.

array set current_info [array get wizard:${wizard:current_id}]]
set title $current_info(label)
set context [list $title]

ad_return_template
