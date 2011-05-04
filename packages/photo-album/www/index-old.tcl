ad_page_contract {

    Photo album front page.  List the albums and subfolders in the folder specified
    Uses package root folder if none specified

    @author Tom Baginski (bags@arsdigita.com)
    @creation-date 12/7/2000
    @cvs-id $Id: index.tcl,v 1.6 2003/11/18 22:59:03 rocaelh Exp $
} {
    {folder_id:integer [pa_get_root_folder]}
} -validate {
    valid_folder -requires {folder_id:integer} {
	if [string equal [pa_is_folder_p $folder_id] "f"] {
	    ad_complain "[_ photo-album._The_3]"
	}
    }
} -properties {
    context:onevalue
    folder_name:onevalue
    folder_description:onevalue
    folder_id:onevalue
    admin_p:onevalue
    subfolder_p:onevalue
    album_p:onevalue
    write_p:onevalue
    move_p:onevalue
    delete_p:onevalue
    child:multirow
    shutterfly_p:onevalue
    child_photo:multirow
}




# check for read permission on folder
ad_require_permission $folder_id read

# HAM : AjaxPA
# - we need to pass package_id to ajaxpa-include
# - turn ajaxpa on/off with a parameter, default to 1 for now
set package_id [ad_conn package_id]
#set use_ajaxpa_p [parameter::get -parameter UseAjaxPa -default 1]
set use_ajaxpa_p 1

set user_id [ad_conn user_id]
set context [pa_context_bar_list $folder_id]

# get all the info about the current folder and permissions with a single trip to database
db_1row get_folder_info {}

set root_folder_id [pa_get_root_folder]
set parameter_url_vars [export_url_vars package_id=$package_id return_url=[ad_conn url]]

# to move an album need write on album and write on parent folder
set move_p [expr $write_p && !($folder_id == $root_folder_id) && $parent_folder_write_p]

# to delete an album, album must be empty, need delete on album, and write on parent folder
set delete_p [expr !($has_children_p) && !($folder_id == $root_folder_id) && $folder_delete_p && $parent_folder_write_p]

if $has_children_p {
    db_multirow child get_children {}
} else {
    set child:rowcount 0
}

set collections [db_string collections {select count(*) from pa_collections where owner_id = :user_id}]

set shutterfly_p [parameter::get -parameter ShowShutterflyLinkP -default f]


###
# Unsorted Photos
### 

# create API to return photos radomically from all albums max 10.
#set photos_on_page [pa_get_random_pages $page]
set photos_on_page [pa_all_photos 10]

if {$has_children_p && [llength $photos_on_page] > 0} {
    # query gets all child photos in album
    # I query the data without an orderby in the sql to cut the querry time
    # and then sort the returned data manually while constructing the multirow datasource.
    # This goes against the theory of let oracle do the hard work, but load testing and
    # query tuning showed that the order by doubled the query time while sorting a few rows in tcl was fast

    # wtem@olywa.net, 2001-09-24
    db_foreach get_child_photos {} {
	set val(photo_id) $photo_id
	set val(caption) $caption
	set val(thumb_path) $thumb_path
	set val(thumb_height) $thumb_height
	set val(thumb_width) $thumb_width
	set child1($photo_id) [array get val]
    }


    # if the structure of the multirow datasource ever changes, this needs to be rewritten    
    set counter 0
    foreach id $photos_on_page {
        if {[info exists child1($id)]} {
            incr counter 
            foreach {key value} $child1($id) {
                set child_photo:${counter}($key) $value
            }
        }
    }
    set child_photo:rowcount $counter

} else {
    # don't bother querying for children if we know they don't exist
    set child_photo:rowcount 0
}

ad_return_template


