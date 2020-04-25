ad_page_contract {} {
    form_id:integer,optional
    {__refreshing_p "0"}
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



# template::head::add_css -href "/resources/calendar/calendar.css" -media all
# template::head::add_css -alternate -href "/resources/calendar/calendar-hc.css" -title "highContrast"
template::add_event_listener -id form.date-button1 -script {showCalendarWithDateWidget('dl', 'y-m-d');}
template::add_event_listener -id form.date-button2 -script {showCalendarWithDateWidget('dc', 'y-m-d');}



set acm_rate 0
template::multirow create rates abrev_date rate acm_rate applied_rate
db_foreach select_rates {
    SELECT rate_id, rate, date, EXTRACT(MONTH FROM date) AS month, EXTRACT(YEAR FROM date) AS year
    FROM ix_selic_rates
    WHERE type = '0'
    ORDER BY date ASC
} { 

    set abrev_date "$month-$year"

    set acm_rate [format "%.2f" [expr $acm_rate + $rate]]
    set applied_rate [db_string select_acm_rate {
	SELECT rate FROM ix_selic_rates WHERE type = '1' AND date = :date
    } -default ""]

    template::multirow append rates $abrev_date $rate $acm_rate $applied_rate  


    
}





 
ad_form -name form -html {enctype multipart/form-data} -form {
    {form_id:key}
    {inform:text(inform) {label ""}  {value "<h1>Auto de Infra&ccedil;&atilde;o Federal<h1/>"}}
    {inform2:text(inform) {label ""}  {value "<h2>Datas</h2>"}}
    {dl:date
	{label "Data da Lavratura (DL)"}
        {format "DD MM YYYY"}
        {after_html {<input type="button" style="height:23px; width:23px; background: url('/resources/acs-templating/calendar.gif');" id='form.date-button1'> \[<b>DD-MM-AAAA</b>\]} }
    }
    {dc:date
	{label "Data da ciência (DC)"}
        {format "DD MM YYYY"}
        {after_html {<input type="button" style="height:23px; width:23px; background: url('/resources/acs-templating/calendar.gif');" id="form.date-button2" onBlur="document.form.__refreshing_p.value='1';document.form.submit()"> \[<b>DD-MM-AAAA</b>\]} }
       
    }
    {dv:date
	{label "Data de Vencimento (DV)"}
	{mode display}
        {format "DD MM YYYY"}
    }

}


ad_form -extend -name form -form {    
    {inform3:text(inform) {label ""}  {value "<h2>C&aacute;lculo</h2>"}}
    {p:text {label "Principal (P)"} {html "size 10"} {help_text "Valor principal do d&eacute;bito"}}
    {j:text {label "Juros (J)"} {html "size 10"} {help_text ""}}
    {m:text {label "Multa (M)"} {html {onChange "document.form.__refreshing_p.value='1';document.form.submit()"}} {help_text ""}}
}



ad_form -extend -name form -form {
    {jp:text {label "Juros de mora sobre principal (JP)"} {html "size 10"} {help_text ""}}    
    {jm:text {label "Juros de mora sobre multa (JM)"} {html "size 10"} {help_text ""}}
    {total:text {label "Total"} {html "size 10"} {help_text ""}}
}




ad_form -extend -name form -form {    
    {inform4:text(inform) {label ""}  {value "<a href=https://docs.google.com/document/d/16756by_GEZjjO4yai8IGnxAl5d5saNzT5DavytQ1zoU/edit?usp=sharing><b>Termos & Documenta&ccedil;&atilde;o</b> </a>"}}


} -on_submit {
    
    ns_log Notice "Imposto $p | Juros $j | Multa $m | Juros sobre Principal $jp | Juros sobre Multa $jm | Data Ciencia $dc | Data Lavrarura $dl | Data Vencimento $dv | "

    if {$p ne "" && $m ne ""} {
 	set p [string map {"." ""} $p]
	set m [string map {"." ""}  $m]
	set j [string map {"." ""} $j]
	set jp [string map {"." ""} $jp]
	set jm [string map {"." ""} $jm]
	
	set p [string map {"," "."} $p]
	set m [string map {"," "."} $m]
	set j [string map {"," "."} $j]
	set jp [string map {"," "."} $jp]
	set jm [string map {"," "."} $jm]
	
	
	set dv [calendar::to_sql_datetime -date $dv -time "00:00:00" -time_p 0]
	set i [ix_selic::rates::get_rate -date $dv -type 1]
	ns_log Notice "RATE SIMPLES $i ******"
	ns_log Notice "\n MATH $jp * $i \n"
	
	set result [expr [expr $jp * $i] / 100]
	ns_log Notice "RESULT = $jp * $i / 100  = $result"
	
	
	
    }

     
} -after_submit {
    
    ad_returnredirect [export_vars -base autodeinfracaofederal {value p jp mp jm dv dc dl}]
    ad_script_abort

} -on_refresh {
    ns_log Notice "Imposto $p | Juros $j | Multa $m | Data Ciencia $dc | Data Lavrarura $dl"
    
    set dc [calendar::to_sql_datetime -date $dc -time "00:00:00" -time_p 0]
    set dl [calendar::to_sql_datetime -date $dl -time "00:00:00" -time_p 0]

    ns_log Notice "DATA CIENCIA $dc"
    ns_log Notice "DATA LAVRATURA $dl"
    
    
    set dc_day_of_week [db_string select_dat_of_week { SELECT extract(dow from timestamp :dc) FROM dual  } -default ""]    	
    ns_log Notice "DAY OF WEEK $dc_day_of_week"
    # Case dc_day_of_week is sat or sun then add 2 or 1 day to dc 
    switch $dc_day_of_week {
	0 {
	    set dc [db_string select_date_next_day {
		SELECT DATE :dc + INTERVAL '1 day' FROM dual 
	    } -default ""]
	}
	6 {
	    set dc [db_string select_date_next_two_days {
		SELECT DATE :dc + INTERVAL '2 days' FROM dual 
	    } -default "" ]
	}
	default {
	    #do nothing
	}	
    }
    ns_log Notice "NEW DATA CIENCIA $dc"
    
    # 1. Juros de mora sobre a multa - JM
    set dv [db_string select_date { SELECT DATE :dc + interval '32 days' FROM dual } -default ""]
    ns_log Notice "DVM $dv"

    set dv_day_of_week [db_string select_dat_of_week { SELECT extract(dow from timestamp :dv) FROM dual  } -default ""]
    
    ns_log Notice "DVM Day OF WEEK $dv_day_of_week"
    # If day_of_week is SAT, SUN or holiday* then add 1 or 2 days 
    switch $dv_day_of_week {
	0 {
	    set dv [db_string select_date_next_day {
		SELECT DATE :dv + INTERVAL '1 day' FROM dual 
	    } -default ""]
	}
	6 {
	    set dv [db_string select_date_next_two_days {
		SELECT DATE :dv + INTERVAL '2 days' FROM dual 
	    } -default "" ]
	}	
	default {
	    #do nothing
	}	
    }
    ns_log Notice "NEW DVM $dv"

    set dv [calendar::from_sql_datetime -sql_date $dv  -format "YYY-MM-DD"]
    ns_log Notice "DV2 $dv"

    template::element set_value form dv $dv

    set monthly_rate [db_string select_monthly_rate {
	SELECT rate FROM ix_selic_rates
	WHERE EXTRACT(month FROM date) = EXTRACT(month FROM :dl::timestamp)	
	AND EXTRACT(year FROM date) = EXTRACT(year FROM :dl::timestamp)
	AND type = '0' 
	
    } -default ""]
    
    set applied_rate [db_string select_applied_rate {
	SELECT rate FROM ix_selic_rates
        WHERE EXTRACT(month FROM date) = EXTRACT(month FROM :dl::timestamp)	
	AND EXTRACT(year FROM date) = EXTRACT(year FROM :dl::timestamp)
	AND type = '1' 
    } -default ""]

    ns_log notice "RATES $monthly_rate | $applied_rate"

    if {$p ne "" && $m ne ""} {
	set p [string map {"." ""} $p]
	set m [string map {"." ""}  $m]
	set j [string map {"." ""} $j]
	
	set p [string map {"," "."} $p]
	set m [string map {"," "."} $m]
	set j [string map {"," "."} $j]
	
	set jp [format "%.2f" [expr [expr [expr $applied_rate + $monthly_rate - 1] * $p] / 100]]
	set jm [format "%.2f" [expr [expr $applied_rate * $m] / 100]]
	ns_log Notice "Juros princ $jp | Juros multa $jm"     

	set total [format "%.2f" [expr $p + $j + $m + $jp + $jm]]
	template::element set_value form jp $jp
	template::element set_value form jm $jm
	template::element set_value form total $total
    }

}



# <!-- Latest compiled and minified CSS -->
template::head::add_css -href "https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css"

# <!-- jQuery library -->
template::head::add_javascript -src "https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js" -order 1

# <!-- Latest compiled JavaScript -->
template::head::add_javascript -src "https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js" -order 2
    
template::head::add_javascript -src "/resources/jquery.mask.min.js" -order 2
