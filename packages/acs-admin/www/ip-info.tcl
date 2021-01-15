ad_page_contract {
  Displays information about an IP address

    @author Gustaf Neumann

    @cvs-id $Id: ip-info.tcl,v 1.1.2.1 2020/09/22 07:50:36 gustafn Exp $
} -query {
    {ip}
} -properties {
    title:onevalue
    context:onevalue
}

set title "IP Lookup"
set context [list $title]

if {[catch {set dns_name [ns_hostbyaddr $ip]}]} { set dns_name "DNS lookup for $ip failed" }


# Local variables:
#    mode: tcl
#    tcl-indent-level: 2
#    indent-tabs-mode: nil
# End:
