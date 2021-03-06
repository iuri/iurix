ad_page_contract {} {
    input_file:trim,optional
    input_file.tmpfile:tmpfile,optional
}
# -validate {
#    max_size -requires {input_file} {
#	set n_bytes [file size ${input_file.tmpfile}]
#	if { $n_bytes > 10024} {
#	    ad_complain "Your file is larger than the maximum file size allowed on this system ([util_commify_number $n_bytes] bytes)"
#	    ad_script_abort
#	}
#    }
#    empty_size -requires {input_file} {
#	set n_bytes [file size ${input_file.tmpfile}]
#	if { $n_bytes eq 0} {
#	    ad_complain "Your file is empty!"
#	}
#   }
#}

auth::require_login

ad_form -name new -html {enctype multipart/form-data} -form {
    {inform:text(inform) {label ""} {value "<h1>Upload new JSON data</h1>"}}
    {input_file:file {label "JSON file"}}

} -on_submit {

    # to get old_file's filesize
    set filesize [file size ${input_file.tmpfile}]
    # to get new_file's filesize is greater than 0 
    
    # to open files and assign them address to their respective variables: f1 and f2. Given read permissions only!
    set f1 [open ${input_file.tmpfile} r]
    
    # to read file streams and assign their content to new variables: lines1 and lines2
    set json [read $f1]

 #   ns_log Notice "JSON \n $json"
    ctree::import_json -jsonText $json
    
    
    # Releasing memory, delete and unset files and variables
    file delete -- ${input_file.tmpfile}

    # unset f1 unset f2 unset lines1 unset lines2
    # once execution is completed, finish it
    
    ad_returnredirect index
    # ad_script_abort


}




