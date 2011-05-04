<master>
<property name="title">@spam_name@</property>
<property name="context">@context_bar@</property>

<h1>#survey.Choose_members_to_receive#</h1>

<form method="post" action="spam">
      <input type="hidden" name="survey_id" value="@survey_id@">
      <input type="hidden" name="group_id" value="@group_id@">
  	<ul><p><input type="checkbox" name="spam_all" value="1"> #survey.Send_to_all#</ul>
    <p>#survey.Send_to_groups#
        <ul><p>@groups_html;noquote@</p></ul>

    <p>#survey.Send_to_people#
	<listtemplate name="current_members"></listtemplate>
	@exported_vars;noquote@
    <center>
	  <input type="submit" value="#survey.Compose_bulk_message#">
    </center>
</form>
