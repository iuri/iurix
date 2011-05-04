#/chat/www/index.tcl
ad_page_contract {
    Display a list of available chat rooms that the user has permission to edit.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 13, 2000
    @cvs-id $Id: index.tcl,v 1.11 2009/07/13 16:35:29 emmar Exp $
} {
} -properties {
    context_bar:onevalue
    package_id:onevalue
    user_id:onevalue
    room_create_p:onevalue
    rooms:multirow
}

set package_id [ad_conn package_id]
set user_id [ad_conn user_id]
set actions [list]
set bulk_actions [list]
set room_create_p [permission::permission_p -object_id $package_id -privilege chat_room_create]
set room_delete_p [permission::permission_p -object_id $package_id -privilege chat_room_delete]

set default_client [parameter::get -parameter "DefaultClient" -default "ajax"]
set warning ""

if { $default_client eq "ajax" && ![apm_package_installed_p xotcl-core] } {
    set warning "[_ chat.xotcl_missing]"
}

if { $room_create_p } {
    lappend actions "#chat.Create_a_new_room#" room-edit "#chat.Create_a_new_room#"
}

if { $room_delete_p } {
    set bulk_actions {"#chat.Delete#" "room-bulk-delete" "#chat.Delete_selected_msgs#"}
} 

chat_remove_inactive_rooms

db_multirow -extend {active_users last_activity room_url room_html_url} rooms rooms_list {} {
    set room [::chat::Chat create new -volatile -chat_id $room_id]
    ns_log Notice "TESTE"
    ns_log Notice "[$room info vars]"
    set active_users [$room nr_active_users]
    set last_activity [$room last_activity]

    if { $active_p } {
        set room_url [export_vars -base "room-enter-popup" {room_id {client $default_client}}]
        set room_url [ad_quotehtml $room_url]
        set room_html_url [export_vars -base "room-enter-popup" {room_id {client html}}]
        set room_html_url [ad_quotehtml $room_html_url]
    }
}



list::create \
    -name "rooms" \
    -multirow "rooms" \
    -key room_id \
    -pass_properties {room_create_p} \
    -bulk_actions $bulk_actions \
    -bulk_action_export_vars { return_url } \
    -actions $actions \
    -row_pretty_plural [_ chat.rooms] \
    -no_data [_ chat.There_are_no_rooms_available] \
    -elements {
        active {
            label "#chat.Active#"
            html { style "text-align: center" }
            display_template {
                <if @rooms.active_p@ eq t>
                <img src="/resources/chat/active.png" alt="#chat.Room_active#">
                </if>
                <else>
                <img src="/resources/chat/inactive.png" alt="#chat.Room_no_active#">
                </else>
            }
        }
        pretty_name {
            label "#chat.Room_name#"
            display_template {
                <if @rooms.active_p@ eq t>
                <a href="@rooms.room_url;noquote@" onclick="return popitup('room-enter-popup?room_id=@rooms.room_id@&client=ajax')">@rooms.pretty_name@</a>&nbsp;\[<a href="@rooms.room_html_url;noquote@">#chat.HTML_chat#</a>\]
                </if>
                <else>
                @rooms.pretty_name@
                </else>
            }
        }
	author {
	    label "[_ chat.Author]"
	    link_url_eval {[acs_community_member_url -user_id $author_id]}
	}
        last_activity {
            label "#chat.last_activity#"
            html { style "text-align:center;" }
        }
    }

# set page properties

set doc(title) [_ chat.Chat_main_page]

ad_return_template
