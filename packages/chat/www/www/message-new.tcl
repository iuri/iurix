ad_page_contract {
    Form to send intant messages

    @author iuri sampaio (iuri.sampaio@gmail.com)
    @creation-date 2011-01-17
}

set return_url [ad_conn package_url]
set title "Instant Message"


set online_users [chat_select_online_parties]


ad_form -name message_new -cancel_url close-window -form {
    {message_id:key}
    {target_user:integer(select)
	{label "[_ chat.To]"}
	{options $online_users}
    }
    {content:text(textarea)
	{label "[_ chat.Message]"}
    }
} -new_data {

    if {[catch { set room_id [chat_room_new -moderated_p "f" \
				  -description $content \
				  -active_p "t" \
				  -archive_p "t" \
				  -auto_flush_p "t" \
				  -auto_transcript_p "t" \
                                  -context_id [ad_conn package_id] \
				  -creation_user [ad_conn user_id] \
                                  -creation_ip [ad_conn peeraddr] $content]} errmsg]} {
        ad_return_complaint 1 "[_ chat.Create_new_room_failed]: $errmsg"
        break
    }
    
    set group_p [db_0or1row select_group { select group_id from groups where group_id = :target_user}]
    if {$group_p} {
	set target_user [group::get_members -group_id $target_user]
    }
    
    foreach target_user_id $target_user {
	ns_log Notice "$target_user_id"
	db_exec_plsql grant_permission {}
	
	chat_add_to_invitation_queue \
	    -room_id $room_id \
	    -sender_user_id [ad_conn user_id] \
	    -target_user_id $target_user_id \
	    -content $content
    }

} -after_submit {
    set client ajax
    ad_returnredirect [export_vars -base "/chat/room-enter-popup" {room_id client content}]
}
    
