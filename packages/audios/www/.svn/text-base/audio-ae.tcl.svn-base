ad_page_contract {

    Creating a new Audio Item
    
    @author Iuri Sampaio (iuri.sampaio@gmail.com)
    @date 2010-11-23
} {
    {audio_id:optional}
    {return_url ""}

} -validate {
    max_size -requires {upload_file} {
	set n_bytes [file size ${upload_file.tmpfile}]
	set max_bytes [ad_parameter "MaximumFileSize"]
	if {$n_bytes > $max_bytes} {
	    ad_complain "Your file is larger than the maximum file size allowed on this system ([util_commify_number $max_bytes] bytes.)"
	}
    }
}


if {![exists_and_not_null audio_id]} {
    set ad_form_mode add
} else {
    set ad_form_mode edit
}

ad_form -name audio_ae -cancel_url $return_url -html { enctype multipart/form-data } -form {
    {audio_id:key}
    {upload_file:file
	{label "[_ audios.File]"}
	{html "size 30"}
    }
    {name:text(text)
	{label "[_ audios.Name]"}
    }
    {description:text(textarea),optional
	{label "[_ audios.Description]"}
	{html {cols 50 rows 10}}
    }
    {date:date,optional
	{label "[_ audios.Data]"}
	{format "YYYY MM DD"}
        {after_html {<input type="button" style="height:23px; width:23px; background: url('/resources/acs-templating/calendar.gif');" onclick ="return showCalendarWithDateWidget('date', 'y-m-d');" > \[<b>[_ audios.y-m-d]</b>\]}}
    }
    {author:text(text),optional
	{label "[_ audios.Author]"}
    }     
    {coauthor:text(text),optional
	{label "[_ audios.coAuthor]"}
    }	
    {source:text(text),optional
	{label "[_ audios.Source]"}
    }	
    {group_id:integer(select),optional
	{label "[_ audios.Groups]"}
	{options [audios::get_group_options]}
    }
    {tags:text(text),optional {
	{label "[_ audios.Tags]"}
	{html size 60}
	{help_text "[_ audios.Use_spaces]"}
    }}
    {terms:text(inform)
	{label "[_ audios.Term]"}
	{value " O Portal do Software Público não assume nenhuma responsabilidade pelo conteúdo dos artefatos publicados dos usuários. A responsabilidad\
e do conteúdo das mensagens recai sobre a pessoa ou pessoas que enviaram a mensagem. A Portal do Software Público não restringe o conteúdo de mensagens a não ser que violem os termos de uso ou sejam consideradas de natureza abusiva. Reservamo-nos o direito de monitorar o conteúdo de todas as mensagens com o propósito de restringir os abusos desse serviço sem aviso prévio ou consentimento do remetente ou destinatário. Qualquer usuário que violar os termos e condições aqui listados podem ser permanentemente banidos do serviço de mensagens."}
    }
    {read_term:text(checkbox)
	{label ""}
	{options {{"[_ audios.Accept_Term]" "checked"}}}
    }
}


if {[exists_and_not_null upload_file]} {
    ad_form -extend -name audio_ae  -validate {
	#    {upload_file                                                                                                                                          
	#       {[string equal [lindex [split [template::util::file::get_property mime_type $upload_file] "/"] 0] "audio"]}                                        
        #       "#audios.This_file_isnt_audio_file#"                                                                                                         
	#    }                                                                                                                                               
	{read_term
	    {[string equal $read_term "checked"]}
	    "#audios.You_must_check_read_term_box#"
	}
    }
}




ad_form -extend -name audio_ae -on_submit {

} -edit_request {

    db_1row select_audio { 
	SELECT audio_name as name, 
	audio_description as description, 
	audio_date as date, 
	author,
	coauthor,
	group_id,
	source
	FROM
	audios
	WHERE audio_id = :audio_id 
    } 
    set date [audios::from_sql_datetime -sql_date $date -format "YYYY-MM-DD"]

} -edit_data {

    
    ns_log Notice "Audio New Data"
    ns_log Notice "$name \n $description \n $date \n $author \n $coauthor \n $source \n $group_id "

    set tmp_filename [template::util::file::get_property tmp_filename $upload_file]
    set filename [template::util::file::get_property filename $upload_file]
    
    ns_log Notice "$tmp_filename | $filename"
    set date "[lindex $date 0]-[lindex $date 1]-[lindex $date 2]"
   

    
    db_transaction {
	
	
	set audio_id [audios::edit \
			  -filename $filename \
			  -tmp_filename $tmp_filename \
			  -item_id $audio_id \
			  -name $name \
			  -description $description \
			  -date $date \
			  -group_id $group_id \
			  -author $author \
			  -coauthor $coauthor \
			  -source $source]

    }

} -new_data {
    
    ns_log Notice "Audio New Data"
    ns_log Notice "$name \n $description \n $date \n $author \n $coauthor \n $source \n $group_id "

    set tmp_filename [template::util::file::get_property tmp_filename $upload_file]
    set filename [template::util::file::get_property filename $upload_file]
    
    ns_log Notice "$tmp_filename | $filename"
    set date "[lindex $date 0]-[lindex $date 1]-[lindex $date 2]"
   

    
    db_transaction {
	
	
	set audio_id [audios::new \
			  -filename $filename \
			  -tmp_filename $tmp_filename \
			  -name $name \
			  -description $description \
			  -date $date \
			  -group_id $group_id \
			  -author $author \
			  -coauthor $coauthor \
			  -source $source]

    }
} -after_submit {
    
    ad_returnredirect $return_url
    ad_script_abort

}