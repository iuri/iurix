#/chat/www/transcript-delete.tcl
ad_page_contract {
    Display confirmation before delete chat transcript.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 28, 2000
    @cvs-id $Id: transcript-delete.tcl,v 1.6 2008/11/09 23:29:23 donb Exp $
} {
    room_id:integer,notnull
    transcript_id:integer,notnull
} -properties {
    context_bar:onevalue
    room_id:onevalue
    transcript_id:onevalue
}

permission::require_permission -object_id $transcript_id -privilege chat_transcript_delete

set context [list "[_ chat.Delete_transcript]"]
ad_return_template
