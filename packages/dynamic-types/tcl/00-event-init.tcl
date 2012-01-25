ad_library {

    Initialise the event dispatcher nsv.

    @author Lee Denison (lee@thaum.net)
    @creation-date 2004-03-17
    @cvs-id $Id: 00-event-init.tcl,v 1.5 2005/09/04 12:13:28 maltes Exp $

}

nsv_set util_events lock [ns_mutex create]
