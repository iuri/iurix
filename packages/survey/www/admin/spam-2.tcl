#
#  Copyright (C) 2001, 2002 MIT
#
#  This file is part of dotLRN.
#
#  dotLRN is free software; you can redistribute it and/or modify it under the
#  terms of the GNU General Public License as published by the Free Software
#  Foundation; either version 2 of the License, or (at your option) any later
#  version.
#
#  dotLRN is distributed in the hope that it will be useful, but WITHOUT ANY
#  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
#  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
#  details.
#

# dotlrn/www/spam-2.tcl

ad_page_contract {
    @author yon (yon@openforce.net)
    @creation-date 2002-05-13
    @version $Id: spam-2.tcl,v 1.9 2006/08/08 21:26:24 donb Exp $
} -query {
} -properties {
    subject:onevalue
    message:onevalue
    format:onevalue
    spam_name:onevalue
    context_bar:onevalue
    group_id:onevalue
}


# Debug form! This chunk must be erased later                                                                                                                
set myform [ns_getform]
if {[string equal "" $myform]} {
    ns_log Notice "No Form was submited"
} else {
    ns_log Notice "FORM"
    ns_set print $myform
    for {set i 0} {$i < [ns_set size $myform]} {incr i} {
	set varname [ns_set key $myform $i]
	set $varname [ns_set value $myform $i]
    }
}

form get_values spam_message subject message format

if {$format == "html"} {
    set preview_message "$message"
} elseif {$format == "pre"} {
    set preview_message [ad_text_to_html $message]
} else {
    set preview_message [ad_quotehtml $message]
}

set context [list [list $referer Admin] "[_ survey.Spam_Group]"]
set subsite_id [ad_conn subsite_id]

db_1row select_group_id {
    SELECT group_id FROM groups WHERE group_name = (select title from acs_objects WHERE object_type = 'application_group' AND context_id = :subsite_id)
}
