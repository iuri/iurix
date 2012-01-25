ad_page_contract {
	Turn on/off portal customization

} {
    {return_url ""}
}


ns_log Notice "[ad_conn package_id]"
set vertical_menu_p [parameter::get -package_id [ad_conn package_id] -parameter "ShowLeftFunctionalMenupP"]

if {$vertical_menu_p eq 0} {
    parameter::set_value -package_id [ad_conn package_id] -parameter "ShowLeftFunctionalMenupP" -value 1
} 

if {$vertical_menu_p eq 1} {
    parameter::set_value -package_id [ad_conn package_id] -parameter "ShowLeftFunctionalMenupP" -value 0
}

ad_returnredirect $return_url