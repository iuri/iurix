ad_page_contract {
    Form to send intant messages

    @author iuri sampaio (iuri.sampaio@gmail.com)
    @creation-date 2011-01-17
} {
    room_id
}
 
ns_log Notice "$room_id"
set return_url [ad_conn package_url]
set title "Invite User"

set select_options ""

foreach user_id [whos_online::user_ids] {
    acs_user::get -user_id $user_id -array user
    
    
    lappend select_options [list  "$user(name)" $user_id]
}



ad_form -name invite_user -form {
    {message_id:key}
    {room_id:integer(hidden)
	{value $room_id}
    }
    {target_user_id:integer(select)
	{label "[_ chat.To]"}
	{options $select_options}
    }
    {content:text(textarea)
	{label "[_ chat.Message]"}
    }
} -on_submit {
    
    db_exec_plsql grant_permission {}
    
    chat_add_to_invitation_queue \
	-room_id $room_id \
	-sender_user_id [ad_conn user_id] \
	-target_user_id $target_user_id \
	-content $content
	
	

} -after_submit {
    set client ajax
    ad_returnredirect [export_vars -base "/chat/room-enter-popup" {room_id client}]
}
    
