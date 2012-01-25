ad_page_contract {
    This is a index to list videos
    
    @author iuri sampaio
    @creation_date 2010-12-13
} {
    {keyword ""}
    {return_url ""}
} 
set user_id [ad_conn user_id]
set package_id [ad_conn package_id]
set object_id [ad_conn object_id]



# String search
if {$keyword ne ""} {
        set query "AND a.audio_id IN (SELECT item_id FROM tags_tags WHERE tag = :keyword OR lower(tag) = :keyword)"
} else {
        set query ""
}



permission::require_permission -party_id [ad_conn user_id] -object_id $package_id -privilege read

set form_action_url "/videos/"
set admin_p [permission::permission_p -party_id [ad_conn user_id] -object_id [ad_conn package_id] -privilege admin]
set action_list [list]



if {$admin_p eq 1} {
    set action_list {"#audios.New#" audio-ae "#audios.New#"}
}


set image_size [parameter::get -package_id $package_id -parameter ImageSize]
set widthxheight [split $image_size "x"]
set width [lindex $widthxheight 0]
set height [lindex $widthxheight 1]
if {$width > 500} {
    set width [expr $width - 200]
}

set audio_category_options [list Governo Empresa]

set list_elements {
    image {
	label " "
	    display_template {
		<a href="@audios.url@audios-view?audio_id=@audios.audio_id@">
		<img  width="50px" src="@audios.image_audio_url@"></a>
	    }
    }
    name {
	label "#audios.Name#"
	display_template {
	    <a href="@audios.url@audios-view?audio_id=@audios.audio_id@">
	    @audios.audio_name@</a>
	}
    }
    autor {
	label "#audios.Author#"
	display_template {
	    @audios.author@
	}
    }
    description {
	label "#audios.Description#"
	display_template {
	    @audios.audio_description@
	}
    }
}


ns_log Notice "ELEMENTS: $list_elements"
#ns_log Notice "$package_id | [audios::get_categories -package_id $package_id]"

#variable lists to db_multirow
#set extend_list [list]

#foreach {category_id category_name } [audios::get_categories -package_id $package_id] {
 #   ns_log Notice "ITEM: $category_id - $category_name"

  #  lappend list_elements cat_${category_id} [list \
	#  label [category::get_name $category_id] \
	#  display_col cat_$category_id]


#    lappend extend_list "cat_${category_id}"

#}

#ns_log Notice "ELEMENTS: $list_elements"




template::list::create \
    -name audios \
    -multirow audios \
    -key audio_id \
    -actions $action_list \
    -pass_properties {
    } -elements $list_elements \
    -orderby {
	name {
            label "[_ audios.Name]"
            orderby_desc "v.audio_name desc"
            orderby_asc "v.audio_name"
            default_direction "desc"
        }
	autor {
	    label "[_ audios.Author]"
	    orderby "v.autor desc"
	}
    }


set extend_list "image_audio_url"
db_multirow -extend $extend_list audios select_audios {} {

    set image_audio_url "/resources/audios/audio_"
    switch $mime_type {
	audio/x-wav {
	    append image_audio_url "wav.gif"
	}
	audio/wma {
	    append image_audio_url "wma.gif"
	}
	audio/mpeg {
	    append image_audio_url "mpeg.gif"
	}
	default {
	    append image_audio_url "generic.gif"
	}
    }


#    foreach {category_id category_name} [audios::get_categories -package_id $package_id] {
	#ns_log Notice "$category_id | $category_name"
	#set cat_${category_id} [category::get_name [audios::get_category_child_mapped -category_id $category_id -object_id $audio_id]]
	
#    }
}

# User's search form 
                                                                                                                                       
ad_form -name search -export {} -action [ad_conn url] -form {
    {keyword:text(text),optional {label "[_ audios.Search]"} }
}

