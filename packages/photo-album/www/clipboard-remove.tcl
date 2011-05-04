# /packages/photo-album/www/clipboard-attach.tcl
ad_page_contract {

    Detach a photo from a clipboard.
    
    @author Jeff Davis davis@xarg.net
    @creation-date 10/30/2002
    @cvs-id $Id: clipboard-remove.tcl,v 1.3 2005/03/01 00:01:40 jeffd Exp $
} {
    photo_id:integer,notnull
    collection_id:integer,notnull
}

auth::require_login

set user_id [ad_conn user_id]
set peeraddr [ad_conn peeraddr]
set context [ad_conn package_id]

if {$collection_id < 0} { 
    ad_returnredirect "clipboard-ae?photo_id=$photo_id"
    ad_script_abort
} 

if {$collection_id > 0} { 
    if {[catch {db_dml unmap_photo {}} errMsg]} {
        ad_return_error "Clipboard Remove error" "Error removing photo from clipboard<pre>$errMsg</pre>"
        ad_script_abort
    }
}

ad_returnredirect "photo?photo_id=$photo_id&collection_id=-$collection_id"
