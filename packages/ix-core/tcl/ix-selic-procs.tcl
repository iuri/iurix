ad_library {
    @author Iuri Sampaio (iuri@iurix.com)
    creation-date 2020-03-19
}

namespace eval ix_selic {}
namespace eval ix_selic::rates {}

ad_proc -public ix_selic::insert_result {
    {-p}
    {-mp}
    {-jp}
    {-jm}
    {-subtotal}
    {-total}
    {-dl}
    {-dc}
    {-dvm}     
} {
    It return the rate based in the date and type of rate
    
} {
	


    db_transaction {
	set id [db_nextval ix_selic_result_id_seq]
	db_dml insert_result {
	    INSERT INTO ix_selic_results (
	      result_id, value, value_fee, value_tax, tax_fee, subtotal, total, ack_date, creation_date, expiration_date
	    ) VALUES (
	      :id, :p, :mp, :jp, :jm, :subtotal, :total, :dl, :dc, :dvm
	    )
	}
    }
    
    
    
}

ad_proc -public ix_selic::rates::get_acumulated_rate {
    {-date}
    {-type}
} {
    It return the rate based in the date and type of rate
    
} {
    set  curr [db_string select_rate {
	SELECT rate FROM ix_selic_rates
	WHERE type = :type	
	AND EXTRACT(month FROM date) = EXTRACT(month FROM :date::timestamp)	
	AND EXTRACT(year FROM date) = EXTRACT(year FROM :date::timestamp)
    } -default 0]

    set next [db_string select_rate {
	SELECT SUM(rate) FROM ix_selic_rates
	WHERE type = :type
	AND date BETWEEN :date::timestamp AND now()
    } -default 0]

    if {![exists_and_not_null next] } {
	set next 0
    }
    ns_log Notice "RATE ACUMU $curr | $next"
    
    return [expr $curr + $next]
    
}

ad_proc -public ix_selic::rates::get_rate {
    {-date}
    {-type}
} {
    It return the rate based in the date and type of rate
    
} {   
    return [db_string select_rate {
	SELECT rate FROM ix_selic_rates
	WHERE EXTRACT(month FROM date) = EXTRACT(month FROM :date::timestamp)
	AND EXTRACT(year FROM date) = EXTRACT(year FROM :date::timestamp)
	AND type = :type	
    } -default 0]
}


ad_proc -public ix_selic::rates::add {
    {-lines}
    {-type}
} {
    It parses and inserts lines of rates per month and year
    
} {    
    set years [split [lindex $lines 0] ","]
    ns_log Notice "YEARS $years"        
    # For each line(i.e. month) gets year and rate, then inserts on datamodel table
    for {set i 1} {$i < [llength $lines]} {incr i} {
	ns_log Notice "LINE [lindex $lines $i]"
	set line [split [lindex $lines $i] ","]
	if { [string map {"," ""} $line] ne ""} {
	    if {[llength $line] > 0} {	    
		set month [lindex $line 0]
		if {[exists_and_not_null month] } {
		    ns_log Notice "MONTH $month"
		    set l_months [list "zero" "janeiro" "fevereiro" "março" "abril" "maio" "junho" "julho" "agosto" "setembro" "outubro" "novembro" "dezembro"]
		    set month [lsearch $l_months [string tolower $month]]		    
		    ns_log Notice "MONTH $month number"
		    # for each rate of the month (i.e. position [0] of the line. $line(0)
		    for {set j 1} {$j < [llength $line]}  {incr j} {
			set rate [string map {"%" ""} [lindex $line $j]]
			set year [lindex $years $j]
			ns_log Notice  "YEAR $year"
			set date "$year-$month-01"			
			if {[exists_and_not_null rate] && [exists_and_not_null date]} {			    
			    # UPDATE RATE OR    # INSERT RATE and DATE
			    # TO CREATE validatons of rates based in the month and year. if there is one then update it instead of insert a  new rate
			    ns_log Notice "INSERT RATE: $rate | DATE: $date  | TYPE $type"		
			    db_transaction {
				db_exec_plsql insert_selic_rate {
				   SELECT ix_selic_rate__new(:rate,:type,:date)
				}
			    } on_error {
				ns_log notice "AIGH! something bad happened! $errmsg"
				ns_log Notice "ERROR CRETING SELIC RATE *****"
			    }
			} else {
			    ns_log Notice "RATE IS VOID!"
			}       	
		    }
		} else {
		    ns_log Notice "MONTH IS VOID!"
		}
	    }
	} else {
	    ns_log Notice  "LINE IS VOID"
	}
    }
    return 0
}
