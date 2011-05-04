ad_page_contract {

} {
    type:notnull
    room_id:integer,notnull
    party_id:integer,notnull
}

if {$type eq "user"} {
  ad_require_permission $room_id chat_user_grant
  chat_user_grant $room_id $party_id
} else {
  ad_require_permission $room_id chat_user_ban
  chat_user_ban $room_id $party_id
}
ad_returnredirect "room?room_id=$room_id"

