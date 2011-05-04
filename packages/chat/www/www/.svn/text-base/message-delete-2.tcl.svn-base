#/chat/www/message-delete-2.tcl
ad_page_contract {
    Delete messages in the room.

    @author David Dao (ddao@arsdigita.com)
    @creation-date January 18, 2001
    @cvs-id $Id: message-delete-2.tcl,v 1.7 2007/11/19 01:14:16 donb Exp $
} {
    room_id:integer,notnull
}

permission::require_permission -object_id $room_id -privilege chat_room_delete

if { [catch {chat_room_message_delete $room_id} errmsg] } {
    ad_return_complaint 1 "[_ chat.Delete_messages_failed]: $errmsg"
}

::chat::Chat flush_messages -chat_id $room_id

ad_returnredirect .