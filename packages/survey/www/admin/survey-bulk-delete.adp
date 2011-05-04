<!--
    Display confirmation for deleting selected surveys.

    @author iuri sampaio (iuri.sampaio@gmail.com)
    @creation-date March 11, 2011
-->
<master>
<property name="context">@context_bar;noquote@</property>
<property name="title">#survey.Confirm_survey_delete#</property>

<form method="post" action="survey-bulk-delete-2">	
<p>#survey.Are_you_sure_you_want_to_delete#?</p> 
<multiple name="surveys">
@surveys.survey_id@ -  @surveys.name@<br>
</multiple>

<div>
  @hidden_vars;noquote@
  <input type=submit name=submit.x value=#acs-kernel.common_Yes#>
  <input type=submit name=cancel.x value=#acs-kernel.common_No#>
</div>
</form>

