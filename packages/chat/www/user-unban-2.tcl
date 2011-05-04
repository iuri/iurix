#/chat/www/user-unban-2.tcl
ad_page_contract {

    Unban chat user

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 22, 2000
    @cvs-id $Id: user-unban-2.tcl,v 1.1.1.1 2001/04/20 20:51:08 donb Exp $
} {
    room_id:integer,notnull
    party_id:integer,notnull
}

ad_require_permission $room_id chat_user_unban

chat_user_unban $room_id $party_id

ad_returnredirect "room?room_id=$room_id"
