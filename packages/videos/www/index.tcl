ad_page_contract {
    list of videos
    
    @author Alessandro Landim
    @author iuri sampaio

    $Id: site-master.tcl,v 1.22.2.7 2007/07/18 10:44:06 emmar Exp $
} {
    {keyword ""}
} 

set user_id [ad_conn user_id]
set package_id [ad_conn package_id]
set object_id [ad_conn object_id]

permission::require_permission -party_id [ad_conn user_id] -object_id $package_id -privilege read

set admin_p [permission::permission_p -party_id [ad_conn user_id] -object_id [ad_conn package_id] -privilege admin]
set action_list ""

if {$admin_p eq 1} {
      set action_list {"#videos.New#" videos-new "#videos.New#"}
}

set image_size [parameter::get -package_id $package_id -parameter ImageSize]
set widthxheight [split $image_size "x"]
set width [lindex $widthxheight 0]
set height [lindex $widthxheight 1]
if {$width > 500} {
    set width [expr $width - 200]
}


#variable lists to db_multirow
set extend_list [list]

db_multirow -extend $extend_list recent_videos select_recent_videos {} { }

db_multirow -extend $extend_list videos select_videos {} { }

db_multirow -extend $extend_list popular_videos select_popular_videos {} { }


# Video's search form 
ad_form -name search -export {} -action list -form {
    {keyword:text(text),optional {label "[_ videos.Search]"} }
}



set notification_chunk [notification::display::request_widget \
    -type videos_video_notif \
    -object_id $package_id \
    -pretty_name "Videos" \
    -url [ad_conn url]?object_id=$package_id \
]

ns_log Notice "$notification_chunk"

set type_id [notification::type::get_type_id -short_name videos_video_notif]
ns_log Notice "TYPEID $type_id"
set notification_count [notification::request::request_count \
			    -type_id $type_id \
			    -object_id $package_id]
