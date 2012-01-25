ad_page_contract {
    
    @author iuri sampaio (iuri.sampaio@gmail.com)
} {
    {page_id ""}
    {pageset_id ""}
    {return_url ""}
 
}

set subsite_name [ad_conn instance_name]
set context "[ad_conn url] Theme"


set return_url [ad_conn url]?[ad_conn query]
set package_url [ad_conn package_url]

array set page [layout::page::get -page_id $page_id]
array set page_template [layout::page_template::get -name $page(page_template)]


db_multirow page_templates select_page_templates {}


ad_form -name themes -cancel_url $return_url -form {
    {info:text(inform)
	{label "  <h1>#layout-manager.Change_Layout#</h1>"}
    }
    {return_url:text(hidden),optional
	{value $return_url}
    }

} -on_submit {
    
    subsite::set_layout -theme $theme

} -after_submit {

    ad_returnredirect $return_url
    ad_script_abort

}