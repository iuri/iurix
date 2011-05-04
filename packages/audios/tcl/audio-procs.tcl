ad_library {
    Audios Library

    @author Iuri Sampaio <iuri.sampaio@gmail.com>
    @date 2010-11-23
}

namespace eval audios {}



ad_proc -public audios::get_group_options {
} { 
    Returns community and subsite options to a select widget
} {
    
    set subsites [db_list_of_lists select_subsites {
	select instance_name, package_id
	from apm_packages ap
	where package_key = 'acs-subsite'
	order by lower(instance_name)
    }]
    
    set dotlrn_p [apm_package_installed_p dotlrn]
    if {$dotlrn_p} {
	#get communities and subsites
	
	set communities [db_list_of_lists select_communities {
	    select pretty_name, community_id
	    from dotlrn_communities 
	    where archived_p = 'f'
	    order by lower(pretty_name)

	}]
			
	
	lappend $subsites $communities
    }

    return $subsites
}


    



ad_proc -public audios::new {
    {-item_id ""}
    {-filename:required}
    {-tmp_filename:required}
    {-name:required}
    {-description}
    {-date}
    {-group_id}
    {-author}
    {-coauthor}
    {-source}    
} {
    create a new audios
} {

    set new_audio 0
    set suggest_name [lang::util::suggest_key $name]
    set guessed_file_type [ns_guesstype $filename]
    set n_bytes [file size $tmp_filename]

    ns_log Notice "Running API audios::new"
#    ns_log Notice "$filename \n $tmp_filename \n $name \n $description \n" 
 #   ns_log Notice "$date \n $group_id \n $author \n $coauthor \n $source"
  #  ns_log Notice "$guessed_file_type \n $n_bytes"
    
    # Create a new item/audio
    if {![exists_and_not_null item_id]} {
	set item_id [db_nextval "acs_object_id_seq"]
	set new_audio 1
    
	set package_id [ad_conn package_id]
	set creation_user [ad_conn user_id]
	set creation_ip [ad_conn peeraddr]
	

	content::item::new \
	    -item_id $item_id \
	    -name "audio$item_id-$filename" \
	    -parent_id $package_id \
	    -content_type audio_object \
	    -package_id $package_id \
	    -creation_user $creation_user \
	    -creation_ip $creation_ip
    } else {
	db_1row select_info {
	    SELECT package_id, creation_user, creation_ip FROM acs_objects o WHERE object_id = :item_id
	}
    }   
 
    set revision_id [cr_import_content \
                         -item_id $item_id \
                         -storage_type file \
                         -creation_user $creation_user \
			 -creation_ip $creation_ip \
                         -description $description \
                         -package_id $package_id \
			 -title $filename \
                         $package_id \
                         $tmp_filename \
                         $n_bytes \
                         $guessed_file_type \
                         audio-$package_id-$creation_user-$suggest_name-$n_bytes]
    
    item::publish -item_id $item_id -revision_id $revision_id

    
    if {$new_audio} {
	db_exec_plsql insert_audio {}
	permission::grant -party_id $creation_user -object_id $item_id -privilege admin
    } 

    file delete $tmp_filename
    file delete $filename


    # put video in queue to convert to a mpeg format 
    if {$guessed_file_type != "audio/mpeg"} {
	audios::insert_audio_queue -item_id $item_id
    }

    lappend tags $name
    lappend tags $source
    foreach tag $tags {
	db_dml create_tag {}
    }
    

    return $item_id
}


ad_proc -public audios::edit {
    {-item_id ""}
    {-filename:required}
    {-tmp_filename:required}
    {-name:required}
    {-description}
    {-date}
    {-group_id}
    {-author}
    {-coauthor}
    {-source}    
} { 
    Edit audio information
} {
    if {[exists_and_not_null filename]} {
	set audio_id [audios::new \
			  -filename $filename \
			  -tmp_filename $tmp_filename \
			  -item_id $item_id \
			  -name $name \
			  -description $description \
			  -date $date \
			  -group_id $group_id \
			  -author $author \
			  -coauthor $coauthor \
			  -source $source]
    }
    
	
	
    db_dml update_audio {}
    
    return 0
}


