ad_page_contract {}


set codes [list USD JPY BGN CZK DKK GBP HUF PLN RON SEK CHF ISK NOK HRK RUB TRY AUD BRL CAD CNY HKD IDR ILS INR KRW MXN MYR NZD PHP SGD THB ZAR]
# set length [llength $codes]



proc explore {parent currency} {
    #ns_log Notice "Running explore"	    
    set type [$parent nodeType]
    set name [$parent nodeName]	    
    #ns_log Notice  "$parent is a $type node named $name"	    
    if {$type != "ELEMENT_NODE"} then return 	    
    # ns_log Notice "[llength [$parent attributes]]"
    if {[llength [$parent attributes]]} {
	# ns_log Notice "attributes: [join [$parent attributes] ", "]"
	if { [llength [$parent attributes]] == 4 && $name == "Obs" } {
	    set date [$parent getAttribute TIME_PERIOD]
	    set rate [$parent getAttribute OBS_VALUE]
	    set date [db_string select_date { SELECT :date::timestamptz FROM dual } -default ""]
	    ns_log Notice "INSERT $currency $rate $date "
	    if {[db_0or1row select_currency {
		SELECT rate_id
		FROM ix_currency_rates
		WHERE currency_code = :currency
		AND rate = :rate
		AND creation_date = :date
	    } ]} {
		db_1row select_rate {
		    select * FROM ix_currency_rates
		    WHERE rate_id = :rate_id
		} -column_array rate
		ns_log Notice "RATE [parray rate]" 
		ns_log Notice "NOT INSERTED ALREDY PRESENT "
	    } else {	    
		set rate_id [ix_currency::rates::add $currency $rate $date]
		#set rate_id [expr int(abs(rand()*100))]
		ns_log Notice "INSERTED"
	    }
	    #	    ns_log Notice "$value1 $value2"
	}
    }
    
    foreach child [$parent childNodes] {
	explore $child $currency
    }
}



foreach currency_code $codes {
    ns_log Notice "Curency CODE $currency_code"
    
    set url "https://www.ecb.europa.eu/stats/policy_and_exchange_rates/euro_reference_exchange_rates/html/[string tolower $currency_code].xml"
    
    set result [ns_http run $url]
    # ns_log Notice "$result"
    
    set status [dict get $result status]
    ns_log Notice "STATUS $status"
    
    if {$status eq 200} { 
	set xml [dict get $result body]
#	ns_log Notice "XML \n $xml"	
	set doc [dom parse $xml]	
	#ns_log Notice "DOC \n $doc"       
	set root [$doc documentElement]
		
	
	explore $root $currency_code
	
	$doc delete 
	
    }    
}


ad_returnredirect index
ad_script_abort
