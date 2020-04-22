ad_page_contract {} {
    {url:optional ""}
    {result ""}
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




ad_form -name seo-tester -has_submit 1 -form {
    {request_id:integer(text),optional {label "Item ID"}}
    {domain:text(hidden) {value "salvadorairport.com.br"}}
    {submit:text(submit) {value "Analisar+Site"}}
    
} -on_submit {
    
    set url "https://app.neilpatel.com/br/seo_analyzer/site_audit"
    
    set domain "salvadorairport.com.br"
    set submit "Analisar+Site"
    ns_log Notice "DOMAIN $domain \n SUBMIT $submit"
    
    # set result [im_httppost $url [ns_getform] ""]
    # set result [util::http::post -url $url -formvars [ns_getform]]


    set result [util::http::post -url $url -body [export_vars -base {domain submit}]]

    ns_log Notice "********* RESULT $result"


    set data [lindex $result 3]
    ns_log Notice "********* DATA $data"
    
} -after_submit {
    
    
    doc_return 200 "application/json" $data
    ad_script_abort
}




