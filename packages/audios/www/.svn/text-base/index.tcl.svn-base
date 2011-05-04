ad_page_contract {
    list of videos
    
    @author iuri sampaio (iuri.sampaio@gmail.com)
    @date 2010-11-22
} {
    {keyword ""}
} 

set user_id [ad_conn user_id]
set package_id [ad_conn package_id]
set object_id [ad_conn object_id]
set return_url [ad_return_url]

set admin_p [permission::permission_p -party_id $user_id -object_id $package_id -privilege admin]
set add_audio_url [export_vars -base audio-ae {return_url}]

# Video's search form 
ad_form -name search -export {} -action list -form {
    {return_url:text(hidden) {value $return_url}}
    {keyword:text(text),optional {label "[_ audios.Search]"} }
}


set notification_chunk [notification::display::request_widget \
    -type audios_audio_notif \
    -object_id $package_id \
    -pretty_name "Audios" \
    -url [ad_conn url]?object_id=$package_id \
]


set type_id [notification::type::get_type_id -short_name audios_audio_notif]

set notification_count [notification::request::request_count \
			    -type_id $type_id \
			    -object_id $package_id]




#variable lists to db_multirow
set extend_list "image_audio_url"

db_multirow -extend $extend_list recent_audios select_recent_audios {} { 
    set image_audio_url "/resources/audios/audio_"
    switch $mime_type {

	audio/mpeg { 
	    append image_audio_url "mpeg.gif"
	}
	audio/ogg { 
	    append image_audio_url "ogg.gif"
	}
	audio/wma { 
	    append image_audio_url "wma.gif"
	}
	audio/x-wav { 
	    append image_audio_url "wav.gif"
	}
	default {
	    append image_audio_url "generic.gif"
	}
    }

}

db_multirow -extend $extend_list popular_audios select_popular_audios {} { 
    set image_audio_url "/resources/audios/audio_"
    switch $mime_type {

	audio/mpeg { 
	    append image_audio_url "mpeg.gif"
	}
	audio/ogg { 
	    append image_audio_url "ogg.gif"
	}
	audio/wma { 
	    append image_audio_url "wma.gif"
	}
	audio/x-wav { 
	    append image_audio_url "wav.gif"
	}
	default {
	    append image_audio_url "generic.gif"
	}
    }
}

db_multirow -extend $extend_list audios select_audios {} { 
    set image_audio_url "/resources/audios/audio_"
    switch $mime_type {

	audio/mpeg { 
	    append image_audio_url "mpeg.gif"
	}
	audio/ogg { 
	    append image_audio_url "ogg.gif"
	}
	audio/wma { 
	    append image_audio_url "wma.gif"
	}
	audio/x-wav { 
	    append image_audio_url "wav.gif"
	}
	default {
	    append image_audio_url "generic.gif"
	}
    }
}
