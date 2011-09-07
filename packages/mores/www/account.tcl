ad_page_contract {
  
  @author Breno Assunção (assuncao.b@gmail.com)
  @creation-date 2010-08-23

} {
	account_id
	{query_id_p ""}
	{source_p ""}
	{lang_p:optional}
}

if {![exists_and_not_null lang_p]} {
	if {$account_id == 1935} {
		set lang_p "es"
	} else {
		set lang_p "todas"
	}
} else {

}

set export_vars "account_id=$account_id&sentimento=0"

if {$source_p == "" } {
	set sql_source ""
	set sql_query_id2 ""
} else {
	set sql_source " and source = '$source_p'"
	append export_vars "&source_p=$source_p"
}

if {$lang_p == "todas" } {
	set sql_lang ""
} else {
	set sql_lang " and substr(lang,1,2) = '$lang_p'"
	append export_vars "&lang_p=$lang_p"
}



if {$query_id_p == "" } {
	set sql_query_id ""
	set sql_query_id2 ""
	db_multirow redes select_redes "SELECT source,  sum (qtd) as qtd
		  FROM mores_stat_source
		  where account_id = :account_id $sql_source $sql_lang
		  group by source
		  order by qtd desc
  	 " {
	}

} else {
	set sql_query_id " and query_id = $query_id_p"
	set sql_query_id2 " and maq.query_id = $query_id_p"
	db_multirow redes select_redes "SELECT source,  sum (qtd) as qtd
		  FROM mores_stat_source_query
		  where account_id = :account_id and query_id = :query_id_p $sql_source $sql_lang
  		  group by source
		  order by qtd desc
  	" {
	}
	append export_vars "&query_id_p=$query_id_p"
}
set package_id [ad_conn package_id]
set user_id [ad_conn user_id]

permission::require_permission -party_id $user_id -object_id [ad_conn package_id] -privilege read
permission::require_permission -party_id $user_id  -object_id $account_id -privilege write
set admin_p [permission::permission_p -party_id $user_id  -object_id $account_id -privilege admin]
set admin_geral [permission::permission_p -party_id $user_id  -object_id [ad_conn package_id] -privilege admin]
set write_p [permission::permission_p -party_id $user_id  -object_id $account_id -privilege write]
set action_list ""

set account_name [db_string select_name {select name from mores_accounts where account_id = :account_id}]


set values ""
set values2 ""
set chart_js ""
set max_qtd 0

set cont_date 0
set  days ""
set current_query 0
set cont_query 0



set xml 	""
set xml_dados 	""
set xml_date 	""


db_foreach select_grafico "	select tabela.query_id, query_text, tabela.date, dia, COALESCE(msg2.qtd,0) as qtd 
		from (SELECT distinct maq.query_id, query_text, date, data as dia  
			FROM mores_stat_graph msg, mores_acc_query maq
			WHERE maq.account_id = :account_id and msg.account_id = maq.account_id and tipo = 'dia' $sql_query_id2) as tabela
		left join (select query_id, sum(qtd) as qtd, date 
				from mores_stat_graph WHERE account_id = :account_id $sql_source $sql_query_id $sql_lang and tipo = 'dia'
		group by query_id, date) msg2 on msg2.query_id = tabela.query_id AND msg2.date = tabela.date  
		order by tabela.query_id ,tabela.query_text, date    
	" {
  		if {$current_query != $query_id} {
  			if {$cont_query > 0} {
  				  append xml_dados "</graph>"  			
  			}
  			regsub -all {\'} $query_text {} query_text	 
  			append xml_dados "<graph gid='$cont_query' title='$query_text'>"
  			set current_query $query_id
			incr cont_query
  		}
  		if {$cont_query == 1} {
		  	set idx_date($dia) $cont_date
		  	append xml_date "<value xid='$cont_date'>$dia</value>"
		  	incr cont_date
	  	}
  		append xml_dados "<value xid='$idx_date($dia)'>$qtd</value>"
  }

set xml 	"<chart><series>$xml_date</series><graphs>$xml_dados</graph></graphs></chart>"

set xml2 ""
set xml_dados2	""
set xml_date2 	""
set cont_date2 0
set current_query 0
set cont_query 0

