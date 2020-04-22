# Set the tabs then use the plain master to render the page.

subsite_navigation::define_pageflow \
    -navigation_multirow navigation -group main -subgroup sub \
    -show_applications_p [parameter::get -package_id [ad_conn subsite_id] \
                             -parameter ShowApplications -default 1] \
    -no_tab_application_list [parameter::get -package_id [ad_conn subsite_id] \
                                 -parameter NoTabApplicationList -default ""] \
    -initial_pageflow [parameter::get -package_id [ad_conn subsite_id] \
                          -parameter UserNavbarTabsList -default ""]



template::head::add_meta -http_equiv "charset" -name "charset" -content "utf-8"
template::head::add_meta -name "viewport" -content "width=device-width, initial-scale=1, shrink-to-fit=no"
template::head::add_meta -name "description" -content "IURIX Website"
template::head::add_meta -name "author" -content "Iuri de Araujo Sampaio (iuri@iurix.com)"
template::head::add_meta -name "keywords" -content "Tecnologia, Social corporativo, Arte e Cultura"


template::head::add_script -async -src "https://www.googletagmanager.com/gtag/js?id=UA-144184532-1"
template::head::add_javascript -script {
    window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments)};
    gtag('js', new Date());
    gtag('config', 'UA-144184532-1');
} -order 1


# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
