ad_page_contract {

    Modify question responses and scores

    @param question_id   which question we'll be changing responses of
    @param section_id     survey providing this question

    @author Nick Strugnell (nstrug@arsdigita.com)
    @date   September 15, 2000
    @cvs-id $Id: modify-responses.tcl,v 1.2 2003/03/12 01:05:52 daveb Exp $
} {

    question_id:integer
    section_id:integer

}

ad_require_permission $section_id survey_modify_question

get_survey_info -section_id $section_id
set survey_id $survey_info(survey_id)

set survey_name [db_string survey_name_from_id "select name from survey_sections where section_id=:section_id" ]

set question_text [db_string survey_question_text_from_id "select question_text
from survey_questions
where question_id = :question_id" ]

set table_html "<table border=0>
<tr><th>Response</th>"

set variable_id_list [list]

db_foreach get_variable_names "select variable_name, survey_variables.variable_id as variable_id
  from survey_variables, survey_variables_surveys_map
  where survey_variables.variable_id = survey_variables_surveys_map.variable_id
  and section_id = :section_id
  order by variable_name" {

      lappend variable_id_list $variable_id
      append table_html "<th>$variable_name</th>"
  }

append table_html "</tr>\n"

set choice_id_list [list]

db_foreach get_choices "select choice_id, label from survey_question_choices where question_id = :question_id order by choice_id" {
    lappend choice_id_list $choice_id
    append table_html "<tr><td align=center><input name=\"responses\" value=\"$label\" size=80></td>"

    db_foreach get_scores "select score, survey_variables.variable_id as variable_id
      from survey_choice_scores, survey_variables
      where survey_choice_scores.choice_id = :choice_id
      and survey_choice_scores.variable_id = survey_variables.variable_id
      order by variable_name" {

	  append table_html "<td align=center><input name=\"scores.$variable_id\" value=\"$score\" size=2></td>"
      }

    append table_html "</tr>\n"
}

append table_html "</table>\n"

db_release_unused_handles

doc_return 200 text/html "[ad_header "[_ survey.Modify_Responses]"]
<h2>$survey_name</h2>

[ad_context_bar [list "one?[export_url_vars survey_id]" $survey_info(name)] "[_ survey.lt_Modify_Question_Respo]"]

<hr>

[_ survey.Question]: $question_text
<p>
<form action=\"modify-responses-2\" method=get>
[export_form_vars section_id question_id choice_id_list variable_id_list]
$table_html
<p>
<center>
<input type=submit value=\"[_ survey.Submit]\">
</center>

</form>

[ad_footer]
"
