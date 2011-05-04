#/chat/www/room-exit.tcl
ad_page_contract {
    Post log off message.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 25, 2000
    @cvs-id $Id: room-exit.tcl,v 1.5 2007/11/19 01:14:16 donb Exp $
} {
    room_id:integer,notnull
}

set user_id [ad_conn user_id]
set read_p [permission::permission_p -object_id $room_id -privilege "chat_room_view"]
set write_p [permission::permission_p -object_id $room_id -privilege "chat_room_edit"]
set ban_p [permission::permission_p -object_id $room_id -privilege "chat_ban"]

if { ($read_p == "0" && $write_p == "0") || ($ban_p == "1") } {
    #Display unauthorize privilege page.
    ad_returnredirect unauthorized
    ad_script_abort
}

chat_message_post $room_id $user_id "[_ chat.has_left_the_room]." "1"

# send to AJAX
set session_id [ad_conn session_id]
::chat::Chat c1 -volatile -chat_id $room_id -session_id $session_id
c1 logout

set room [::chat::Chat create new -volatile -chat_id $room_id]
set active_users [$room nr_active_users]
ns_log Notice "ACTIVE $active_users"

if {$active_users eq 0} {
    chat_flush_invitation_queue -room_id $room_id
}


ad_returnredirect close-window
#ad_returnredirect [dotlrn::get_url]
