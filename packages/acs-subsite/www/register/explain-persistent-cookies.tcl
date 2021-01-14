ad_page_contract {

    Prepare some datasources for the explain-persistent-cookies .adp

    @author Bryan Quinn (bquinn@arsdigita.com)
    @creation-date Mon Oct 16 09:27:34 2000
    @cvs-id $Id: explain-persistent-cookies.tcl,v 1.2 2017/08/07 23:47:59 gustafn Exp $
} {

} -properties {
    home_link:onevalue
}

set home_link [ad_site_home_link]
ad_return_template


# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
