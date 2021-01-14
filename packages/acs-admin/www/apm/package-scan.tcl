ad_page_contract {
    Scans the packages directory for new or modified packages.
    @author Jon Salz [jsalz@arsdigita.com]
    @creation-date 17 April 2000
    @cvs-id $Id: package-scan.tcl,v 1.4 2017/08/07 23:47:45 gustafn Exp $
} {
}

# A callback to just write an item to the connection.
proc apm_register_new_packages_callback { message } {
    doc_body_append "$message<li>\n"
    doc_body_flush
}

doc_body_append "[apm_header "Scan Packages"]
<ul><li>
"

apm_register_new_packages -callback apm_register_new_packages_callback

doc_body_append "
Done.
</ul>

<a href=\"./\">Return to the Package Manager</a>

[ad_footer]
"
# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
