ad_page_contract {} {
    {p ""}
    {jp ""}
    {mp ""}
    {dl ""}
    {dc ""}
    {jm ""}
    {dvm ""}
} 


ad_form -name form -html {enctype multipart/form-data} -form {    
    {inform:text(inform) {label ""}  {value "<h1>Auto de Infra&ccedil;&atilde;o Federal<h1/>"}}
    {p:text {label "Valor principal do debito/tributo - P"} {html "size 10"} {help_text "Informação disponível no Lançamento de Ofício."}}
    {jp:text {label "Juros de mora sobre principal - JP"} {html "size 10"} {help_text "Informação disponível no Lançamento de Ofício."}}    
    {mp:text {label "Multa proporcional - MP"} {help_text "Informação disponível no Lançamento de Ofício."} {html {onChange "document.form.__refreshing_p.value='1';document.form.submit()"}}}
}


set subtotal ""
if {[exists_and_not_null p] && [exists_and_not_null jp] && [exists_and_not_null mp] } {

    set subtotal [format "%.2f" [expr $p + $jp + $mp]]
    
    if { [exists_and_not_null jm]} {	
	set total [format "%.2f" [expr $p + $jp + $mp + $jm]]
	set jm [format "%.2f" $jm]	
	set current_date [lc_time_fmt [db_string select_current_date {SELECT now() FROM dual} -default ""] "%q %X" "pt_BR"]
	set dc [lc_time_fmt $dc "%q %X" "pt_BR"]
	set dl [lc_time_fmt $dl "%q %X" "pt_BR"]
	set dvm [lc_time_fmt $dvm "%q %X" "pt_BR"]       
    }

    set p [format "%.2f" $p]
    set jp [format "%.2f" $jp]
    set mp [format "%.2f" $mp]   
}


ad_form -extend -name form -form {    
    {subtotal:text,optional {label "Total"} {value $subtotal }    }
}



ad_form -extend -name form -form {    
    {dl:date
	{label "Data da Lavratura - DL"}
        {format "DD MM YYYY"}
        {after_html {<input type="button" style="height:23px; width:23px; background: url('/resources/acs-templating/calendar.gif');" id='form.date-button'> \[<b>DD-MM-AAAA</b>\]} }
    }
    {dc:date
	{label "Data da ciência - DC"}
        {format "DD MM YYYY"}
        {after_html {<input type="button" style="height:23px; width:23px; background: url('/resources/acs-templating/calendar.gif');" id='form.date-button'> \[<b>DD-MM-AAAA</b>\]} }
    }
    {inform2:text(inform) {label ""}  {value "<h4><a href=https://docs.google.com/document/d/16756by_GEZjjO4yai8IGnxAl5d5saNzT5DavytQ1zoU/edit?usp=sharing>Documenta&ccedil;&atilde;o </a></h4>"}}
} -on_submit {
    

    ns_log Notice "Imposto $p | Juros Proporc. $jp | Multa Prop. $mp | Data Ciencia $dc | Data Lavrarura$dl"
    
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
    set dvm [db_string select_date { SELECT DATE :dc + interval '32 days' FROM dual } -default ""]
    ns_log Notice "DVM $dvm "

    set dvm_day_of_week [db_string select_dat_of_week { SELECT extract(dow from timestamp :dvm) FROM dual  } -default ""]
    
    ns_log Notice "DVM Day OF WEEK $dvm_day_of_week"
    # If day_of_week is SAT, SUN or holiday* then add 1 or 2 days 
    switch $dvm_day_of_week {
	0 {
	    set dvm [db_string select_date_next_day {
		SELECT DATE :dvm + INTERVAL '1 day' FROM dual 
	    } -default ""]
	}
	6 {
	    set dvm [db_string select_date_next_two_days {
		SELECT DATE :dvm + INTERVAL '2 days' FROM dual 
	    } -default "" ]
	}	
	default {
	    #do nothing
	}	
    }
    ns_log Notice "NEW DVM $dvm"



    # gets index of mora from auxiliar table 1 - Taxa SEclic Acumulada
    # juros mora index
    # Buscar índice do mês do vencimento na tabela “Taxa de Juros Selic Acumulada Mensalmente”
    # http://receita.economia.gov.br/orientacao/tributaria/pagamentos-e-parcelamentos/taxa-de-juros-selic#Selicmensalmente
    #  Ex set i "1.29"

    set i [ix_selic::rates::get_rate -date $dvm -type 1]
    ns_log Notice "RATE SIMPLES $i ******"
    set jm [expr [expr $mp * $i] / 100]
    ns_log Notice "JM = $mp * $i / 100 = $jm"
    




    
    # 2. Juros de mora sobre principal - Complemento - JP-C
    # Determinar mês da lavratura - ML do Lançamento de Ofício, a partir da DL (Campo D). Exemplo: Se DL é 04.dez.2019, o mês da lavratura é “dezembro/2019”.

    #set pivot_month_lavratura [db_string select_month_lavr { SELECT extract(month FROM timestamp :dl) FROM dual  } -default ""]
    #set pivot_year_lavratura [db_string select_year_lavr { SELECT extract(year FROM timestamp :dl) FROM dual  } -default ""]
    #ns_log Notice "PIVOT MONTH LAVRATURA $pivot_month_lavratura"
    #set date_lavr "$month_names($pivot_month_lavratura)-$pivot_year_lavratura"
    #ns_log Notice "DATE LAVR $date_lavr"

    # Buscar no site da RFB abaixo a tabela “Taxa de Juros Selic”
    # http://receita.economia.gov.br/orientacao/tributaria/pagamentos-e-parcelamentos/taxa-de-juros-selic#Selic
    
    # index_mora_compl
    set j [ix_selic::rates::get_acumulated_rate -date $dl -type 0]
    #set j [expr 0.37 + 0.38 + 0.29]
    ns_log Notice "INDEX ACUMULADO ***** $j"
    set jp [expr $jp + [expr [expr $p * $j] / 100] ]
    ns_log Notice "JP = $p * $j / 100 = $jp"


#    acs_mail_lite::
    
    
} -after_submit {
    
    ad_returnredirect [export_vars -base autodeinfracaofederal {value p jp mp jm dvm dc dl}]
    ad_script_abort
    
}

    
    
