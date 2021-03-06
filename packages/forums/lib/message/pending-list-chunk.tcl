ad_page_contract {

    Moderate a Forum

    @author Ben Adida (ben@openforce.net)
    @creation-date 2002-05-24
    @cvs-id $Id: pending-list-chunk.tcl,v 1.2.2.1 2015/09/12 11:06:24 gustafn Exp $

}

# Get the threads that need approval
db_multirow pending_threads select_pending_threads {}

if {([info exists alt_template] && $alt_template ne "")} {
  ad_return_template $alt_template
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
