ad_page_contract {

    Add one or more package_keys to this instance of the layout manager package

    @author Don Baccus (dhogaza@pacifier.com)
    @creation-date 
    @cvs-id $Id: add-applications-2.tcl,v 1.2 2008/12/01 18:03:58 donb Exp $

} {
    package_key:multiple
    return_url:notnull,optional
}

set added_package_keys [list]

db_transaction {
    foreach one_package_key $package_key {

        # For some reason I'm getting dupes in my package_key list from the checkboxes
        # set up by the list widget on the previous page.

        if { [lsearch -exact $added_package_keys $one_package_key] == -1 } {

            lappend added_package_keys $one_package_key

            # Now mount the package_key under our URL
            site_node::instantiate_and_mount \
                -parent_node_id [ad_conn subsite_node_id] \
                -package_key $one_package_key

        }
    }
}

if { [info exists return_url] } {
    ad_returnredirect $return_url
}
