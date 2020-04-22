ad_page_contract {} {
    file_old:trim,optional
    file_old.tmpfile:tmpfile,optional
    file_new:trim,optional
    file_new.tmpfile:tmpfile,optional
} -validate {
    max_size1 -requires {file_old} {
	set n_bytes [file size ${file_old.tmpfile}]
	if { $n_bytes > 1024} {
	    ad_complain "Your file is larger than the maximum file size allowed on this system ([util_commify_number $max_bytes] bytes)"
	    ad_script_abort
	}
    }
    max_size2 -requires {file_new} {
	set n_bytes [file size ${file_new.tmpfile}]
	if { $n_bytes > 1024} {
	    ad_complain "Your file is larger than the maximum file size allowed on this system ([util_commify_number 1024] bytes)"
	    ad_script_abort
	}
    }
    empty_size1 -requires {file_old} {
	set n_bytes [file size ${file_old.tmpfile}]
	if { $n_bytes eq 0} {
	    ad_complain "Your file is empty!"
	}
    }
    empty_size2 -requires {file_new} {
	set n_bytes [file size ${file_new.tmpfile}]
	if { $n_bytes eq 0} {
	    ad_complain "Your file is empty!"
	}
    }
}


ad_form -name filediff -html {enctype multipart/form-data} -form {
    {inform:text(inform) {label ""}  {value "<h1>File diff<h1/>"}}
    {file_old:file {label "Upload old file"} {html "size 30"}}
    {file_new:file {label "Upload new file"} {html "size 30"}}    
} -on_submit {

    # to get old_file's filesize
    set filesize1 [file size ${file_old.tmpfile}]
    # to get new_file's filesize is greater than 0 
    set filesize2 [file size ${file_new.tmpfile}]
    
    # to open files and assign them address to their respective variables: f1 and f2. Given read permissions only!
    set f1 [open ${file_old.tmpfile} r]
    set f2 [open ${file_new.tmpfile} r]
    
    # to read file streams and assign their content to new variables: lines1 and lines2
    set lines1 [split [read $f1] "\n"]
    set lines2 [split [read $f2] "\n"]

    # if old file is empty, thus the whole content of new file is returned.    
    if {$filesize1 eq 0 && $filesize2 > 0} {
	foreach line $lines2 {
	    if {[exists_and_not_null line]} {
		append output "+ $line \n"
	    }
	}
	# output result to the user, as a plain text file
	doc_return 200 file/plain $output
    }

    # it creates an auxiliar list to store line2 values temporarily
    set l2 [list] 
    foreach line1 $lines1 line2 $lines2 {
	if { [string equal $line1 $line2] } { # if lines are equal
	    if { $line1 eq "" } { # but if they are null ...
		# it appends the first line of the auxiliar list in the output variable
		append output "  [lindex $l2 0] \n"
		# it removes the first line from auxiliar list
		set l2 [lreplace $l2 0 0]
	    } else { # lines are equal and not null
		# it appends line1 in the output variable
		append output "  $line1 \n"
	    }
	} else { # lines are different
	    # it stores the line of file_new, temporarily, in a auxiliar list
	    lappend l2 $line2
	    if { $line1 ne "" } { # line1 is not null and it's different from line2 
		# it appends line1 in the output variable
		append output "- $line1 \n"
	    } else { # whether line2 is null or not, it always output what is in position of auxliar list. Because line1 is null
	       	# To append line1 the first line of the auxiliar list in the outpyt variable
		append output "+ [lindex $l2 0] \n"
		# To remove the first line of the auxiliar list
		set l2 [lreplace $l2 0 0]		
	    }
	}
    }
    # Returning the output variable to the user, as a plain text file
    doc_return 200 file/plain $output

    # Releasing memory, delete and unset files and variables
    file delete -- ${file_old.tmpfile}
    file delete -- ${file_new.tmpfile}
    unset f1 unset f2 unset line1 unset line2  unset lines1 unset lines2 unset output unset l2 unset output

    # once execution is completed, finish it
    ad_script_abort


}

    
    
