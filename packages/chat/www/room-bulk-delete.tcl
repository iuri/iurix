#/chat/www/room-delete.tcl
ad_page_contract {
    Display delete confirmation.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 15, 2000
    @cvs-id $Id: room-delete.tcl,v 1.5 2007/11/19 01:14:16 donb Exp $
} {
    room_id:integer,multiple,notnull
} -properties {
    pretty_name:onevalue
    context_bar:onevalue
}

set context_bar [list "[_ chat.Delete_rooms]"]

set delete_p [permission::permission_p -object_id [ad_conn package_id] -privilege "chat_room_delete"]

if {$delete_p eq 0} {
    ad_returnredirect unauthorized-delete
    ad_script_abort
}

set room_ids $room_id
foreach element $room_ids {
    lappend room_ids "'[DoubleApos $element]'"
}

set room_ids [join $room_ids ","]

db_multirow rooms rooms "
    select room_id, pretty_name from chat_rooms where room_id in ($room_ids)
"

set hidden_vars [export_form_vars room_id return_url]

