ad_page_contract {
  This is a index to list audios

  @author Iuri Sampaio
  @date 2010-12-13
} {
    {audio_id ""}
    {object_id ""}
} 

if {![exists_and_not_null audio_id]} {
    set audio_id $object_id
}
permission::require_permission -party_id [ad_conn user_id] -object_id $audio_id -privilege read



set package_id [ad_conn package_id]

set revision_id [content::item::get_live_revision -item_id $audio_id]
set audio_url [content::revision::get_cr_file_path -revision_id $revision_id]

set url [site_node::get_url_from_object_id -object_id [ad_conn package_id]]
ns_log Notice "AUDIOS-VIEW URL: $url $revision_id "


set return_url [ad_return_url]

template::head::add_javascript -src "/resources/audios/swfobject.js" -order 1 
template::head::add_javascript -src "/resources/audios/headerexpress.js" -order 2

#audios::create_xml -item_id $audio_id

set audio_in_queue [db_string select_audio {select item_id from audio_queue where item_id = :audio_id} -default ""]
set cont 1
if {![string equal $audio_in_queue ""]} {
	set cont 0 
}

set image_size [parameter::get -package_id $package_id -parameter ImageSize]
set widthxheight [split $image_size "x"]
set width [lindex $widthxheight 0]
set height [lindex $widthxheight 1]
if {$width > 500} {
	set width [expr $width - 200]
}

db_1row select_audio {
    select a.audio_name, 
    a.audio_description,
    a.audio_date,
    a.author,
    a.coauthor,
    a.source,
    a.group_id,
    a.creator_id 
    from audios a
    where audio_id = :audio_id
} -column_array audio

#Get Community name to show as audio info
set group_id $audio(group_id)

set group_name [db_string select_group_name {
    select instance_name 
    from apm_packages ap
    where package_id = :group_id
}]

if {![exists_and_not_null group_name]} {
    set dotlrn_p [apm_package_installed_p dotlrn]
    if {$dotlrn_p} {
	#get communities and subsites
	
	set community_name [db_string select_community_name {
	    select pretty_name
	    from dotlrn_communities 
	    where community_id = :community_id	    
	}]
    }
}

#Get user name to show as audio info
set creator_id $audio(creator_id)

set creator_name [db_string select_creator {
    select u.first_names || ' ' || u.last_name as name 
    from cc_users u 
    where u.user_id = :creator_id
}]






set admin_p [permission::permission_p -party_id [ad_conn user_id] -object_id $audio_id -privilege admin]

set context [list "" $audio(audio_name)]
set title $audio(audio_name)

set user_id [ad_conn user_id]

set package_url [apm_package_url_from_id $package_id]



set add_tag_link [tags::create_link -item_id $audio_id -link_text "Add a Tag"]

set tags [db_list select_audio_tags { 
    select tag from tags_tags where item_id = :audio_id 
}]
ns_log Notice "TAGS $tags"


set audio_ids [db_list select_audios {
    select item_id from tags_tags 
    where tag in (
		      select tag from tags_tags where item_id = :audio_id
		      )
}]

ns_log Notice "AUDIOS $audio_ids"

# Right Scrolling Audios
db_multirow -extend {} related_audios select_related_audios {} {}


# Notifications
set notification_chunk [notification::display::request_widget \
    -type audios_audio_notif \
    -object_id $audio_id \
    -pretty_name "Audio Item: $audio(audio_name)" \
    -url [ad_conn url]?object_id=$audio_id \
]

set type_id [notification::type::get_type_id -short_name audios_audio_notif]
ns_log Notice "TYPEID $type_id"
set notification_count [notification::request::request_count \
			    -type_id $type_id \
			    -object_id $audio_id]



# General Comments
set comment_add_url "[general_comments_package_url]comment-add?[export_vars {
 { object_id $audio_id } 
 { object_name $audio(audio_name) } 
 { return_url "[ad_conn url]?[ad_conn query]"} 
}]"

set comments_html [general_comments_get_comments -print_content_p 1 $audio_id]

audios::download_counter -user_id [ad_conn user_id] -package_id $package_id -revision_id $revision_id -audio_id $audio_id 


