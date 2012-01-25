ad_page_contract {

    Make exact copies of a set of elements.

    @author Don Baccus (dhogaza@pacifier.com)
    @creation-date 
    @cvs-id $Id: copy-elements.tcl,v 1.2 2008/12/03 09:22:00 donb Exp $

} {
    element_id:naturalnum,notnull,multiple
    return_url:notnull
}

set copied_element_ids [list]

db_transaction {
    foreach one_element_id $element_id {

        # For some reason I'm getting dupes in my element_id list from the checkboxes
        # set up by the list widget on the previous page.

        if { [lsearch -exact $copied_element_ids $one_element_id] == -1 } {
            lappend copied_element_ids $one_element_id
            array set element [layout::element::get -element_id $one_element_id]
            set page_id $element(page_id)
            set page_column $element(page_column)
            set sort_key [db_string get_sort_key {}]
            layout::element::clone \
                -element_id $one_element_id \
                -sort_key $sort_key \
                -state hidden
        }
    }
}
ad_returnredirect $return_url
