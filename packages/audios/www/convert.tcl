set audio_ids [db_list select_audio_ids { select audio_id from audios}]
ns_log Notice "$audio_ids"

foreach id $audio_ids {
    db_1row select_audio {select * from audios where audio_id = :id} -column_array orig_audio
#audios::get -item_id 29415716 -array orig_audio

ns_log Notice "
    -name $orig_audio(audio_name) \n
    -description $orig_audio(audio_description) \n
    -date $orig_audio(audio_date) \n
    -group_id $orig_audio(group_id) \n
    -author $orig_audio(author) \n
    -coauthor $orig_audio(coauthor) \n
    -source $orig_audio(source)"


    set path [cr_fs_path CR_FILES]
    
    set revision_id [db_string live_revision {
	select revision_id
	from cr_revisions
	where item_id = :id
	order by revision_id asc
	limit 1
    }]

    
    set filename [db_string write_file_content {
	select :path || content
	from cr_revisions
	where revision_id = :revision_id
    }]

    ns_log Notice "$filename"
    set audio_filename "audio-[ns_rand 1000000].mp3"
    set audio_tmp_filename "/tmp/$audio_filename"

    if {[catch {exec lame $filename $audio_tmp_filename} errorMsg]} {
	ns_log Notice "ERROR: $errorMsg"
    } else {
	ns_log Notice "File converted"
    }	
}

	# Reference http://fosswire.com/post/2007/11/using-ffmpeg-to-convert-to-mp3/
	#http://howto-pages.org/ffmpeg/
	# http://www.postgresql.org/docs/8.0/static/datatype-datetime.html
	#http://howto-pages.org/ffmpeg/
	#http://www.ussventure.eng.br/LCARS-Terminal_net_arquivos/download/down.htm

#ns_log Notice "$filename | $audio_filename | $audio_tmp_filename"
#catch {exec ffmpeg -i $filename -acodec libfaac -ab 32k -vcodec libx264  -b ${bitrate}k -threads 0 $audio_tmp_filename} errorMsg
	    # delete a temporary video file
	    # file delete $audio_tmp_filename
