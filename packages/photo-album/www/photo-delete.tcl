# photo-album/www/photo-delete.tcl

ad_page_contract {
    Confirms that user wants to delete a photo and deletes photo

    The delete removes all traces of a pa_photo and its associated images
    Schedules binaries to be deleted from filesystem
    Cannot be undone

    @author Tom Baginski (bags@arsdigita.com)
    @creation-date 12/21/2000
    @cvs-id $Id: photo-delete.tcl,v 1.5 2003/11/18 22:59:03 rocaelh Exp $
} {
    photo_id:integer,notnull
    {confirmed_p "f"}
    return_url:optional
} -validate {
    valid_photo -requires {photo_id:integer} {
	if [string equal [pa_is_photo_p $photo_id] "f"] {
	    ad_complain "[_ photo-album._The_2]"
	}
    }
} -properties {
    photo_id:onevalue
    title:onevalue
    path:onevalue
    height:onevalue
    width:onevalue
}


# to delete a photo need delete on photo and write on parent album 
set album_id [db_string get_parent_album "select parent_id from cr_items where item_id = :photo_id"]
ad_require_permission $photo_id delete
ad_require_permission $album_id write

if { [string equal $confirmed_p "t"]  } {
    # they have confirmed that they want to delete the photo
    # delete pa_photo object which drops all associate images and schedules binaries to be deleted

    if {[apm_package_installed_p tags]} {
	#Remove tags first!!
	db_dml clear_tags {
	    delete from tags_tags
	    where item_id = :photo_id
	}
    }

    db_exec_plsql drop_image {
	begin
	pa_photo.del (:photo_id);
	end;
    }

    pa_flush_photo_in_album_cache $album_id
    
    # HAM : added return_url
    if { ![exists_and_not_null return_url] } {
        ad_returnredirect "album?album_id=$album_id"
    } else {
        ad_returnredirect $return_url
    }
    ad_script_abort

} else {
    # they still need to confirm

    set context_list [pa_context_bar_list -final "[_ photo-album._Delete_1]" $photo_id]
    db_1row get_photo_info {select 
      cr.title,
      i.height as height,
      i.width as width,
      i.image_id as image_id
    from cr_items ci,
      cr_revisions cr,
      cr_items ci2,
      cr_child_rels ccr2,
      images pi
    where ci.live_revision = cr.revision_id
      and ci.item_id = ccr2.parent_id
      and ccr2.child_id = ci2.item_id
      and ccr2.relation_tag = 'thumb'
      and ci2.live_revision = i.image_id
      and ci.item_id = :photo_id
     }
     
     set path $image_id
     
     ad_return_template
 }
