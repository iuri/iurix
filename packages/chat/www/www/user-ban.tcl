#/chat/www/user-ban.tcl
ad_page_contract {
    
    Explicit ban user from the chat room.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 22, 2000
    @cvs-id $Id: user-ban.tcl,v 1.3 2006/03/14 12:16:09 emmar Exp $
} {
    room_id:integer,notnull
} -properties {
    context_bar:onevalue
    title:onevalue
    action:onevalue
    submit_label:onevalue
    room_id:onevalue
    description:onevalue
    parties:multirow
}

ad_require_permission $room_id chat_user_ban

set context_bar [list "[_ chat.Ban_user]"]
set submit_label "[_ chat.Ban]"
set title "[_ chat.Ban_user]"
set action "user-ban-2"
set description "[_ chat.Ban_chat_read_write] <b>[chat_room_name $room_id]</b> [_ chat.to]"
db_multirow parties list_parties {}

ad_return_template grant-entry
