ad_page_contract {
    add files in the chat room
} {
    room_id
    return_url  
}




ad_form \
    -name file-add \
    -html { enctype multipart/form-data } \
    -form {
	file_id:key
	{upload_file:file {label "<b>\#chat.Upload_file\#</b>"} {html "size 25"}}
	{room_id:integer(hidden)
	    {value $room_id}
	}	
	{return_url:text(hidden)
	    {value $return_url}
	}
    } 


ad_form -extend -name file-add -new_data {

    set name $upload_file
    set upload_files [template::util::file::get_property filename $upload_file]
    set upload_tmpfiles [template::util::file::get_property tmp_filename $upload_file]

    set user_id [ad_conn user_id]

    foreach upload_file $upload_files tmpfile $upload_tmpfiles {
	set file_size [file size $tmpfile]
	
	set mime_type [cr_filename_to_mime_type -create -- $upload_file]
	
	if {[content::type::content_type_p -mime_type $mime_type -content_type "image"]} {
	    set content_type image
	} else {
	    set content_type file_storage_object
	}
	
	
	set item_id [content::item::new  \
			 -item_id $file_id \
			 -parent_id $room_id \
			 -creation_user $user_id \
			 -creation_ip [ad_conn peeraddr] \
			 -package_id [ad_conn package_id] \
			 -name $name \
			 -storage_type "file" \
			 -content_type "file_storage_object" \
			 -mime_type $mime_type]
	
	set revision_id [cr_import_content \
			     -item_id $item_id \
			     -storage_type "file" \
			     -creation_user $user_id \
			     -creation_ip [ad_conn peeraddr] \
			     -other_type "file_storage_object" \
			     -image_type "file_storage_object" \
			     $room_id \
			     $tmpfile \
			     $file_size \
			     $mime_type \
			     $name]
	
	content::item::set_live_revision -revision_id $revision_id
    }

    set file_url "teste"
    set moderator_p 0
    set message "<a href=\"$file_url\" target=\"_blank\">Download file</a>"
    chat_message_post $room_id $user_id $message $moderator_p

    
} -after_submit {
    ad_returnredirect [export_vars -base "close-window" {}]
    ad_script_abort
}
