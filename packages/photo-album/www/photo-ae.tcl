# /packages/photo-album/www/photo-add.tcl

ad_page_contract {

    Upload a photo to an existing album

    @author Tom Baginski (bags@arsdigita.com)
    @creation-date 12/10/2000
    @cvs-id $Id: photo-add.tcl,v 1.6.6.1 2007/06/14 09:12:49 emmar Exp $
} {
    album_id:integer,notnull
    photo_id:integer,notnull,optional
} -properties {
    album_id:onevalue
    context_list:onevalue
    path:onevalue
    height:onevalue
    width:onevalue
}

set package_id [ad_conn package_id]

# check for read permission on folder
ad_require_permission $album_id pa_create_photo

set context_list [pa_context_bar_list -final "[_ photo-album._Upload]" $album_id]

#set photo_id [db_string get_next_object_id "select acs_object_id_seq.nextval from dual"]

set community_options [photo_album::get_community_options]

set return_url [export_vars -base "photo" {photo_id}]

ad_form -name photo-ae -action photo-ae -cancel_url $return_url -form {
    {photo_id:key}
    {album_id:integer(hidden)}
    {revision_id:integer(hidden)}
    {previous_revision:integer(hidden)}

    {title:text(text),optional
	{label "[_ photo-album.Title]"}
	{help_text "[_ photo-album.Help_Title]"}
    }
    {description:text(textarea),optional
	{html { cols 50 rows 5}}
	{label "[_ photo-album._Photo]"} 
	{help_text "[_ photo-album.lt_OPTIONAL_Displayed_wh]"}
    }
}


set category_ids [list]
foreach {category_id category_name} [photo_album::get_categories -package_id [ad_conn package_id]] {
    ad_form -extend -name photo-ae -form [list \
	[list "cat_${category_id}:integer(select),optional" \
	     [list label "${category_name}"] \
	     [list options [photo_album::category_get_options -parent_id $category_id]] \
	     [list value   ""] \
	] \
    ]
}



ad_form -extend -name photo-ae -form {
    {community_id:integer(select),optional
	{label "[_ photo-album.Community]"} 
	{help_text "[_ photo-album.lt_OPTIONAL_Displayed_community]"}
	{options $community_options}
    }
    {photographer:text(text),optional
	{label "[_ photo-album.Photographer]"}
	{help_text "[_ photo-album.Help_Photographer]"}
	{html {size 30}}	    
    }
    {date:date(date),optional
	{label "[_ photo-album.Date]"}
        {html {id sel1} }
        {format "YYYY MM DD"}
        {after_html {<input type="button" style="height:23px; width:23px; background: url('/resources/acs-templating/calendar.gif');" onclick ="return showCalendarWithDateWidget('date', 'y-m-d');" > \[<b>[_ photo-album.y-m-d]</b>\]}}
    }
    {tags:text(text),optional
	{label "[_ photo-album.Tags]"} 
	{help_text "[_ photo-album.lt_OPTIONAL_Displayed_tags]"}
	{html { size 30 }}
    }

} -new_request {
	
    set read_term 0


} -edit_request {

    db_1row get_photo_info { *SQL* }
    db_1row get_thumbnail_info { *SQL* }
    db_1row get_photo_more_info { *SQL* }
    
    set path $image_id

    set revision_id [db_string get_next_object_id "select acs_object_id_seq.nextval from dual"]
    template::element set_properties photo-ae revision_id -value $revision_id
    template::element set_properties photo-ae photo_id -value $photo_id
    template::element set_properties photo-ae previous_revision -value $previous_revision
    template::element set_properties photo-ae photographer -value $photographer
    template::element set_properties photo-ae community_id -value $community_id
    template::element set_properties photo-ae description -value $description

    set date [photo_album::from_sql_datetime -sql_date $date_taken -format "YYYY-MM-DD"]
    #set date $date_taken
    
    ns_log Notice "$revision_id | $photo_id | $previous_revision | $photographer | $community_id | $date"


    foreach {category_id category_name} [photo_album::get_categories -package_id $package_id] {
        set cat_${category_id} [photo_album::get_category_child_mapped -category_id $category_id -object_id $photo_id]
    }

} -edit_data {
    db_transaction {

	set peeraddr [ad_conn peeraddr]
	set user_id [ad_conn user_id]
	set date_timestamp [photo_album::convert_to_timestamp -date $date]
	set story $description
	set caption $description

	ns_log Notice "$community_id | $photographer"
	db_exec_plsql update_photo_attributes {} 
	db_dml insert_photo_attributes { *SQL* }

	# for now all the attributes about the specific binary file stay the same
	# not allowing users to modify the binary yet
	# will need to modify thumb and view binaries when photo binary is changed 
	
	# db_dml update_photo_user_filename {} 
	
	db_exec_plsql set_live_revision {} 

	foreach {category_id category_name} [photo_album::get_categories -package_id $package_id] {
	    category::map_object -remove_old -object_id $photo_id ""
	}
	foreach {category_id category_name} [photo_album::get_categories -package_id $package_id] {
	    set child_id  [set cat_${category_id}]
	    category::map_object -object_id $photo_id $child_id
	    
	}
    
	
    } on_error {
	ad_return_complaint 1 "[_ photo-album._An_1]
	  <pre>$errmsg</pre>"
	
	ad_script_abort
    }
    
    ad_returnredirect "photo?photo_id=$photo_id"
    ad_script_abort

} -on_submit {


} -new_data {

    db_transaction {
	#check permission
	ad_require_permission $album_id "pa_create_photo"


	ns_log Notice "*********** $date"

	set user_id [ad_conn user_id]
	set new_photo_ids [pa_load_images \
			       -remove 1 \
			       -client_name $upload_file \
			       -description $description \
			       -community_id $community_id \
			       -photographer $author \
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