ad_proc -public audios::convert {
    {-item_id:required}
} {
    convert audio to mpeg
} {

    ns_log Notice "Running API audios::convert"
	#try a different bitrate if the previous convert didn't work
	set convert_time_bit_rate [nsv_incr audios convert_time 20]
	set bitrate [expr 320 - $convert_time_bit_rate]
	ns_log notice "bitrate complete!!"
	ns_log Notice "BIT RATE: $convert_time_bit_rate - $bitrate"

	set path [cr_fs_path CR_FILES]
	set revision_id [db_string get_live_revision ""]
	set filename [db_string write_file_content ""]

	set audio_filename "audio-[ns_rand 1000000].mp3"
	set audio_tmp_filename "/tmp/$audio_filename"

	# Reference http://fosswire.com/post/2007/11/using-ffmpeg-to-convert-to-mp3/
	#http://howto-pages.org/ffmpeg/
	# http://www.postgresql.org/docs/8.0/static/datatype-datetime.html
	#http://howto-pages.org/ffmpeg/
	#http://www.ussventure.eng.br/LCARS-Terminal_net_arquivos/download/down.htm

	ns_log Notice "$filename | $audio_filename | $audio_tmp_filename"
	if {![catch {exec lame $filename $audio_tmp_filename} errorMsg]} {
	    ns_log Notice "ERROR: $errorMsg"
	    # delete a temporary video file
	    # file delete $audio_tmp_filename
	} else {
				
	    #start insert video
	    
	    audios::get -item_id $item_id -array orig_audio

	    ns_log Notice " $audio_tmp_filename \n
    $audio_filename \n
    -name $orig_audio(audio_name) \n
    -description $orig_audio(audio_description) \n
    -date $orig_audio(audio_date) \n
    -group_id $orig_audio(group_id) \n
    -author $orig_audio(author) \n
    -coauthor $orig_audio(coauthor) \n
    -source $orig_audio(source)"



	    #exec flvtool2 -U $video_tmp_filename	
	    audios::new -tmp_filename $audio_tmp_filename \
		-filename $audio_filename \
		-item_id $item_id \
		-name $orig_audio(audio_name) \
		-description $orig_audio(audio_description) \
		-date $orig_audio(audio_date) \
		-group_id $orig_audio(group_id) \
		-author $orig_audio(author) \
		-coauthor $orig_audio(coauthor) \
		-source $orig_audio(source) 
	}

	file delete $audio_tmp_filename

	audios::delete_audio_queue -item_id $item_id	
	nsv_incr audios convert_time $bitrate
}


ad_proc -public audios::insert_audio_queue {
    -item_id:required
} {
    This proc add audio into queue to convert. 
} {
 	db_dml insert_audio_queue {}

}

ad_proc -public audios::delete_audio_queue {
    -item_id:required
} {
    This proc add audio into queue to convert. 
} {
 	db_dml delete_audio_queue {}

}



ad_proc -public audios::convert_queue {} {
    This proc retrieves a audio. 
} {
    ns_log Notice "Running API audios::convert_queue"
    set items_id [db_list select_queue {select item_id from audio_queue}]
    ns_log Notice "$items_id"
    foreach item_id $items_id {
	audios::convert -item_id $item_id
    }

}

ad_proc -public audios::get {
    -item_id:required
    -array:required
} {
    This proc retrieves anm audio.
} {
    upvar 1 $array row
    db_1row select_audio {} -column_array row
}





ad_proc -public audios::download_counter {
    -user_id
    -package_id
    -revision_id
    -audio_id
} {
    @author iuri sampaio (iuri.sampaio@gmail.com)
    @creation-date 2010-10-19
} {

    set total [db_list count_audio_id {
	select count(*) from audio_rank where item_id = :audio_id
    }]

   if {![exists_and_not_null total]} { 
       incr $total
   }

    db_dml count_download {
	insert into audio_rank (item_id,rank)
	values (:audio_id,:total)
    }
}

namespace eval videos::notification {}

