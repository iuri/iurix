# /www/survsimp/admin/survey-create-choice.tcl
ad_page_contract {

    Ask the user what kind of survey they wish to create.

    @author nstrug@arsdigita.com
    @date September 13, 2000
    @cvs-id $Id: survey-create-choice.tcl,v 1.2 2003/03/12 01:05:52 daveb Exp $

} {



}

set package_id [ad_conn package_id]
ad_require_permission $package_id survey_create_survey

set whole_page "[ad_header "[_ survey.Choose_Survey_Type]"]

<h2>[_ survey.Choose_a_Survey_Type]</h2>

[ad_context_bar "[_ survey.Choose_Type]"]

<hr>

<dl>
<dt><a href=\"survey-create?type=scored\">[_ survey.Scored_Survey]</a>
<dd>[_ survey.lt_This_is_a_multiple_ch]</dd>
<dt><a href=\"survey-create?type=general\">[_ survey.General_Survey]</a>
<dd>[_ survey.lt_This_survey_allows_yo]</dd>
</dl>

[ad_footer]
"

doc_return 200 text/html $whole_page
