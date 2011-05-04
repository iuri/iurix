#/chat/www/chat-popup.tcl
ad_page_contract {

    Decide which template to use HTML or AJAX.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 22, 2000
    @cvs-id $Id: chat.tcl,v 1.13 2008/11/09 23:29:23 donb Exp $
} {
    room_id
    {client "ajax"}
    {message:html ""}
} -properties {
    context:onevalue
    user_id:onevalue
    user_name:onevalue
    message:onevalue
    room_id:onevalue
    room_name:onevalue 
    width:onevalue
    height:onevalue
    host:onevalue
    port:onevalue
    moderator_p:onevalue
    msgs:multirow
}

ns_log Notice "CHAT"

if { [catch {set room_name [chat_room_name $room_id]} errmsg] } {
    ad_return_complaint 1 "[_ chat.Room_not_found]"
}

set doc(title) $room_name
set doc(type) {<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">}

set context [list $doc(title)]

auth::require_login
set user_id [ad_conn user_id]
set read_p [permission::permission_p -object_id $room_id -privilege "chat_room_view"]
set write_p [permission::permission_p -object_id $room_id -privilege "chat_room_edit"]
set ban_p [permission::permission_p -object_id $room_id -privilege "chat_ban"]
set moderate_room_p [chat_room_moderate_p $room_id]

ns_log Notice "CHAT"
ns_log Notice "$user_id | $read_p | $write_p"

if { $moderate_room_p == "t" } {
    set moderator_p [permission::permission_p -object_id $room_id -privilege "chat_moderator"]
} else {
    # This is an unmoderate room, therefore everyone is a moderator.
    set moderator_p "1"
}

if { ($read_p == "0" && $write_p == "0") || ($ban_p == "1") } {
    #Display unauthorize privilege page.
    ad_returnredirect unauthorized
    ad_script_abort
}

# Get chat screen name.
set user_name [chat_user_name $user_id]

# send message to the database 
if { ![empty_string_p $message] } {
    chat_message_post $room_id $user_id $message $moderator_p
}

# Determine which template to use for html or ajax client
switch $client {
    "html" {
        set template_use "html-chat"
        # forward to ajax if necessary
        if { ![empty_string_p $message] } {
            set session_id [ad_conn session_id]
            ::chat::Chat c1 -volatile -chat_id $room_id -session_id $session_id
            c1 add_msg $message
        }
    }
    "ajax" {
        set template_use "/packages/chat/lib/ajax-chat-script"
    }
    "java" {
	set template_use "java-chat"
	
	# Get config paramater for applet.
	set width [ad_parameter AppletWidth "" 500]
	set height [ad_parameter AppletHeight "" 400]   
	
	set host [ad_parameter ServerHost "" [ns_config "ns/server/[ns_info server]/module/nssock" Hostname]]
	set port [ad_parameter ServerPort "" 8200]
    }
}

ad_return_template $template_use

