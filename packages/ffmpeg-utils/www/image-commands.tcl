ad_page_contract {

    @author Iuri Sampaio (iuri.sampaio@iurix.com)
    @creation-date 2011-11-02
} {
    {msg ""}
}



template::head::add_css -href "/resources/ffmpeg-utils/ffmpeg-utils.css"
template::head::add_javascript -src "/resources/ffmpeg-utils/jquery.js" -order 0
template::head::add_javascript -src "/resources/ffmpeg-utils/showhide.js" -order 1


ad_form -name info -html { enctype multipart/form-data } -form {
    {input_file:file 
	{label \#ffmpeg-utils.Upload_a_file\#} {html "size 30"}
    }
} -on_submit {
    ns_log Notice "$input_file"

    set ifile [list [template::util::file::get_property filename $input_file]]
    set tmpfile [list [template::util::file::get_property tmp_filename $input_file]]
    

    # Still needs to fix ffmpeg command line
    if {![catch {[exec ffmpeg -i $tmpfile]} errorMsg]} {
	ns_log Notice "Error in attempt to read file!" 
    } else {
	set msg [exec ffmpeg -i $tmpfile]
    }
}




ad_form -name scale -html { enctype multipart/form-data } -form {
    {input_file:file 
	{label \#ffmpeg-utils.Upload_a_file\#} {html "size 30"}
    }
} -on_submit {

    # Still needs to fix ffmpeg command line
    if {![catch {[exec ffmpeg -s $origin_resol $final_resol]} errorMsg]} {
	ns_log Notice "Error in attempt to convert!" 
    } else {
	#return the re-scaled file to the user
	ns_return 200 application/octet-stream $output_file
    }
}

