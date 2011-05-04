ad_page_contract {
    Show photos on slider javascript
    
    @author iuri.sampaio@gmail.com
} {
    {album_id ""}

}

photo_album::album_create_xml -album_id $album_id





#set photo_ids [pa_all_photos_in_album $album_id]
db_multirow photos select_photo_info {
    select
    ci.item_id as photo_id
    from cr_items ci,
    cr_child_rels ccr
    where ci.latest_revision is not null
    and ci.content_type = 'pa_photo'
    and ccr.parent_id = :album_id
    and ci.item_id = ccr.child_id
    order by ccr.order_n
    
} {
    photo_album::photo::get -photo_id $photo_id -array photo
    ns_log Notice "[parray photo]"
    set left_url $photo(left_thumb_content)
    set right_url $photo(right_thumb_content)
    ns_log Notice "$left_url | $right_url"
}


#set photo_ids [db_list select_photos "SELECT live_revision from cr_items where content_type = 'pa_photo'"]
#ns_log Notice "PHOTOID $photo_ids"


#foreach photo_id $photo_ids {
#    photo_album::photo::get -photo_id $photo_id -array photo
#    set left_url $photo(
#    set 


#    ns_log Notice "[parray photo]"
#}


multirow create photos left_path center_path right_path
multirow foreach photos {} 

set show all

multirow create show_opts value label count

multirow append show_opts "all" "All" 5
multirow append show_opts "translated" "Translated" 10
multirow append show_opts "untranslated" "Untranslated" 15
multirow append show_opts "deleted" "Deleted" 20

multirow extend show_opts url selected_p

multirow foreach show_opts {
    set selected_p [string equal $show $value]
    if {$value eq "all"} {
        set url "[ad_conn url]?[export_vars { locale package_key }]"
    } else {
        set url "[ad_conn url]?[export_vars { locale package_key {show $value} }]"
    }
}


