ad_page_contract {
    The display logic for the project manager portlet

    @author Bjoern Kiesbye (kiesbye@theservice.de)
    @cvs_id $Id: project-manager-portlet.tcl
} {
    orderby:optional
    {status_id:integer,optional}
    {searchterm ""}
    category_id:multiple,optional
    {format "normal"}
    {assignee_id ""}
    {is_observer_p ""}
    {page_num 0}
    
} -properties {

    context:onevalue
    projects:multirow
    write_p:onevalue
    create_p:onevalue
    admin_p:onevalue
    task_term:onevalue
    task_term_lower:onevalue
    project_term:onevalue
    project_term_lower:onevalue
}

# daily?
set daily_p [parameter::get -parameter "UseDayInsteadOfHour" -default "f"]

#------------------------
# Check if the project will be handled on daily basis or will show hours and minutes
#------------------------

set fmt "%x %r"
if { $daily_p } {
    set fmt "%x"
} 

set projects_portlet [parameter::get_from_package_key -package_key project-manager-portlet -parameter ProjectsPortlet]

array set config $cf

set base_url "[ad_conn package_url]project-manager/"

set project_manager_id $config(project_manager_id)
set package_id $config(project_manager_id)

if {$config(project_manager_status_id) == "{}" } {

    set project_manager_status_id ""
#    set status_id ""

} else {

    set project_manager_status_id $config(project_manager_status_id)
#    set status_id $config(project_manager_status_id)

}

if {$config(project_manager_action_p) == "{}" } {

    set project_manager_action_p 1 
    set action_p 1

} else {

    set project_manager_action_p $config(project_manager_action_p)
    set action_p $config(project_manager_action_p)

}

if {$config(project_manager_searchterm) == "{}" } {

    set searchterm ""

} else {

    set searchterm $config(project_manager_searchterm)

}


 
if { $config(project_manager_orderby) == "{}"} {

    set project_manager_orderby ""
    set orderby ""

} else {

    set project_manager_orderby $config(project_manager_orderby)
    set orderby $config(project_manager_orderby)
}

if {$config(project_manager_bulk_p) == "{}"} {

    set project_manager_bulk_p ""
    set bulk_p 1

} else { 

    set project_manager_bulk_p $config(project_manager_bulk_p)
    set bulk_p $config(project_manager_bulk_p)
}

# --------------------------------------------------------------- #

set exporting_vars { status_id assignee_id orderby format }
set hidden_vars [export_vars -form $exporting_vars]

set status_ids [db_list get_all_open_states {}]
set status_ids 1
