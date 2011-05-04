#/www/chat/room.tcl
ad_page_contract {
    Display information about chat room.
    @author David Dao (ddao@arsdigita.com)
    @creation-date November 15, 2000
    @cvs-id $Id: room.tcl,v 1.8 2008/11/09 23:29:23 donb Exp $
} {
    room_id:integer,notnull
} -properties {
    context_bar:onevalue
    pretty_name:onevalue
    description:onevalue
    archive_p:onevalue
    moderated_p:onevalue
    active_p:onevalue
    room_view_p:onevalue
    room_edit_p:onevalue
    room_delete_p:onevalue
    user_ban_p:onevalue
    user_unban_p:onevalue
    user_grant_p:onevalue
    user_revoke_p:onevalue
    moderator_grant_p:onevalue
    moderator_revoke_p:onevalue
    transcript_create_p:onevalue
    transcript_edit_p:onevalue
    transcript_view_p:onevalue
    moderators:multirow
    users_allow:multirow
    users_ban:multirow
    chat_transcripts:multirow
}

set context_bar [list "[_ chat.Room_Information]"]

###
# Get all available permission of this user on this room.
###
set room_view_p [permission::permission_p -object_id $room_id -privilege chat_room_view]
set room_edit_p [permission::permission_p -object_id $room_id -privilege chat_room_edit]
set room_delete_p [permission::permission_p -object_id $room_id -privilege chat_room_delete]
set user_ban_p [permission::permission_p -object_id $room_id -privilege chat_user_ban]
set user_unban_p [permission::permission_p -object_id $room_id -privilege chat_user_unban]
set user_grant_p [permission::permission_p -object_id $room_id -privilege chat_user_grant]
set user_revoke_p [permission::permission_p -object_id $room_id -privilege chat_user_revoke]
set moderator_grant_p [permission::permission_p -object_id $room_id -privilege chat_moderator_grant]
set moderator_revoke_p [permission::permission_p -object_id $room_id -privilege chat_moderator_revoke]
set transcript_create_p [permission::permission_p -object_id $room_id -privilege chat_transcript_create]

###
# Get room basic information.
###
db_1row room_info {
    select pretty_name, description, moderated_p, active_p, archive_p, auto_flush_p, auto_transcript_p
    from chat_rooms
    where room_id = :room_id
}

# get db-message count
set message_count [db_string message_count "select count(*) from chat_msgs where room_id = :room_id" -default 0]

# List user ban from chat
db_multirow -extend {unban_url unban_text} banned_users list_user_ban {} {
    if { $user_unban_p } {
        set unban_url [export_vars -base "user-unban" {room_id party_id}]
        set unban_text [_ chat.Unban_user]
    }
}

set actions ""
if { $user_ban_p } {
    set actions [list [_ chat.Ban_user] [export_vars -base "search" {room_id {type ban}}]]
}

list::create \
    -name "banned_users" \
    -multirow "banned_users" \
    -key party_id \
    -pass_properties { user_unban_p room_id } \
    -row_pretty_plural [_ chat.banned_users] \
    -actions $actions \
    -elements {
        name {
            label "#chat.Name#"
        }
        email {
            label "#acs-kernel.Email_Address#"
        }
        actions {
            label "#chat.actions#"
            html { style "text-align:center" }
            link_url_col unban_url
            display_col unban_text
            link_html {class "button"}
        }
    }

ad_return_template
