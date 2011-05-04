# /packages/photo-album/www/photo-create-xml.tcl
#
# ---------------------------------------------------------------
# Page Contract
# ---------------------------------------------------------------

ad_page_contract {
    Create a Photo XML structure for a album

    @author iuri.sampaio@gmail.com
} {
    {album_id}
}

# ---------------------------------------------------------------
# Defaults & Security
# ---------------------------------------------------------------

set today [db_string today "select to_char(now(), 'YYYY-MM-DD')"]



# ---------------------------------------------------------------
# Create the XML
# ---------------------------------------------------------------

# ---------------------------------------------------------------
# Project node

set doc [dom createDocument photogallery]
set root_node [$doc documentElement]

#$root_node setAttribute xmlns "http://schemas.microsoft.com/project"



# minimal set of elements in case this hasn't been imported before
if {![info exists xml_elements] || [llength $xml_elements]==0} {
    set xml_elements {src src_large src_center src_left src_right title subtitle}
   # set xml_elements {src title subtitle}
}





# ---------------------------------------------------------------
# Get information about the photos
# ---------------------------------------------------------------

#set photo_ids [db_list select_photos "SELECT item_id from cr_items where content_type = 'pa_photo'"]
set photo_ids [pa_all_photos_in_album $album_id]

ns_log Notice "$photo_ids [llength $photo_ids]"
foreach photo_id $photo_ids {
    #    ns_log Notice "$photo_id"
    
    photo_album::photo::get -photo_id $photo_id -array photo
     #ns_log Notice "[parray photo]"
    
    
    
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

#ns_return 200 application/octet-stream "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>[$doc asXML -indent 2 -escapeNonASCII]"
ns_return 200 application/octet-stream "<?xml version=\"1.0\" encoding=\"UTF-8\"?>[$doc asXML -indent 2 -escapeNonASCII]"