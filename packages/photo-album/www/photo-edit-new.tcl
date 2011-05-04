# /packages/photo-album/www/photo-edit.tcl

ad_page_contract {

    Edit Photo Properties

    @author Tom Baginski (bags@arsdigita.com)
    @creation-date 12/11/2000
    @cvs-id $Id: photo-edit.tcl,v 1.4.10.1 2007/06/14 09:12:49 emmar Exp $
} {
    {hide:integer 0}
    {photo_id:integer 0}
    d:array,integer,optional
    {return_url ""}
} -properties {
    path:onevalue
    height:onevalue
    width:onevalue
}

#  -validate {
#     valid_photo -requires {photo_id:integer} {
# 	if [string equal [pa_is_photo_p $photo_id] "f"] {
# 	    ad_complain "[_ photo-album._The_2]"
# 	}
#     }
# }

ad_require_permission $photo_id "write"

set user_id [ad_conn user_id]
set context_list [pa_context_bar_list -final "[_ photo-album._Edit_2]" $photo_id]

#clear the cached value 
util_memoize_flush $photo_id

foreach id [array names d] { 
    if { $d($id) > 0 } { 
        pa_rotate $photo_id $d($photo_id)
    }
}


ad_form -name "edit_photo" -cancel_url $return_url -form { 
    {photo_id:key}
    {revision_id:integer(hidden)
	{label ""}
    }
    {previous_revision:integer(hidden)
	{label ""}
    }
    {title:text(text)
	{label "<#_Titile#>"}
	{html {size 30}}
    }
    {photographer:text(text)
	{label "<#_Photographer#>"}
	{html {size 30}}
    }
    {caption:text(text)
	{label "<#_Caption#>"}
	{html {size 30}}
    }
    {description:text(text)
	{label "<#_Photographer#>"}
	{html {size 50}}
	{help_text "Displayed on the thumbnail page"} 
    }
    {story:text(textarea)
	{label "<#_Story#>"}
	{html {size 50}}
	{help_text "Displayed when viewing the photo"} 
    }
} -edit_request {

# moved outside is_request_block so that vars exist during form error reply

    db_1row get_photo_info { *SQL* }
    db_1row get_thumbnail_info { *SQL* }
    
    
    if [empty_string_p $live_revision] {
	set checked_string "checked"
    } else {
	set checked_string ""
    }
    #ad_return_error $checked_string  "$live_revision"
    set path $image_id
    
    
    
    
    set revision_id [db_string get_next_object_id "select acs_object_id_seq.nextval from dual"]

} -on_submit {

    db_transaction {
	db_exec_plsql update_photo_attributes {} 
	db_dml insert_photo_attributes { *SQL* }

	# for now all the attributes about the specific binary file stay the same
	# not allowing users to modify the binary yet
	# will need to modify thumb and view binaries when photo binary is changed 

	#db_dml update_photo_user_filename {} 

	db_exec_plsql set_live_revision {} 

	if $hide {
	    db_dml update_hides { *SQL* }
	} 
    } on_error {
	ad_return_complaint 1 "[_ photo-album._An_1]
	  <pre>$errmsg</pre>"
	
	ad_script_abort
    }
    

} -after_submit {

    ad_returnredirect "photo?photo_id=$photo_id"
    ad_script_abort

}


# These lines are to uncache the image in Netscape, Mozilla. 
# IE6 & Safari (mac) have a bug with the images cache
ns_set put [ns_conn outputheaders] "Expires" "-"
ns_set put [ns_conn outputheaders] "Last-Modified" "-"
ns_set put [ns_conn outputheaders] "Pragma" "no-cache"
ns_set put [ns_conn outputheaders] "Cache-Control" "no-cache"

ad_return_template
