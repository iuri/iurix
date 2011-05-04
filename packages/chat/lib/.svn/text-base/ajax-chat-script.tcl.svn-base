ad_page_contract {
  a tiny chat client

  @author Gustaf Neumann (gustaf.neumann@wu-wien.ac.at)
  @creation-date Jan 31, 2006
  @cvs-id $Id: ajax-chat-script.tcl,v 1.7 2008/11/09 23:29:23 donb Exp $
} -query {
  msg:optional
}

set return_url [ad_conn url]

set html_room_url [export_vars -base "room-enter" {room_id {client html}}]
set invite_user_url [export_vars -base "invite-user" {room_id}]
set file_add_url [export_vars -base "file-add" {room_id return_url}]
set chat_frame [ ::chat::Chat login_popup -chat_id $room_id]
