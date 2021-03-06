ad_library {
    Binaries conversion procedures for the search package.
    Thanks to Carsten Clasohm for suggesting the converter programs.

    @author Dirk Gomez <openacs@dirkgomez.de>
    @creation-date 2005-06-25
    @cvs-id $Id: search-convert-procs.tcl,v 1.5.2.1 2019/05/24 13:45:42 antoniop Exp $
}


namespace eval search {}
namespace eval search::convert {}

ad_proc -public search::convert::binary_to_text {
    {-filename:required}
    {-mime_type:required}
} {
    Converts the binary file to text and returns this as a string.
    (Carsten Clasohm provided the converters.)

    @author Dirk Gomez <openacs@dirkgomez.de>
    @creation-date 2005-06-25
} {

    if {[file size $filename] == 0} {
        #
        # Some conversion programs choke on empty content
        #
        return ""
    }

    set tmp_filename [ad_tmpnam]
    set result ""

    switch $mime_type {
        application/msword -
        application/vnd.ms-word {
            set convert_command {catdoc $filename >$tmp_filename}
        }
        application/msexcel -
        application/vnd.ms-excel {
            set convert_command {xls2csv $filename >$tmp_filename 2> /dev/null}
        }
        application/mspowerpoint -
        application/vnd.ms-powerpoint {
            set convert_command {catppt $filename >$tmp_filename}
        }
        application/pdf {
            set convert_command {pdftotext $filename $tmp_filename}
        }
        application/vnd.oasis.opendocument.text -
        application/vnd.oasis.opendocument.text-template -
        application/vnd.oasis.opendocument.text-web -
        application/vnd.oasis.opendocument.text-master -
        application/vnd.oasis.opendocument.presentation -
        application/vnd.oasis.opendocument.presentation-template -
        application/vnd.oasis.opendocument.spreadsheet -
        application/vnd.oasis.opendocument.spreadsheet-template {
            set convert_command {unzip -p $filename content.xml >$tmp_filename}
        }
        text/html {
	    file delete -- $tmp_filename
	    #
	    # Reading the whole content into memory is not necessarily
	    # the best when dealing with huge files. However, for
	    # html-files this is probably ok.
	    #
            return [ns_striphtml [template::util::read_file $filename]]
        }
        text/plain {
	    file delete -- $tmp_filename
	    #
	    # Reading the whole content into memory is not necessarily
	    # the best when dealing with huge files. However, for
	    # txt-files this is probably ok.
	    #
	    return [template::util::read_file $filename]
        }

        default {
            # If there's nothing implemented for a particular mime type
            # we'll just index filename and pathname
            return ""
        }
    }

    ad_try {
        set convert_command [subst $convert_command]
        exec -- {*}$convert_command
    } on error {errorMsg} {
        if {$mime_type eq "application/pdf" &&
            [string first $errorMsg "Command Line Error: Incorrect password"] >= 0} {
            ns_log warning "SEARCH: pdf seems password protected - $convert_command"
        } else {
            ns_log error "SEARCH: conversion failed - $convert_command: $errorMsg"
        }
    } on ok {d} {
        set fd [open $tmp_filename "r"]
        set result [read $fd]
        close $fd
    } finally {
        file delete -- $tmp_filename
    }

    return $result
}



# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
