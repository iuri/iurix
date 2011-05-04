ad_page_contract {

    Insert user response into database.
    This page receives an input for each question named
    response_to_question.$question_id 

    @param   section_id             survey user is responding to
    @param   return_url            optional redirect address
    @param   group_id              
    @param   response_to_question  since form variables are now named as response_to_question.$question_id, this is actually array holding user responses to all survey questions.
    
    @author  jsc@arsdigita.com
    @author  nstrug@arsdigita.com
    @date    28th September 2000
    @cvs-id $Id: process-response.tcl,v 1.14 2005/03/01 00:01:44 jeffd Exp $

} {
  survey_id:integer
  section_id:integer
  {initial_response_id:integer 0}
  {response_id:integer 0}
  return_url:optional
  response_to_question:array,optional,multiple,html
  new_response_id:integer
} -validate {
    survey_exists -requires {survey_id} {
	if ![db_0or1row survey_exists {}] {
	    ad_complain "[_ survey.lt_Survey_survey_id_do_no]"
	}
    set user_id [auth::require_login]
    set number_of_responses [db_string count_responses {}]
    get_survey_info -survey_id $survey_id
    set single_section_p $survey_info(single_section_p)
        if {$section_id==0 && $single_section_p=="t"} {
            set section_id $survey_info(section_id)
        }
    set name [list $survey_info(name)]
    set description $survey_info(description)
    set description_html_p $survey_info(description_html_p)
    set single_response_p $survey_info(single_response_p)
    set editable_p $survey_info(editable_p)
    set display_type $survey_info(display_type)

   if {$description_html_p != "t"} {
       set description [ad_text_to_html $description]
   } 

   if {($single_response_p=="t" && $editable_p=="f" && $number_of_responses>0) || ($single_response_p=="t" && $editable_p=="t" && $number_of_responses>0 && $response_id==0)} {
	    ad_complain "[_ survey.lt_You_have_already_comp]"
	} elseif {$response_id>0 && $editable_p=="f"} {
	    ad_complain "[_ survey.lt_This_survey_is_not_ed]"
	}
    }

    section_exists -requires { section_id } {
	if ![db_0or1row section_exists {}] {
	    ad_complain "[_ survey.lt_Section_section_id_do]"
	}
    }



    check_questions -requires { section_id:integer } {

	set question_info_list [db_list_of_lists survey_question_info_list {
	    select question_id, question_text, abstract_data_type, presentation_type, required_p
	    from survey_questions
	    where section_id = :section_id
	    and active_p = 't'
	    order by sort_order
	}]
	    
	## Validate input.



	
	set questions_with_missing_responses [list]
	
	foreach question $question_info_list { 
	    set question_id [lindex $question 0]
	    set question_text [lindex $question 1]
	    set abstract_data_type [lindex $question 2]
	    set required_p [lindex $question 4]
	    
	    #  Need to clean-up after mess with :array,multiple flags
	    #  in ad_page_contract.  Because :multiple flag will sorround empty
	    #  strings and all multiword values with one level of curly braces {}
	    #  we need to get rid of them for almost any abstract_data_type
	    #  except 'choice', where this is intended behaviour.  Why bother
	    #  with :multiple flag at all?  Because otherwise we would lost all
	    #  but first value for 'choice' abstract_data_type - see ad_page_contract
	    #  doc and code for more info.
	    #
	    if { [exists_and_not_null response_to_question($question_id)] } {
			if {$abstract_data_type != "choice"} {
			    set response_to_question($question_id) [join $response_to_question($question_id)]
			} else {
			    if { [empty_string_p [lindex $response_to_question($question_id) 0 ] ] } {
				set response_to_question($question_id) ""
		    	}
				# Checa o número máximo de respostas
				set num_answers [llength $response_to_question($question_id)]
				set max_answers [db_string get_max_answers {}]
				if {$num_answers > $max_answers && $max_answers ne "" && $max_answers ne 0} {
					ad_complain "[_ survey.Max_number_answers]"
				}
	        }
	    }
	    
	    if { $abstract_data_type == "date" } {
		if [catch  { set response_to_question($question_id) [validate_ad_dateentrywidget "" response_to_question.$question_id [ns_getform]]} errmsg] {
		    ad_complain "$errmsg: [_ survey.lt_Please_make_sure_your]"
		}
	    }
	   
    
	    if { [exists_and_not_null response_to_question($question_id)] } {

		set response_value [string trim $response_to_question($question_id)]
	    } elseif {$required_p == "t"} {
		lappend questions_with_missing_responses $question_text
		continue
	    } else {
		set response_to_question($question_id) ""
		set response_value ""
	    }
	    
	    if {![empty_string_p $response_value]} {
		if { $abstract_data_type == "number" } {
		    if { ![regexp {^(-?[0-9]+\.)?[0-9]+$} $response_value] } {
			
			ad_complain "[_ survey.lt_The_response_to_ques_n]"
			continue
		    }
		} elseif { $abstract_data_type == "integer" } {
		    if { ![regexp {^[0-9]+$} $response_value] } {
			
			ad_complain "[_ survey.lt_The_response_to_ques_i]"
			continue
		}
		}
	    }
	    
	    if { $abstract_data_type == "blob" } {
                set tmp_filename $response_to_question($question_id.tmpfile)
		set n_bytes [file size $tmp_filename]
		if { $n_bytes == 0 && $required_p == "t" } {
		    
		    ad_complain "[_ survey.lt_Your_file_is_zero-len]"
		}
	    }
	    
	}
	
	if { [llength $questions_with_missing_responses] > 0 } {
	    ad_complain "[_ survey.lt_You_didnt_respond_to_]"
	    foreach skipped_question $questions_with_missing_responses {
		ad_complain $skipped_question
	    }
	    return 0
	} else {
	    return 1
	}
    }

} -properties {

    survey_name:onerow
}

