#/chat/www/room-delete-2.tcl
ad_page_contract {
    Delete the chat room.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 16, 2000
    @cvs-id $Id: room-delete-2.tcl,v 1.5 2007/11/19 01:14:16 donb Exp $
} {
    room_id:notnull
    {return_url "/chat/index"}
    {cancel.x:optional}
}

if {![info exists cancel.x]} {

    
    foreach element $room_id {    
	ad_require_permission $element chat_room_delete
	chat_room_file_delete $element 
	chat_flush_invitation_queue -room_id $element
	if { [catch {chat_room_delete $element} errmsg] } {
	    ad_return_complaint 1 "[_ chat.Delete_room_failed]: $errmsg"
	}
    }
}
ad_returnredirect $return_url