db_foreach select_grafico2 " select base.query_id, query_text, hora as hour, COALESCE(msg3.qtd,0) as qtd 
					  from (select hora,query_id, query_text from    (SELECT distinct data as hora FROM mores_stat_graph msg
						WHERE msg.tipo = 'hora')as tabela1, 
						mores_acc_query maq
						WHERE maq.account_id = :account_id $sql_query_id2
					   ) as base
					left join (select query_id, sum(qtd) as qtd, data 
						from mores_stat_graph  where account_id = :account_id $sql_query_id $sql_source $sql_lang and tipo = 'hora'
						group by query_id, data) msg3 on msg3.query_id = base.query_id AND msg3.data = base.hora
						order by query_id, query_text, hora
	" {
  		if {$current_query != $query_id} {
  			if {$cont_query > 0} {
  				  append xml_dados2 "</graph>"  			
  			}
  			regsub -all {\'} $query_text {} query_text	 
  			append xml_dados2 "<graph gid='$cont_query' title='$query_text'>"
  			set current_query $query_id
			incr cont_query
  		}
  		if {$cont_query == 1} {
		  	set idx_date2($hour) $cont_date2
		  	append xml_date2 "<value xid='$cont_date2'>$hour</value>"
		  	incr cont_date2
	  	}
  		append xml_dados2 "<value xid='$idx_date2($hour)'>$qtd</value>"
  }

set xml2 	"<chart><series>$xml_date2</series><graphs>$xml_dados2</graph></graphs></chart>"

set xml3 	""
set xml_dados3	""
set xml_date3 	""
set cont_date3 0
set current_query 0
set cont_query 0

db_foreach select_grafico3 "select base.query_id, query_text, hora  as hour, COALESCE(msg3.qtd,0) as qtd 
					  from (select hora,query_id, query_text from    (SELECT distinct data as hora FROM mores_stat_graph msg
						WHERE msg.tipo = 'hora')as tabela1, 
						mores_acc_query maq
						WHERE maq.account_id = :account_id $sql_query_id2
					   ) as base
					left join (select query_id, sum(qtd) as qtd, data 
						from mores_stat_graph  where account_id = :account_id $sql_query_id $sql_source $sql_lang
								and tipo = 'hora' and date = now()
						group by query_id, data) msg3 on msg3.query_id = base.query_id AND msg3.data = base.hora
						order by query_id, query_text, hora
	" {
  		if {$current_query != $query_id} {
  			if {$cont_query > 0} {
  				  append xml_dados3 "</graph>"  			
  			}
  			regsub -all {\'} $query_text {} query_text	 
  			append xml_dados3 "<graph gid='$cont_query' title='$query_text'>"
  			set current_query $query_id
			incr cont_query
  		}
  		if {$cont_query == 1} {
		  	set idx_date3($hour) $cont_date3
		  	append xml_date3 "<value xid='$cont_date3'>$hour</value>"
		  	incr cont_date3
	  	}
  		append xml_dados3 "<value xid='$idx_date3($hour)'>$qtd</value>"
  }

set xml3 	"<chart><series>$xml_date3</series><graphs>$xml_dados3</graph></graphs></chart>"

db_multirow  -extend {clear_query} querys   select_account "
	SELECT maq.query_id,maq.query_text, COALESCE(qtd,0) as qtd
	  FROM mores_acc_query maq
	  left join (select query_id, sum(qtd) as qtd
	  	from mores_stat_source_query mssq
	  	where 1 = 1 $sql_query_id $sql_source $sql_lang
	  	group by query_id) as dt on ( dt.query_id = maq.query_id)
	WHERE  maq.account_id =:account_id   $sql_query_id2
	--group by maq.query_id, maq.query_text
	order by 3 desc 
	" {
		regsub -all {\#} $query_text {} clear_query
	}



db_multirow users select_users "SELECT user_id as user_name, sum(qtd) as qtd
  FROM mores_stat_twt_usr
  where account_id = :account_id $sql_query_id $sql_lang
  group by user_id
  order by 2 desc
  limit 300;" {
}

set total_sent 0
set sent(1) 0
set sent(2) 0
set sent(3) 0
set sent(4) 0

db_foreach feeling "
  SELECT feeling, count(*) as qtd
  FROM mores_feeling mi, mores_acc_query maq 
  WHERE maq.account_id = :account_id and  maq.query_id = mi.query_id and feeling <> 0 $sql_query_id2 $sql_source $sql_lang
  GROUP BY feeling;
" {
    set total_sent [expr $total_sent + $qtd]
    set sent($feeling) [expr $qtd *1.0]
}


set xml_pizza "<pie>  <slice title=\"Positivo\" pull_out=\"true\">$sent(1)</slice> <slice title=\"Neutro\">$sent(2)</slice>  <slice title=\"Negativo\">$sent(3)</slice>  <slice title=\"Divulgação\">$sent(4)</slice></pie>"