ad_require_permission $survey_id survey_take_survey

set user_id [auth::require_login]

get_survey_info -survey_id $survey_id
set type $survey_info(type)
set survey_id $survey_info(survey_id)
set survey_name $survey_info(name)


# Do the inserts.
# here we need to decide if it is an edit or multiple response, and create
# a new response, possibly linked to a previous response.

# moved to respond.tcl for double-click protection
# set response_id [db_nextval acs_object_id_seq]

if {[db_string get_response_count {}] == 0} {

    set response_id $new_response_id

    set creation_ip [ad_conn peeraddr]
    if {$initial_response_id==0} {
	set initial_response_id ""
    }

    db_transaction {

	db_exec_plsql create_response {}

	set question_info_list [db_list_of_lists survey_question_info_list {} ]

	foreach question $question_info_list { 
	    set question_id [lindex $question 0]
	    set question_text [lindex $question 1]
	    set abstract_data_type [lindex $question 2]
	    set presentation_type [lindex $question 3]

	    set response_value [string trim $response_to_question($question_id)]

    #valida inicio
	set erro_cpf ""
	set cpf $response_value
	set question_id_cpf "2146521"

	#Valida CPF
        if { $question_id eq $question_id_cpf} {
 	        # Se tiver uma quantidade de dígitos diferente de 14, é inválido
 	        if {[string length $cpf] != 11} {
			        set erro_cpf ", CPF inválido"
 	                db_abort_transaction
 	        }
 	
 	        # Se for tudo igual é inválido
 	        if {$cpf eq "00000000000" || $cpf eq "11111111111" || $cpf eq "22222222222" ||
 	            $cpf eq "33333333333" || $cpf eq "44444444444" || $cpf eq "55555555555" ||
 	            $cpf eq "66666666666" || $cpf eq "77777777777" || $cpf eq "88888888888" ||
 	            $cpf eq "99999999999"
 	        } {
			        set erro_cpf ", CPF inválido"
 	                db_abort_transaction
 	        }
 	 
 	        # Início do cálculo do primeiro dígito verificador
 	        set soma 0
 	        set soma [expr $soma + [expr [string index $cpf 0] * 10]]
 	        set soma [expr $soma + [expr [string index $cpf 1] * 9]]
 	        set soma [expr $soma + [expr [string index $cpf 2] * 8]]
 	        set soma [expr $soma + [expr [string index $cpf 3] * 7]]
 	        set soma [expr $soma + [expr [string index $cpf 4] * 6]]
 	        set soma [expr $soma + [expr [string index $cpf 5] * 5]]
 	        set soma [expr $soma + [expr [string index $cpf 6] * 4]]
 	        set soma [expr $soma + [expr [string index $cpf 7] * 3]]
 	        set soma [expr $soma + [expr [string index $cpf 8] * 2]]
 	   
 	        set d1 [expr $soma % 11]
 	        set d1 [expr {$d1 < 2 ? 0 : 11 - $d1}]
 	
 	        # Início do cálculo do segundo dígito verificador
 	        set soma 0
 	        set soma [expr $soma + [expr [string index $cpf 0] * 11]]
 	        set soma [expr $soma + [expr [string index $cpf 1] * 10]]
 	        set soma [expr $soma + [expr [string index $cpf 2] * 9]]
 	        set soma [expr $soma + [expr [string index $cpf 3] * 8]]
 	        set soma [expr $soma + [expr [string index $cpf 4] * 7]]
 	        set soma [expr $soma + [expr [string index $cpf 5] * 6]]
 	        set soma [expr $soma + [expr [string index $cpf 6] * 5]]
 	        set soma [expr $soma + [expr [string index $cpf 7] * 4]]
 	        set soma [expr $soma + [expr [string index $cpf 8] * 3]]
 	        set soma [expr $soma + [expr $d1 * 2]]
 	       
 	        set d2 [expr $soma % 11]
 	        set d2 [expr {$d2 < 2 ? 0 : 11 - $d2}]
 	
 	        if {[string index $cpf 9] eq $d1 && [string index $cpf 10] eq $d2} {
 	                #OK
 	        } else {
			        set erro_cpf ", CPF inválido"
					db_abort_transaction
 	        }
		}

    
        if { $question_id eq $question_id_cpf} {
	      set existe [db_0or1row find_cpf {
		      select varchar_answer from survey_question_responses where question_id = :question_id_cpf and varchar_answer = :cpf
	      } -column_array resposta]
           #  set erro_cpf ", CPF já cadastrado1"
		#	 db_abort_transaction
	       if {$existe} {
		      # Erro de CPF já cadastrado
		      set erro_cpf ", CPF já cadastrado"
		      db_abort_transaction
	       }
		}
		#Valida CPf fim
 	

	#valida fim
	    switch -- $abstract_data_type {
		"choice" {
		    if { $presentation_type == "checkbox" } {
			# Deal with multiple responses. 
			set checked_responses $response_to_question($question_id)
			set num_answers_checked 0
			foreach response_value $checked_responses {
			    if { [empty_string_p $response_value] } {
				set response_value [db_null]
			    }
				# Check if the answer exists
				set answers_number [db_string find_equal_answers "select count(choice_id) from survey_question_responses where response_id = :response_id and question_id = :question_id and choice_id = :response_value" -default 0]
				if {$answers_number eq 0} {
				    db_dml survey_question_response_checkbox_insert "insert into survey_question_responses (response_id, question_id, choice_id)
 values (:response_id, :question_id, :response_value)"
 					incr num_answers_checked
				}
			}
		    }  else {
			if { [empty_string_p $response_value] || [empty_string_p [lindex $response_value 0]] } {
			    set response_value [db_null]
			}

			db_dml survey_question_response_choice_insert "insert into survey_question_responses (response_id, question_id, choice_id)
 values (:response_id, :question_id, :response_value)"
		    }
		}
		"shorttext" {
		    db_dml survey_question_choice_shorttext_insert "insert into survey_question_responses (response_id, question_id, varchar_answer)
 values (:response_id, :question_id, :response_value)"
		}
		"boolean" {
		    if { [empty_string_p $response_value] } {
			set response_value [db_null]
		    }

		    db_dml survey_question_response_boolean_insert "insert into survey_question_responses (response_id, question_id, boolean_answer)
 values (:response_id, :question_id, :response_value)"
		}
		"integer" -
		"number" {
		    if { [empty_string_p $response_value] } {
			set response_value [db_null]
		    } 
		    db_dml survey_question_response_integer_insert "insert into survey_question_responses (response_id, question_id, number_answer)
 values (:response_id, :question_id, :response_value)"
		}
		"text" {
		    if { [empty_string_p $response_value] } {
			set response_value [db_null]
		    }

		    db_dml survey_question_response_text_insert "
insert into survey_question_responses
(response_id, question_id, clob_answer)
values (:response_id, :question_id, empty_clob())
returning clob_answer into :1" -clobs [list $response_value]
	    }
	    "date" {
                if { [empty_string_p $response_value] } {
                    set response_value [db_null]
                }

		db_dml survey_question_response_date_insert "insert into survey_question_responses (response_id, question_id, date_answer)
values (:response_id, :question_id, :response_value)"
	    }   
            "blob" {

                if { ![empty_string_p $response_value] } {
                    # this stuff only makes sense to do if we know the file exists
		    set tmp_filename $response_to_question($question_id.tmpfile)

                    set file_extension [string tolower [file extension $response_value]]
                    # remove the first . from the file extension
                    regsub {\.} $file_extension "" file_extension
                    set guessed_file_type [ns_guesstype $response_value]

                    set n_bytes [file size $tmp_filename]
                    # strip off the C:\directories... crud and just get the file name
                    if ![regexp {([^/\\]+)$} $response_value match client_filename] {
                        # couldn't find a match
                        set client_filename $response_value
                    }
                    if { $n_bytes == 0 } {
                        error "This should have been checked earlier."
                    } else {
                         set unique_name "${response_value}_${response_id}"
                         set mime_type [ns_guesstype $client_filename]
                         set revision_id [cr_import_content -title $client_filename "" $tmp_filename $n_bytes $mime_type $unique_name ]
# we use cr_import_content now --DaveB
# this abstracts out for use the blob handling for oracle or postgresql
# we are linking the file item_id to the survey_question_response attachment_answer field now
                            db_dml survey_question_response_attachment_insert "
insert into survey_question_responses
(response_id, question_id, attachment_answer)
values
(:response_id, :question_id, :revision_id
 )"
	 	    }
                }
            }
	}
    }
} on_error {
	ad_return_error "Erro na resposta $erro_cpf" "Erro no preenchimento do formulário $erro_cpf."
}

survey_do_notifications -response_id $response_id

}

if {[info exists return_url] && ![empty_string_p $return_url]} {
    ad_returnredirect "$return_url"
           ad_script_abort
} else {
     set context [_ survey.lt_Response_Submitted_for]
     ad_return_template
}	
    



