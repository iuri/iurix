# /packages/photo-album/www/album-delete.tcl

ad_page_contract {
    page to confirm and delete album.
    album must be empty to delete

    @author Tom Baginski (bags@arsdigita.com)
    @creation-date 1/8/2000
    @cvs-id $Id: album-delete.tcl,v 1.5 2003/11/18 22:59:03 rocaelh Exp $
} {
    album_id:integer,notnull
    {confirmed_p "f"}
    return_url:optional
} -validate {
    valid_album -requires {album_id:integer} {
	if [string equal [pa_is_album_p $album_id] "f"] {
	    ad_complain "[_ photo-album._The_1]"
	}
    }

    no_children -requires {album_id:integer} {
	if { [pa_count_photos_in_album $album_id] > 0 } {
	    ad_complain "<#_We're sorry, but you cannot delete albums unless they are already empty.#>"
	}
    }
} -properties {
    album_id:onevalue
    title:onevalue
    context_bar:onevalue
}

# to delete a album must have delete permission on the album
# and write on parent folder
set parent_folder_id [db_string get_parent "select parent_id from cr_items where item_id = :album_id"]
ad_require_permission $album_id delete
ad_require_permission $parent_folder_id write

if { [string equal $confirmed_p "t"]  } {
    # they have confirmed that they want to delete the album

    db_exec_plsql album_delete "
    begin
        pa_album.del(:album_id);
    end;"

    pa_flush_photo_in_album_cache $album_id

    # HAM : added return_url
    if { ![exists_and_not_null return_url] } {
        #redirect back to index page with parent_id
        ad_returnredirect "?folder_id=$parent_folder_id"
    } else {
        ad_returnredirect $return_url
    }
    ad_script_abort

} else {
    # they still need to confirm

    set title [db_string album_name "
    select content_item.get_title(:album_id,'t') from dual"]

    set context_list [pa_context_bar_list -final "Delete Album" $album_id]

}
