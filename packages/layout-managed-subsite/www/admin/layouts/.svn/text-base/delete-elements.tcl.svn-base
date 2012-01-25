ad_page_contract {

    Delete a set of elements.

    @author Don Baccus (dhogaza@pacifier.com)
    @creation-date 
    @cvs-id $Id: delete-elements.tcl,v 1.2 2010/02/06 01:50:54 donb Exp $

} {
    element_id:naturalnum,notnull,multiple
    return_url:notnull
}

set deleted_element_ids [list]

db_transaction {
    foreach one_element_id $element_id {

        # For some reason I'm getting dupes in my element_id list from the checkboxes
        # set up by the list widget on the previous page.

        if { [lsearch -exact $deleted_element_ids $one_element_id] == -1 } {
            lappend deleted_element_ids $one_element_id
            layout::element::delete -element_id $one_element_id \
                -uninitialize=[expr {![layout::element::clone_p -element_id $element_id]}]
        }
    }
}
ad_returnredirect $return_url
