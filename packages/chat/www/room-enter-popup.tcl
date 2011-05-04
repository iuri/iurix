#/chat/www/room-enter.tcl
ad_page_contract {

    Perform initialize before chat "Need to change this comment"

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 22, 2000
    @cvs-id $Id: room-enter.tcl,v 1.7 2007/11/19 01:14:16 donb Exp $
} {
    room_id:integer,notnull
    client:trim
} 

set user_id [ad_conn user_id]
ns_log Notice "ENTER-ROOM: $room_id | $user_id"

set read_p  [permission::permission_p -object_id $room_id -party_id $user_id -privilege "chat_room_view"]
set write_p [permission::permission_p -object_id $room_id -party_id $user_id -privilege "chat_room_edit"]
set ban_p   [permission::permission_p -object_id $room_id -privilege "chat_ban"]

ns_log Notice "$read_p | $write_p"
ns_log notice "--query ban $ban_p: permission::permission_p -object_id $room_id -privilege chat_ban -party_id [ad_conn user_id]"
set active  [room_active_status $room_id]

if { ($read_p == "0" && $write_p == "0") || ($ban_p == "1") || ($active == "f") } {
    #Display unauthorize privilege page.
    ad_returnredirect unauthorized
    ad_script_abort
}

set default_client [parameter::get -parameter "DefaultClient" -default "ajax"]

if {$default_client eq "java"} {
	chat_start_server
}

switch $client {
    "html" - "ajax" - "html-chat-script" {
        ns_log Notice "YY room-enter: has_entered_the room"
        chat_message_post $room_id $user_id "[_ chat.has_entered_the_room]." "1"
    }
}


ad_returnredirect "chat-popup?room_id=$room_id&client=$client"
