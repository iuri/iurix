ad_page_contract {
    add/edit document
} {
    {folder_id ""}
    file_id:optional
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

set package_id [ad_conn package_id]
set user_id [ad_conn user_id]
set fs_package_id [documents::get_fs_package_id -package_id [ad_conn package_id]]

set language_options [lang::util::get_locale_options]

set root_folder_id [fs_get_root_folder -package_id $fs_package_id]

set folder_options [db_list_of_lists select_folders { 
    SELECT name, item_id FROM cr_items 
    WHERE content_type = 'content_folder' AND parent_id = :root_folder_id
}]

ad_form -html { enctype multipart/form-data } -name document_ae -cancel_url /documents -form {
    {file_id:key}
}



if {![exists_and_not_null file_id]} {
    ad_form -extend -name document_ae -form {
	{info1:text(inform)
	    {label ""}
	    {value "<b>[_ documents.Add_Document]</b>"}
	}
    }
} else {
    ad_form -extend -name document_ae -form {
	{info2:text(inform)
	    {label ""}
	    {value "<b>[_ documents.Edit_document]</b>"}
	}
    }
}

ad_form -extend -name document_ae -form {
    {upload_file:file {label "[_ documents.File]"}}
    {title:text(text) {label "[_ documents.Name]"}}
    {description:text(textarea),optional
        {label "[_ documents.Description]"}
	
    }
}



if {[exists_and_not_null folder_id]} {
    ad_form -extend -name document_ae -form {
	{folder_id:integer(hidden) {value $folder_id}}
    }
} else {
    ad_form -extend -name document_ae -form {
	{folder_id:integer(select)
	    {label "#documents.Type#"}
	    {options $folder_options}
	}
    }
}

db_1row select_subsite_id {
    select context_id as group_id 
    from acs_objects 
    where package_id = :package_id 
    and object_type = 'apm_package'
}

if {![info exists $group_id]} {
    set dotlrn_p [apm_package_installed_p dotlrn]
    if {$dotlrn_p} {
	#get communities and subsites
	
	db_1row select_community_id {
	    select package_id as group_id
	    from dotlrn_communities 
	    where archived_p = 'f'
	    
	}
    }
}

ns_log Notice "GROUP $group_id"

ad_form -extend -name document_ae -form {


    {language:text(select),optional 
	{label "[_ documents.Idiom]"}
	{options $language_options}
    }
    {author:text(text) {label "#documents.Author#"}}
    {coauthor:text(text),optional {label "#documents.CoAuthor#"}}
    {source:text(text),optional {label "#documents.Source#"}}
    {group_id:integer(hidden)
	{value {$group_id}}
    }
    {status:integer(select),optional
	{label {[_ documents.Status]}}
	{options {{Minuta 1} {Copia 2} {Original 3}}}
    }    
    {publish_date:date(date)
	{label "[_ documents.Publish_Date]"}
	{html {id sel1} }
	{format "YYYY MM DD"}
	{after_html {<input type="button" style="height:23px; width:23px; background: url('/resources/acs-templating/calendar.gif');" onclick ="return showCalendarWithDateWidget('publish_date', 'y-m-d');" > \[<b>[_ documents.yyyy-mm-dd]</b>\]}} 
    }
}




set category_ids [list]

ns_log Notice "[documents::get_categories -package_id $package_id]"
foreach {category_id category_name} [documents::get_categories -package_id $package_id] {
    if {[string equal $category_name "Tipo"]} {
		
	ad_form -extend -name document_ae -form [list \
	    [list "cat_${category_id}:integer(select)" \
		 [list label "${category_name}"] \
		 [list options [documents::category_get_options -parent_id $category_id]] \
		 [list value  ""]  \
		 [list html "onChange \"document.document_ae.__refreshing_p.value='1';document.document_ae.submit();\""]
	    ]]
	
	ns_log Notice "$category_id | $category_name"
	
	#if {[exists_and_not_null file_id]} {
	#    set child_id [set cat_${category_id}]
	#    ns_log Notice "BREAK CHILD $child_id"
	#} else {
	#    set cat_${category_id} ""
	#    export_url_vars [set cat_${category_id}]
	#}
	#ns_log Notice "[documents::get_subcategories -category_id $child]"
	    


	 
					 
    } else {
	ad_form -extend -name document_ae -form [list \
	    [list "cat_${category_id}:integer(select)" \
		 [list label "${category_name}"] \
		 [list options [documents::category_get_options -parent_id $category_id]] \
		 [list value  ""]  \
		]]
	
    }
} 





if {![exists_and_not_null document_id]} {
    ad_form -extend -name document_ae -form {
	{terms:text(inform)
	    {label "[_ documents.Term]"} 
	    {value " O Portal do Software Público não assume nenhuma responsabilidade pelo conteúdo dos artefatos publicados dos usuários. A responsabilidade do conteúdo das mensagens recai sobre a pessoa ou pessoas que enviaram a mensagem. A Portal do Software Público não restringe o conteúdo de mensagens a não ser que violem os termos de uso ou sejam consideradas de natureza abusiva. Reservamo-nos o direito de monitorar o conteúdo de todas as mensagens com o propósito de restringir os abusos desse serviço sem aviso prévio ou consentimento do remetente ou destinatário. Qualquer usuário que violar os termos e condições aqui listados podem ser permanentemente banidos do serviço de mensagens."}
	}
	{read_term:text(checkbox)
	    {label ""}
	    {options {{"[_ documents.Accept_Term]" "checked"}}}
	}
    }
    if {[exists_and_not_null document]} {
	ad_form -extend -name document_ae -validate {
	    {read_term
		{[string equal $read_term "checked"]} 
		"[_documents.You_must_check_read_term_box]"
	    }
	}
    }
}


ad_form -extend -name document_ae -form {
} -new_request {
    
    set read_term 0
    
} -edit_request {

    db_1row document_info { 
	select name as title, description, author, coauthor, group_id, user_id, language, source, publish_date
	from document_items
	where document_id in (select latest_revision 
			      from cr_items  
			      where item_id = :file_id)
    }

    set publish_date [documents::from_sql_datetime -sql_date $publish_date  -format "YYYY-MM-DD"]

    
} -on_submit {
    
   
} -new_data {
    
    set upload_files [list [template::util::file::get_property filename $upload_file]]
    set upload_tmpfiles [list [template::util::file::get_property tmp_filename $upload_file]]
    
    set number_upload_files [llength $upload_files]
    
    foreach upload_file $upload_files tmpfile $upload_tmpfiles {
        set this_file_id $file_id
        set this_title $title
        set mime_type [cr_filename_to_mime_type -create -- $upload_file]
        # upload a new file
        # if the user choose upload from the folder view
        # and the file with the same name already exists 
	# we create a new revision 
                                                                                                                          

        if {[string equal $this_title ""]} {
            set this_title $upload_file
        }

    
        set existing_item_id [fs::get_item_id -name $upload_file -folder_id $folder_id]
	if {![empty_string_p $existing_item_id]} {
            # file with the same name already exists in this folder  
                                                                                        
            if { [ad_parameter "BehaveLikeFilesystemP" -package_id [ad_conn package_id]] } {
                # create a new revision -- in effect, replace the existing file  
                                                                            
                set this_file_id $existing_item_id
                permission::require_permission \
                    -object_id $this_file_id \
                    -party_id $user_id \
                    -privilege write
            } else {
                # create a new file by altering the filename of the                                                                                          
                # uploaded new file (append "-1" to filename)                                                                                                
                set extension [file extension $upload_file]
                set root [string trimright $upload_file $extension]
                append new_name $root "-$this_file_id" $extension
                set upload_file $new_name
            }
        }

        set document_id [fs::add_file \
			     -name $upload_file \
			     -item_id $this_file_id \
			     -parent_id $folder_id \
			     -tmp_filename $tmpfile\
			     -creation_user $user_id \
			     -creation_ip [ad_conn peeraddr] \
			     -title $this_title \
			     -description $description \
			     -package_id [documents::get_fs_package_id -package_id $package_id] \
			     -mime_type $mime_type]
	
	
	
        file delete $tmpfile
        
    }
    file delete $upload_file.tmpfile
  

    documents::new \
	-document_id $document_id \
	-name $title \
	-description $description \
	-group_id $group_id \
	-author $author \
	-coauthor $coauthor \
	-language $language \
	-source $source \
	-publish_date $publish_date \
	-creation_user [ad_conn user_id] 
	
    
    
} -edit_data {

    ns_log Notice "UPLOAD FILE $upload_file"

    db_1row get_document_id {
	select latest_revision from cr_items  where item_id = :file_id
    }

    if {![string equal $upload_file ""]} {
	set this_title $title
	set filename [template::util::file::get_property filename $upload_file]
	if {[string equal $this_title ""]} {
	    set this_title $filename
	}
	
	fs::add_version \
	    -name $filename \
	    -tmp_filename [template::util::file::get_property tmp_filename $upload_file] \
	    -item_id $file_id \
	    -creation_user $user_id \
	    -creation_ip [ad_conn peeraddr] \
	    -title $this_title \
	    -description $description \
	    -package_id $package_id
    } else {

	db_dml edit_info {
	    update cr_revisions set 
	    title = :title,
	    description = :description
	    where revision_id = :latest_revision
	}
    }

    

    documents::edit \
	-document_id $latest_revision \
	-name $title \
	-description $description \
	-group_id $group_id \
	-author $author \
	-coauthor $coauthor \
	-language $language \
	-source $source \
	-publish_date $publish_date \
	-creation_user [ad_conn user_id] 

    


} -after_submit {
    ad_returnredirect "."
    ad_script_abort
}	
