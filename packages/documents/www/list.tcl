ad_page_contract {
    @author iuri sampaio (iuri.sampaio@gmail.com)
    @date 2010-09-30
} {
    { keyword ""}
    { folder_id ""}
}


set myform [ns_getform]
if {[string equal "" $myform]} {
    ns_log Notice "No Form was submited"
} else {
    ns_log Notice "FORM"
    ns_set print $myform
    for {set i 0} {$i < [ns_set size $myform]} {incr i} {
	set varname [ns_set key $myform $i]
	set varvalue [ns_set value $myform $i]

	ns_log Notice " $varname - $varvalue"
    }
}

ns_log Notice "PAGE documents/list.tcl $folder_id"


set return_url [ad_return_url]

set n_past_days 99999
set category_id ""