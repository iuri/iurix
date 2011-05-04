# /packages/photo-album/www/photo-add.tcl

ad_page_contract {

    Upload a photo to an existing album

    @author Tom Baginski (bags@arsdigita.com)
    @creation-date 12/10/2000
    @cvs-id $Id: photo-add.tcl,v 1.6.6.1 2007/06/14 09:12:49 emmar Exp $
} {
    album_id:integer,notnull
    photo_id:integer,notnull,optional
    upload_file:notnull,trim,optional
    upload_file.tmpfile:tmpfile,optional
} -validate {
    valid_album -requires {album_id:integer} {
	if [string equal [pa_is_album_p $album_id] "f"] {
	    ad_complain "[_ photo-album._The_4]"
	}
    }
    valid_mime_type {
	if { ![parameter::get -parameter ConverttoJpgorPng -package_id [ad_conn package_id] -default 1] } {
	    if { [catch {set photo_info [pa_file_info ${upload_file.tmpfile}]}  errMsg] } { 
		ns_log Warning "Error parsing file data Error: $errMsg" 
		ad_complain "error" 
	    } 
	    
	    foreach {base_bytes base_width base_height base_type base_mime base_colors base_quantum base_sha256} $photo_info { break } 
	    
	    if [empty_string_p $base_mime] { 
		set base_mime invalid 
	    }   
	    
	    if ![regexp  $base_mime [parameter::get -parameter AcceptableUploadMIMETypes -package_id [ad_conn package_id]]] { 
		ad_complain "[_ photo-album._The_5]" 
		ad_complain "[_ photo-album._The_6]" 
	    } 
	} 
    }
    valid_photo_id -requires {photo_id:integer} {
	# supplied photo_id must not already exist
	if {[db_string check_photo_id {}]} {
	    ad_complain "The photo already exists.  Check if it is already in the <a href=\"album?album_id=$album_id\">album</a>."
	}       
    }
} -properties {
    album_id:onevalue
    context_list:onevalue
}

set package_id [ad_conn package_id]

# check for read permission on folder
ad_require_permission $album_id pa_create_photo

set context_list [pa_context_bar_list -final "[_ photo-album._Upload]" $album_id]

#set photo_id [db_string get_next_object_id "select acs_object_id_seq.nextval from dual"]

set group_options [photo_album::get_group_options]

set return_url [export_vars -base "album" {album_id}]

ad_form -name photo_upload -action photo-new -html {enctype multipart/form-data} -cancel_url $return_url -form {
    {photo_id:key}
    {album_id:integer(hidden)
	{value $album_id}
    }
    {upload_file:file
	{label "[_ photo-album._Choose_2]"}
	{help_text "[_ photo-album._Use]"}
    } 
    {title:text(text)
	{label "[_ photo-album.Title]"}
	{help_text "[_ photo-album.Help_Title]"}
    }
    {description:text(textarea)
	{html { cols 50 rows 5}}
	{label "[_ photo-album._Photo]"} 
	{help_text "[_ photo-album.lt_OPTIONAL_Displayed_wh]"}
    }
}


set category_ids [list]
foreach {category_id category_name} [photo_album::get_categories -package_id [ad_conn package_id]] {
    ad_form -extend -name photo_upload -form [list \
	[list "cat_${category_id}:integer(select)" \
	     [list label "${category_name}"] \
	     [list options [photo_album::category_get_options -parent_id $category_id]] \
	     [list value   ""] \
	] \
    ]
}



ad_form -extend -name photo_upload -form {
    {group_id:integer(select),optional
	{label "[_ photo-album.Group]"} 
	{help_text "[_ photo-album.lt_OPTIONAL_Displayed_group]"}
	{options $group_options}
    }
    {photographer:text(text),optional
	{label "[_ photo-album.Author]"}
	{help_text "[_ photo-album.Help_Author]"}
	{html {size 30}}	    
    }
    {date:date(date),optional
	{label "[_ photo-album.Date]"}
        {html {id sel1} }
        {format "YYYY MM DD"}
        {after_html {<input type="button" style="height:23px; width:23px; background: url('/resources/acs-templating/calendar.gif');" onclick ="return showCalendarWithDateWidget('date', 'yyyy-mm-dd');" > \[<b>[_ photo-album.y-m-d]</b>\]}}
    }
    {tags:text(text),optional
	{label "[_ photo-album.Tags]"} 
	{help_text "[_ photo-album.lt_OPTIONAL_Displayed_tags]"}
	{html { size 60 }}
    }
    
    {terms:text(inform)
	{label "[_ photos.Terms]"} 
	{value "O Portal do Software Público não assume nenhuma responsabilidade pelo conteúdo dos artefatos publicados dos usuários. A responsabilidade do conteúdo das mensagens recai sobre a pessoa ou pessoas que enviaram a mensagem. A Portal do Software Público não restringe o conteúdo de mensagens a não ser que violem os termos de uso ou sejam consideradas de natureza abusiva. Reservamo-nos o direito de monitorar o conteúdo de todas as mensagens com o propósito de restringir os abusos desse serviço sem aviso prévio ou consentimento do remetente ou destinatário. Qualquer usuário que violar os termos e condições aqui listados podem ser permanentemente banidos do serviço de mensagens."}
    }
    {read_term:text(checkbox)
	{label ""}
	{options {{"[_ photo-album.Accept_Term]" "checked"}}}
    }
    
} -validate {
    {read_term
	{[string equal $read_term "checked"]}
	"#photos.You_must_check_read_term_box#"
    }
    
} -new_request {
	
    set read_term 0

} -on_submit {


} -new_data {

    db_transaction {
	#check permission
	ad_require_permission $album_id "pa_create_photo"
	
	set user_id [ad_conn user_id]

	set new_photo_ids [pa_load_images \
			       -remove 1 \
			       -client_name $upload_file \
			       -description $description \
			       -group_id $group_id \
			       -photographer $photographer \
			       -story $description \
			       -caption $title \
			       -date $date \
			       -tags $tags \
			       ${upload_file.tmpfile} $album_id $user_id]
	
	pa_flush_photo_in_album_cache $album_id
	
	
	# page used as part of redirect so user returns to the album page containing the newly uploaded photo
	set page [pa_page_of_photo_in_album [lindex $new_photo_ids 0] $album_id]
		
	foreach {category_id category_name} [photo_album::get_categories -package_id $package_id] {
	    category::map_object -remove_old -object_id $new_photo_ids ""
	}
	foreach {category_id category_name} [photo_album::get_categories -package_id $package_id] {
	    set child_id  [set cat_${category_id}]
	    category::map_object -object_id $new_photo_ids $child_id
	    
	}
    }

} -after_submit {
    ad_returnredirect $return_url

}