ad_proc -public videos::notification::get_url {
    object_id
} {
    returns a full url to the object_id.
    handles videos and video item.
} { 
    
    db_1row select_object_type {
	select object_type from acs_objects where object_id = :object_id
    }
    

    if {[string equal $object_type "apm_package"]} {
	set package_url [db_list select_url {
	    select site_node__url(node_id) from site_nodes where object_id  = :object_id
	}]
	
	return ${package_url}
    }

    if {[string equal $object_type "content_item"]} {
	set package_url [db_exec_plsql select_videos_package_url {}]
	return ${package_url}videos-view?video_id=$object_id
    }
    
	
    
}





ad_proc -public audios::from_sql_datetime {
    {-sql_date:required}
    {-format:required}
} {
    
} {
    # for now, we recognize only "YYYY-MM-DD" "HH12:MIam" and "HH24:MI". 
    set date [template::util::date::create]

    switch -exact -- $format {
        {YYYY-MM-DD} {
            regexp {([0-9]*)-([0-9]*)-([0-9]*)} $sql_date all year month day

            set date [template::util::date::set_property format $date {DD MONTH YYYY}]
            set date [template::util::date::set_property year $date $year]
            set date [template::util::date::set_property month $date $month]
            set date [template::util::date::set_property day $date $day]
        }

        {HH12:MIam} {
            regexp {([0-9]*):([0-9]*) *([aApP][mM])} $sql_date all hours minutes ampm
            
            set date [template::util::date::set_property format $date {HH12:MI am}]
            set date [template::util::date::set_property hours $date $hours]
            set date [template::util::date::set_property minutes $date $minutes]                
            set date [template::util::date::set_property ampm $date [string tolower $ampm]]
        }

        {HH24:MI} {
            regexp {([0-9]*):([0-9]*)} $sql_date all hours minutes

            set date [template::util::date::set_property format $date {HH24:MI}]
            set date [template::util::date::set_property hours $date $hours]
            set date [template::util::date::set_property minutes $date $minutes]
        }

        {HH24} {
            set date [template::util::date::set_property format $date {HH24:MI}]
            set date [template::util::date::set_property hours $date $sql_date]
            set date [template::util::date::set_property minutes $date 0]
        }
        default {
            set date [template::util::date::set_property ansi $date $sql_date]
        }
    }

    return $date
}




ad_proc -public audios::create_xml {
    -item_id
} {
    Create an xml file with information of the item

} {


    
# ---------------------------------------------------------------
# Create the XML
# ---------------------------------------------------------------
    
# ---------------------------------------------------------------
# Project node

    set doc [dom createDocument audio_item]
    set root_node [$doc documentElement]
    

# minimal set of elements in case this hasn't been imported before
    if {![info exists xml_elements] || [llength $xml_elements]==0} {
	set xml_elements {src src_large src_center src_left src_right title subtitle}
    }
    




# ---------------------------------------------------------------
# Get information about the audio item
# ---------------------------------------------------------------

    
    foreach photo_id $photo_ids {
	
	photo_album::photo::get -photo_id $photo_id -array photo
    
	set photo_node [$doc createElement photo]
	$root_node appendChild $photo_node
	
	foreach element $xml_elements { 
	        
	    switch $element {
		"src"            { set value $photo(title) }
		"src_large"      { set value $photo(viewer_content) }
		"src_center"     { set value $photo(thumb_content) }
		"src_left"       { set value $photo(left_thumb_content) }
		"src_right"      { set value $photo(right_thumb_content) }
		"title"          { set value $photo(title) }
		"subtitle"       { set value "$photo(description)<br> $photo(username)" }
		default {
		    set attribute_name [plsql_utility::generate_oracle_name "xml_$element"]
		    set value [expr $$attribute_name]
		}
	    }
	        
	        # the following does "<$element>$value</$element>"
	    $photo_node appendFromList [list $element {} [list [list \#text $value]]]
	}
    }
    
    
    set xml_content "<?xml version=\"1.0\" encoding=\"UTF-8\"?>[$doc asXML -indent 2 -escapeNonASCII]"
    set xml_filename "/var/lib/aolserver/trunk2/packages/photo-album/www/resources/xml/photos-temp.xml"
    set fp [open $xml_filename w]
    puts $fp $xml_content
    close $fp  


    if {[file isfile $xml_filename]} { 
	return 1;
    } 
    
    return 0;
    
}
