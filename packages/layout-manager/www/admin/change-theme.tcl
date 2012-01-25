ad_page_contract {
    
    @author iuri sampaio (iuri.sampaio@gmail.com)
} {
    {return_url ""}
}

set subsite_name [ad_conn instance_name]
set context "[ad_conn url] Theme"

set theme_options [subsite::get_theme_options]
set subsite_options [layout::get_subsite_options]


ad_form -name themes -cancel_url $return_url -form {
    {info:text(inform)
	{label "  <h1>#layout-manager.Change_Theme#</h1>"}
    }
    {theme:text(select)
	{label "Theme"}
	{options $theme_options}
    }
    {return_url:text(hidden),optional
	{value $return_url}
    }

} -on_submit {
    
    subsite::set_theme -theme $theme

} -after_submit {

    ad_returnredirect "$return_url"
    ad_script_abort

}