ad_library {

    iurix-mail package API

    @author Iuri Sampaio (iuri.sampaio@iurix.com)
    @creation-date 2011-09-30
}


namespace eval iurix_mail {}

ad_proc -public iurix_mail::get_package_id {} {

    Returns iurix-mail package_id

} {

    return [db_string select_package_id {
	SELECT package_id FROM apm_packages WHERE package_key = 'iurix-mail'
    }]
}


ad_proc -public iurix_mail::new {
    {-user_id ""}
    {-largs}
    {-type "new"}
    {-subject ""}
    {-bodies ""}
    {-files ""}
    {-date ""}
    {-to ""}
    {-from ""}
    {-delivered_to ""}
    {-importance ""}
    {-dkim_signature ""}
    {-headers ""}
    {-message_id ""}
    {-received ""} 
    {-return_path ""}
    {-x_mailer ""}
    {-x_original_to ""}
    {-x_original_arrival_time ""}
    {-x_originating_ip ""}
    {-x_priority ""}
} {
    
    Create a new message
} {


    foreach arg $largs {
	set [string map {- _} [string trimleft [lindex $arg 0] "-"]] "[lindex $arg 1]"	
    }


    if {[string equal bodies "text/html"]} {
	set body [ad_html_to_text -- [lindex $bodies(1)]]
    } else {
	set body [lindex $bodies 1]
    }
    
    set mail_id [db_nextval acs_object_id_seq]
    set package_id [iurix_mail::get_package_id]
  

#    set date [clock scan $date -base $t -gmt t]
    set date [clock format [clock scan $date -base [ns_time] -gmt t] -format "%D %H:%M:%S" -gmt t]


    ns_log Notice "MAILID $mail_id"

    db_transaction {
	content::item::new \
	    -item_id $mail_id \
	    -name "mail: $message_id" \
	    -parent_id $package_id \
	    -content_type "mail_object" \
	    -package_id $package_id \
	    -creation_user $user_id \
	    -creation_ip "0.0.0.0"
	
	
	if {[exists_and_not_null files]} {
	    ns_log Notice "FILE ATTACHED"
	    
	    # Email's Attachments 
	    foreach f $files {
		set mime_type [lindex $f 0]
		#set file_size [lindex $f 1]
		set filename [lindex $f 2]
		set fcontent [lindex $f 3]
		
		set tmp_file [ns_tmpnam]

		ns_log Notice "TMP-FILE $tmp_file"
		
		set fd [open $tmp_file w]
		puts $fd $fcontent
		close $fd
		
		set file_size [file size $tmp_file]

		set revision_id [cr_import_content \
				     -item_id $mail_id \
				     -storage_type file \
				     -description "attachment: $message_id" \
				     -creation_user $user_id \
				     -creation_ip "0.0.0.0" \
				     -package_id $package_id \
				     $package_id \
				     $tmp_file \
				     $file_size \
				     $mime_type \
				     $filename]
		
		ns_log Notice "REVISION $revision_id"
		item::publish -item_id $mail_id -revision_id $revision_id
	    }
	}
	
	
	db_exec_plsql insert_mail {
	    SELECT iurix_mails__new (
				     :mail_id,
				     :package_id,
				     :user_id,
				     :type,
				     :subject,
				     :bodies,
				     :date,
				     :to,
				     :from,
				     :delivered_to,
				     :importance,
				     :dkim_signature,
				     :headers,
				     :message_id,
				     :received,
				     :return_path,
				     :x_mailer,
				     :x_original_to,
				     :x_original_arrival_time,
				     :x_originating_ip,
				     :x_priority
	     );	    
	}
    }	
    return $mail_id
}

