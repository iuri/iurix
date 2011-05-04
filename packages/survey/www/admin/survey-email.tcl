ad_page_contract {

    this page offers options for sending a survey by email 
    to various groups

    @param survey_id
    
    @author iuri.sampaio@gmail.com
    @creation-date   2011-04-14
} {
    { survey_id ""}
    { package_id:integer 0}
    { to "responded"}  
    { recipients:multiple "" } 
    { user_id:multiple ""}
    { groups:multiple "" }
    { spam_all 0 }
    
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

set package_id [ad_conn package_id]
set user_id [ad_conn user_id]
set sender_id [ad_conn user_id]



ns_log Notice "$recipients"
ns_log Notice "$user_id"
