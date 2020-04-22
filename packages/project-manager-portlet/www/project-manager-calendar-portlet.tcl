ad_page_contract {
} {
    {view "month"}
    {date ""}
    {julian_date ""}
    {hide_closed_p "t"}
    {display_p "l"}
    {t_date ""}
} 

set user_id [ad_conn user_id]
set package_id [dotlrn_community::get_package_id_from_package_key -package_key project-manager -community_id [dotlrn_community::get_community_id]]

# daily?
set daily_p [parameter::get -parameter "UseDayInsteadOfHour" -default "f" -package_id $package_id]



