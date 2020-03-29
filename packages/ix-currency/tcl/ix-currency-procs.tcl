ad_library {
    @author Iuri Sampaio (iuri.sampaio@iurix.com)
    creation-date 2015-09-11
}

namespace eval ix_currency {}
namespace eval ix_currency::rates {}


ad_proc -public ix_currency::rates::add_currency_history {currency rate date} {
    Adds records of currency's rate
} {
    ns_log Notice "Running ix_currency::rates::add..."

    ns_log Notice "$currency $rate $date"


    set rate_id [db_exec_plsql insert_rate {
	SELECT ix_currency_rate__new (
			     :currency,
			     :rate,
			     :date
	     )
    }]

    return $rate_id
}



ad_proc -public ix_currency::get_currency_rates {
    {interval ""}
} {
    Returns a list with all selected currencies

    Ref. http://stackoverflow.com/questions/9716868/select-todays-since-midnight-timestamps-only
    http://www.postgresql.org/docs/8.1/static/functions-datetime.html
} {
    set currencies ""

    if {[string equal $interval "today"]} {
	set currencies [db_list_of_lists select_currency_rates {
	    SELECT currency_code, rate FROM ix_currency_rates WHERE creation_date > now() - interval '24 hour'
	    -- order by creation_date desc limit 31;
	}] 
    }

    return $currencies

}




ad_proc -public ix_currency::rates::add {currency rate} {
    Adds daily currency's rate
} {
    ns_log Notice "Running ix_currency::rates::add..."
    set cur_rate 0    
    db_0or1row select_rate {
	SELECT rate FROM ix_currency_rates
	WHERE currency_code = :currency
	AND creation_date > now () - interval '23 hour'
	ORDER BY creation_date ;
    }
    
    if {$rate ne $cur_rate } {	   
	set rate_id [db_exec_plsql insert_rate {
	    SELECT ix_currency_rate__new (
					  :currency,
					  :rate
					  )
	}]
	return $rate_id
    }	
    return 
}


ad_proc -public ix_currency::get_xml_ecb_currency_rates {} {
    
    Downloads and storage currency  rates

    @author Iuri Sampaio (iuri.sampaio@iurix.com)
    @creation-date 2015-10-18

    References
    @http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml
    
} {
    ns_log Notice "Running ad_proc ix_currency::get_xml_ecb_currency_rates    "
    set url "https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml"
    
    set result [ns_http run $url]
    #    ns_log Notice "$xml"

    set status [dict get $result status]
    ns_log Notice "STATUS $status"

    
    set xml [dict get $result body]
    ns_log Notice "XML \n $xml"
    
    set doc [dom parse $xml]

    ns_log Notice "DOC \n $doc"
    
    set root [$doc documentElement]
    
    proc explore {parent} {
	
	set type [$parent nodeType]
	set name [$parent nodeName]
	
	#   ns_log Notice  "$parent is a $type node named $name"
	
	if {$type != "ELEMENT_NODE"} then return 
	
	#ns_log Notice "[llength [$parent attributes]]"
	if {[llength [$parent attributes]]} {
	    # ns_log Notice "attributes: [join [$parent attributes] ", "]"
	    if { [llength [$parent attributes]] == 2 && $name == "Cube" } {
		set value1 [$parent getAttribute currency]
		set value2 [$parent getAttribute rate] 
		ix_currency::rates::add $value1 $value2
		
		
		#	    ns_log Notice "$value1 $value2"
	    }
	}
	
	foreach child [$parent childNodes] {
	    explore $child
	}
    }
    
    
    explore $root
    
    $doc delete 
    
    return 0
}









ad_proc -public ix_currency::get_ecb_rates {
    {-src ""}
} {
    Reads and parses XML file
} {
    ns_log Notice "Running ix_currency_ecb_rates..."
    #ns_log Notice "$src"
    set xml [ns_httpget $src]

    
set doc [dom parse $xml]
    set root [$doc documentElement]

    ix_currency::explore_xml $root

    $doc delete 


}





ad_proc -public ix_currency::explore_xml {parent} {
    Reads and parses XML file
} {

    set type [$parent nodeType]
    set name [$parent nodeName]
    
   # ns_log Notice  "$parent is a $type node named $name"

    if {$type != "ELEMENT_NODE"} then return 
    
    #ns_log Notice "[llength [$parent attributes]]"
    if {[llength [$parent attributes]]} {
    #    ns_log Notice "attributes: [join [$parent attributes] ", "]"
	if { [llength [$parent attributes]] == 2 && $name == "Cube" } {
	    set value1 [$parent getAttribute currency]
	    set value2 [$parent getAttribute rate] 
	    currency::rate::add $value1 $value2

	}
    }

    foreach child [$parent childNodes] {
	ix_currency::explore_xml $child
    }
}

