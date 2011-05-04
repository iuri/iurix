ad_page_contract {
    Confirms that user wants to delete a photo and deletes photo

    The delete removes all traces of a pa_photo and its associated images
    Schedules binaries to be deleted from filesystem
    Cannot be undone

    @author Tom Baginski (bags@arsdigita.com)
    @creation-date 12/21/2000
    @cvs-id $Id: photo-delete.tcl,v 1.5 2003/11/18 22:59:03 rocaelh Exp $
} {
    photo_id:multiple,optional
    album_id:integer,optional
    {confirmed_p "f"}
} -validate {
    valid_photo_or_album  {
	if {![exists_and_not_null album_id] && ![exists_and_not_null photo_id]} {
	    ad_complain "[_ photo-album.You_must_supply_one]"
		}
    }
} 

ns_log Notice "***********  $album_id | $confirmed_p"
set title "[_ photo-album.Delete_1]"

# to delete a photo need delete on photo and write on parent album 
if {[exists_and_not_null album_id]} {
	ad_require_permission $album_id admin
	if { [string equal $confirmed_p "t"]  } {
		foreach photo_id [pa_all_photos_in_album $album_id] {
		    # they have confirmed that they want to delete the photo
		    # delete pa_photo object which drops all associate images and schedules binaries to be deleted

		    #Remove tags first!!
		    if {[apm_package_installed_p tags]} {
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
		    
		}

		# Finish and redirect
	    ad_returnredirect "album?album_id=$album_id"
	    ad_script_abort
		
	} else {
	    # they still need to confirm
	
	    set context_list [pa_context_bar_list -final "[_ photo-album._Delete_1]" $album_id]
	    ad_return_template
	}
} else {
	if { [string equal $confirmed_p "t"]  } {
		set photo_id [string trim $photo_id {{}]
		set photo_id [string trim $photo_id {}}]
		foreach photo $photo_id {
		    set album_id [db_string get_parent_album "select parent_id from cr_items where item_id = $photo"]
		    ad_require_permission $album_id write
		    ad_require_permission $photo delete
		    
		    # they have confirmed that they want to delete the photo
		    # delete pa_photo object which drops all associate images and schedules binaries to be deleted

		    #Remove tags first!!
		    db_dml clear_tags {
			delete from tags_tags
			where item_id = :photo_id
		    }
		    
		    db_exec_plsql drop_image2 {
			begin
			pa_photo.del (:photo);
			end;
		    }
		
		    pa_flush_photo_in_album_cache $album_id
		    
		}	
		# Finish and redirect
		ad_returnredirect "album?album_id=$album_id"
		ad_script_abort
	} else {
		# they still need to confirm
		
		set context_list [list "[_ photo-album._Delete_1]"]
	}
}
