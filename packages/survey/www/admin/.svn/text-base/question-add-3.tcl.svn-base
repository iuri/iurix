# /www/survsimp/admin/question-add-3.tcl
ad_page_contract {
    Inserts a new question into the database.

    @param section_id               integer denoting which survey we're adding question to
    @param question_id             id of new question
    @param after                   optional integer determining position of this question
    @param question_text           text of question
    @param abstract_data_type      string describing datatype we expect as answer
    @param presentation_type       string describing widget for providing answer
    @param presentation_alignment  string determining placement of answer widget relative to question text
    @param valid_responses         string containing possible choices, one per line
    @param textbox_size            width of textbox answer widget
    @param textarea_size           size of textarea answer widget
    @param required_p              flag telling us whether an answer to this question is mandatory
    @param active_p                flag telling us whether this question will show up at all

    @author Jin Choi (jsc@arsdigita.com) February 9, 2000
    @author nstrug@arsdigita.com
    @cvs-id $Id: question-add-3.tcl,v 1.5 2003/03/12 01:05:52 daveb Exp $
} {
    section_id:integer,notnull
    question_id:integer,notnull
    after:integer,optional
    question_text:html
    {abstract_data_type ""}
    presentation_type
    presentation_alignment
    type:notnull
    {valid_responses:html ""}
    {textbox_size ""} 
    {textarea_size: "medium"} 
    {required_p t}
    {active_p t}
    {responses:multiple ""}
    {scores:multiple,array,integer ""}
    {n_variables:integer ""}
    {variable_id_list ""}
	{n_v_responses ""}
	{response_type "standard"}
}

set package_id [ad_conn package_id]
set user_id [ad_get_user_id]
ad_require_permission $package_id survey_create_question
get_survey_info -section_id $section_id

if {![info exists survey_info(survey_id)]} {
    ad_return_complaint 1 "[_ survey.lt_Requested_survey_does]"
    ad_script_abort
}

set survey_id $survey_info(survey_id)
set exception_count 0
set exception_text ""


if { [empty_string_p $question_text] } {
    incr exception_count
    append exception_text "<li>[_ survey.lt_You_did_not_enter_a_q]\n"
}

if { $type != "scored" && $type != "general" } {
    incr exception_count
    set type_var $type
    append exception_text "<li>[_ survey.Surveys of type $type are not currently available.\n"
}

if { $type == "general" && $abstract_data_type == "choice" && [empty_string_p $valid_responses] } {
    incr exception_count
    append exception_text "<li>[_ survey.lt_You_did_not_enter_a_l]\n"
}


if { $exception_count > 0 } {
    ad_return_complaint $exception_count $exception_text
    ad_script_abort
}

set already_inserted_p [db_string already_inserted_p {}]

if { $already_inserted_p } {
    ad_returnredirect "one?[export_vars survey_id]"
    ad_script_abort
}
# Generate presentation_options.
    set presentation_options ""
    if { $presentation_type == "textbox" } {
	if { [exists_and_not_null textbox_size] } {
	    # Will be "small", "medium", or "large".
	    set presentation_options $textbox_size
	}
    } elseif { $presentation_type == "textarea" } {
	if { [exists_and_not_null textarea_size] } {
	    # Will be "small", "medium", or "large".
	    set presentation_options $textarea_size
	}
    } elseif { $abstract_data_type == "yn" } {
	set abstract_data_type "boolean"
	set presentation_options "[_ survey.YesNo]"
    } elseif { $abstract_data_type == "boolean" } {
	set presentation_options "[_ survey.TrueFalse]"
    }

    db_transaction {
	if { [exists_and_not_null after] } {
	    # We're inserting between existing questions; move everybody down.
	    set sort_order [expr { $after + 1 }]
	    db_dml renumber_sort_orders {}
	} else {
	    set sort_order [expr [db_string max_question {}] + 1]
	}

	db_exec_plsql create_question {}

	db_dml add_question_text {}


    # For questions where the user is selecting a canned response, insert
    # the canned responses into survey_question_choices by parsing the valid_responses
    # field.
            if { $presentation_type == "checkbox" || $presentation_type == "radio" || $presentation_type == "select" } {
                if { $abstract_data_type == "choice" } {
					if {$response_type eq "personal"} {
	    		    	set count 0
    	        		set choice_id [db_string get_choice_id "select survey_choice_id_sequence.nextval as choice_id from dual"]
				        db_dml insert_survey_question_choice_0 "insert into survey_question_choices (choice_id, question_id, label, sort_order) values (survey_choice_id_sequence.nextval, :question_id, :valid_responses, :count)"
						incr count
			        	set responses [split $valid_responses "\n"]
				        foreach response $responses {
					    	set trimmed_response [string trim $response]
					        if { [empty_string_p $trimmed_response] } {
						        # skip empty lines
					            continue
				    	    }
			        		### added this next line to 
							# Input type element?
							if {[regexp {\<input(.+)\>} $trimmed_response trimmed_response] > 0} {
								ad_parse_html_attributes -attribute_array input $trimmed_response
								set trimmed_response $input(value)
								# Does it exist?
								if {![db_0or1row find_label "
									select choice_id from survey_question_choices where label = :trimmed_response
								" -column_set coluna]} {
			    	        		set choice_id [db_string get_choice_id "select survey_choice_id_sequence.nextval as choice_id from dual"]

							        db_dml insert_survey_question_choice "insert into survey_question_choices (choice_id, question_id, label, sort_order)
values (survey_choice_id_sequence.nextval, :question_id, :trimmed_response, :count)"
					    		    incr count
								}
							}
						}
					} else {
				        set responses [split $valid_responses "\n"]
		    		    set count 0
				        foreach response $responses {
					    	set trimmed_response [string trim $response]
					        if { [empty_string_p $trimmed_response] } {
						        # skip empty lines
					            continue
					        }
			    	    	### added this next line to 
	    	        		set choice_id [db_string get_choice_id "select survey_choice_id_sequence.nextval as choice_id from dual"]
					        db_dml insert_survey_question_choice "insert into survey_question_choices (choice_id, question_id, label, sort_order)
values (survey_choice_id_sequence.nextval, :question_id, :trimmed_response, :count)"
			    		    incr count
						}
		            }
	        	}
            }

		# Insere a opção número de respostas permitidas
		if {$n_v_responses ne ""} {
			db_dml insere {
				update survey_questions
				set num_answers = :n_v_responses
				where question_id = :question_id
			}
		}
    } on_error {

            db_release_unused_handles
            ad_return_error "[_ survey.Database_Error]" "<pre>$errmsg</pre>"
            ad_script_abort
 
    }


db_release_unused_handles
ad_returnredirect "one?survey_id=$survey_id&#${sort_order}"







