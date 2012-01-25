ad_page_contract {

    Add one or more includelets as new elements in the given pageset

    @author Don Baccus (dhogaza@pacifier.com)
    @creation-date 
    @cvs-id $Id: add-elements.tcl,v 1.3 2008/12/05 13:59:56 donb Exp $

} {
    page_id:naturalnum,notnull
    package_id:naturalnum,notnull
    name:notnull,multiple
    return_url:notnull
}

set added_names [list]

db_transaction {
    foreach one_name $name {

        # For some reason I'm getting dupes in my name list from the checkboxes
        # set up by the list widget on the previous page.

        if { [lsearch -exact $added_names $one_name] == -1 } {

            lappend added_names $one_name

            layout::element::new \
                -package_id $package_id \
                -page_id $page_id \
                -includelet_name $one_name \
                -state hidden \
                -initialize

        }
    }
}
ad_returnredirect $return_url
