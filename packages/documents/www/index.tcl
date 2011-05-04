ad_page_contract {

    @author iuri sampaio (iuri.sampaio@gmail.com)
    @date 2010-10-29
} {
    {folder_id:optional}
}

set admin_p [permission::permission_p -party_id [ad_conn user_id] -object_id [ad_conn package_id] -privilege admin]

set package_id [ad_conn package_id]

set fs_package_id [documents::get_fs_package_id -package_id $package_id]

set base_url [site_node::get_url_from_object_id -object_id $fs_package_id]

set root_folder_id [fs_get_root_folder -package_id $fs_package_id]

db_multirow -extend {type_url} document_types select_folders {} {
    set type_url [export_vars -base "index" {{folder_id $item_id} return_url}]
    
}

set folder_p 0
if {[info exists folder_id]} {
    set folder_p 1

    set folder_title [db_string select_folder_title { 
	SELECT title FROM acs_objects WHERE object_id = :folder_id 
    }]

    db_multirow -extend {item_url image_url} folder_content select_folder_content {} {
	set item_url [export_vars -base "${base_url}index" {folder_id}]

	set image_url "/resources/documents/"
	switch $mime_type {
	    {application/msword} -
	    {application/vnd.ms-word} {
		append image_url "msword.png"
	    }
	    {application/msexcel} -
	    {application/vnd.ms-excel} {
		append image_url "msexcel.png"
	    }
	    {application/mspowerpoint} -
	    {application/vnd.ms-powerpoint} {
		append image_url "msppt.png"
	    }
	    {application/pdf} {
		append image_url "pdf.png"
	    }
	    {text/html} {
		append image_url "generic_document.png"
	    }
	    default {
		append image_url "generic_document.png"
	    }
	}
    }
} else {
    set folder_id $root_folder_id
    db_multirow -extend {item_url image_url} most_recent select_most_recent_files { } {
	set item_url [export_vars -base "${base_url}index" { {folder_id $parent_id}}]
	set image_url "/resources/documents/"
	switch $mime_type {
	    {application/msword} -
	    {application/vnd.ms-word} {
		append image_url "msword.png"
	    }
	    {application/msexcel} -
	    {application/vnd.ms-excel} {
		append image_url "msexcel.png"
	    }
	    {application/mspowerpoint} -
	    {application/vnd.ms-powerpoint} {
		append image_url "msppt.png"
	    }
	    {application/pdf} {
		append image_url "pdf.png"
	    }
	    {text/html} {
		append image_url "generic_document.png"
	    }
	    default {
		append image_url "generic_document.png"
	    }
	}
    }
    
}


# Document's search form 
ad_form -name search -export {folder_id} -action list -form {
    {keyword:text(text),optional {label "[_ documents.Search]"}} 
}
