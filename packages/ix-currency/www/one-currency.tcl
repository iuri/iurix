ad_page_contract {} {
    {code ""}
    {rate ""}
    {diff ""}
    {percent ""}
} -properties {
    context:onevalue
    title:onevalue
}


set url [ad_url]
set page_url "[ad_url][ad_conn url]"
#set page_url [export_vars -base [ad_conn url]]
#set page_url "[ad_url][ad_conn url]"
#set page_url [util_get_current_url]


set title "Currency Rate"
set context [list $title]
