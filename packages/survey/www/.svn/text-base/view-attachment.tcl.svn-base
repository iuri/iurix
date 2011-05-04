ad_page_contract {

  View the attachment contents of a given response.
  This page has been modified to use the CR for attachment storage dave@thedesignexperience.org
  
  @param  response_id  id of complete survey response submitted by user
  @param  question_id  id of question for which this file was submitted as an answer

  
  @author jbank@arsdigita.com
  @author nstrug@arsdigita.com
  @date   28th September 2000
  @cvs-id $Id: view-attachment.tcl,v 1.2 2003/03/12 01:05:39 daveb Exp $
} {

  response_id:integer,notnull
  question_id:integer,notnull

} -validate {
    attachment_exists -requires {response_id question_id} {
	db_1row get_file_info {}

	if { [empty_string_p $file_type] } {
	    ad_complain "[_ survey.lt_Couldnt_find_attachment]"
	}
    }
}

ReturnHeaders $file_type

cr_write_content -revision_id $revision_id