set qtd_total [db_string select_name "SELECT sum(qtd)  FROM mores_stat_source_query  where account_id = :account_id $sql_source $sql_query_id $sql_lang;" -default "0"]




set max_date [db_string select_name "SELECT  to_char(max(date), 'DD/MM/YYYY') FROM mores_stat_graph msg, mores_acc_query maq
	WHERE msg.query_id = maq.query_id and tipo = 'dia' and maq.account_id =:account_id $sql_lang" -default ""]

set min_date [db_string select_name "SELECT  to_char(min(date), 'DD/MM/YYYY') FROM mores_stat_graph msg, mores_acc_query maq
	WHERE msg.query_id = maq.query_id and tipo = 'dia' and maq.account_id =:account_id $sql_lang" -default ""]
		


set updated_at [db_string select_name "SELECT  max(updated_at) FROM mores_stat_graph msg, mores_acc_query maq
	WHERE msg.query_id = maq.query_id and tipo = 'dia' and maq.account_id =:account_id " -default ""]

set h [lc_time_system_to_conn $updated_at]

set updated_at [lc_time_fmt $h "%D %H:%M" ]



append script "jQuery('#link_hoje').click(function(){
				jQuery('#chart_hoje').show(1000);
				jQuery('#chart_hoje').fadeIn(1000);

				jQuery('#chart_hora').hide(1000);
				jQuery('#chart_dia').hide(1000);
				
				jQuery('#link_hoje').addClass(\"selecionado\");

				jQuery('#link_dia').removeClass(\"selecionado\");
				jQuery('#link_hora').removeClass(\"selecionado\");

			});\n"



append script "jQuery('#link_hora').click(function(){
				jQuery('#chart_hora').show(1000);
				jQuery('#chart_hora').fadeIn(1000);

 				jQuery('#chart_hoje').hide(1000);
				jQuery('#chart_dia').hide(1000);
				
				jQuery('#link_hora').addClass(\"selecionado\");

				jQuery('#link_dia').removeClass(\"selecionado\");
				jQuery('#link_hoje').removeClass(\"selecionado\");
			});\n"

append script "jQuery('#link_dia').click(function(){
				jQuery('#chart_dia').show(1000);
				jQuery('#chart_dia').fadeIn(1000);

 				jQuery('#chart_hora').hide();
				jQuery('#chart_hoje').hide(1000);

				jQuery('#link_dia').addClass(\"selecionado\");

				jQuery('#link_hoje').removeClass(\"selecionado\");
				jQuery('#link_hora').removeClass(\"selecionado\");
			});\n"

set jquery_ready "
 jQuery(document).ready(function() { 
	$script

	jQuery('#user').load('tag_data?account_id=$account_id');
   });
"

#SELECT substr(lang,1,2) as lang, count(*) as qtd
#  FROM mores_items3 mi, mores_acc_query maq, acs_objects o
#  where maq.query_id = mi.query_id and maq.account_id = :account_id  AND maq.account_id = o.object_id
# 		 and created_at > (o.creation_date -interval '10 days') $sql_source $sql_query_id2
# 		 and user_nick not in (select user_nick from mores_user_block mub where mub.query_id = mi.query_id and mub.source= mi.source)
#	group by substr(lang,1,2)
#	order by 1


db_multirow langs select_langs "
	SELECT substr(lang,1,2) as lang, sum(qtd) as qtd
	FROM mores_stat_source_query mi, mores_acc_query maq
	WHERE maq.query_id = mi.query_id and maq.account_id = :account_id $sql_source $sql_query_id2 		 
	GROUP BY substr(lang,1,2)
	ORDER BY 1
" {
	if {$lang == ""} {
		set lang "N. Def."
	}
}



template::head::add_javascript -script $jquery_ready -order 5
template::head::add_javascript -src "/resources/mores/js/jquery-1.2.3.min.js" -order 1

set css ""


if {$account_id == 1189} {
	set css "/resources/mores/layouts/sebrae/css/css.css"
	template::head::add_css -href "/resources/mores/layouts/sebrae/css/css.css"
}

if {$account_id == 1284} {
	set css "/resources/mores/layouts/jp/css/css.css"
	template::head::add_css -href "/resources/mores/layouts/jp/css/css.css"
}

if {$account_id == 1935} {
	set css "/resources/mores/layouts/ollanta/css/css.css"
	template::head::add_css -href "/resources/mores/layouts/ollanta/css/css.css"
}

if {$css == ""} {
	template::head::add_css -href "/resources/mores/layouts/css.css"
}

set extra_css ""
set extra_css [parameter::get -parameter "aditional_css" -package_id $package_id]
