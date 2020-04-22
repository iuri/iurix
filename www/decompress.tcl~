ad_page_contract {} {
    {str ""}
}

ad_proc -public compress {
    {-str ""}
} {
    Compresses string
} {

    ns_log Notice "INPUT STR $str"
    set result ""
    set total 1
    set c ""
    
    for {set i 0} {$i < [llength [split $str ""]]} {incr i} {
	if {$c ne "" && [lindex [split $str ""] $i] ne $c && $i ne 0} {
	    
	    append result "${c}${total}"
	    set c [lindex [split $str ""] $i]
	    set total 0
	}
	incr total
	set c [lindex [split $str ""] $i]
    }

    append result "${c}${total}"
    
    ns_log Notice "OUTPUT RESULT $result"
    return $result
}

ad_proc -public decompress {
    {-str ""}
} {
    Decompresses string
} {
    # regular expersion where numbers 0-9 is the parter
    ns_log Notice "INPUT STR $str"
    set result ""

    set numbers [regexp -all -inline -- {[0-9]+} $str]
    ns_log Notice "NUMBERS $numbers"
    
    set chars [regexp -all -inline -- {[a-z]+} $str]
    ns_log Notice "CHAARS $chars"
    set i 0
    foreach c $chars {
	for {set j 0} {$j < [lindex $numbers $i]} {incr j} {
	    append result $c
	}
	incr i		       
    } 

    ns_log Notice "OUTPUT RESULT $result"
    
    return $result    
}

ad_proc -private compress_not_cached  {
    {-str ""}
} {
    Compresses string
} {

    while $str ne "" {

	 # Mem_cache ns_cache  NAVISERVER api


    }


    return $result
}

ad_proc -public  decompress_not_cached {
    {-str ""}
} {
    Decompresses string
} {

    while $str ne "" {
       
    }


    return $result
}



# Compress string
#set result [compress -str $str]

# decompress string
set result [decompress -str $str]

