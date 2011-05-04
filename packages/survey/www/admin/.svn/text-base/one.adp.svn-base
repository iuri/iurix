<master>
<property name="survey_id">@survey_id;noquote@</property>

<property name="title">#survey.lt_One_Survey_survey_inf#</property>
<property name="context">@context;noquote@</property>
<p><a href=".">#survey.lt_Main_Survey_Administr#</a></p>
<font size=+1><b>@survey_info.name@</b></font> #survey.-__Created_by# <a href="@user_link@">@survey_info.creator_name@</a>#survey._on_creation_date#</h2>
<table class="table-display" cellpadding=2 cellspacing=0>
	<tr class="even"><td> </td><td> #survey.This_survey_is# <if @survey_info.enabled_p@ eq t><%= [lang::util::localize @survey_info.enabled_display@]%></if><else><span style="color: #f00;"><%=[lang::util::localize @survey_info.enabled_display@]%></span></else>. - <a href="@toggle_enabled_url@">@toggle_enabled_text@</a></td></tr>

	<tr class="odd"> 
<td valign="top">#survey.Survey_Name#<p>
#survey.Description# </td>
	<td>
<a href="survey-preview?survey_id=@survey_id@">#survey.Preview#</a>

	 <a href="name-edit?survey_id=@survey_id@">#survey.Edit#</a>
@survey_info.name@<p>
@survey_info.description;noquote@</td>
</tr>
	<tr class="even"><td>#survey.View_Responses# </td><td >
	<a
	href="respondents?survey_id=@survey_id@">#survey.By_user#</a> | <a
	href="responses?survey_id=@survey_id@">#survey.Summary#</a> | 
	<a href="responses-export?survey_id=@survey_id@"> #survey.CSV_file#</a></td>
	</tr>
	<tr class="odd"><td valign="top" rowspan="2"><nobr>#survey.Response_Options# </nobr></td><td> <%= [lang::util::localize @survey_info.single_response_display@]%> - [ 
	<a href="response-limit-toggle?survey_id=@survey_id@">@response_limit_toggle@</a>
	]</td></tr>
	
      
	<tr class="odd"><td><if @survey_info.editable_p@> #survey.lt_Users_may_edit_their_#</if><else>#survey.lt_Users_may_not_edit_th#</else> - [ <a
	href="response-editable-toggle?survey_id=@survey_id@">#survey.make# <if
	@survey_info.editable_p@>#survey.non-#</if>#survey.editable#</a> ]</td></tr>

	<tr class="odd"><td>#survey.Display_Options# </td><td><%= [lang::util::localize "#survey.@survey_info.display_type@#"]%> - <list name="survey_display_types"><if @survey_info.display_type@ ne @survey_display_types:item@>[<a href="survey-display-type-edit?display_type=@survey_display_types:item@&survey_id=@survey_id@"><%= [lang::util::localize "#survey.@survey_display_types:item@#"]%></a>]</if></list></td></tr>
	
      
<tr class="odd"><td valign="top" rowspan="2">#survey.Email_Options#</td><td >@notification_chunk;noquote@</td></tr>

	<tr class="odd"><td ><a href="send-mail?survey_id=@survey_id@">#survey.Send_bulkmail#</a> #survey.lt_regarding_this_survey# </td></tr>
	
      
	<tr><td></td><td >
	
      <tr class="even">
	<td>#survey.Extreme_Actions# </td><td >
	<a href="survey-delete?survey_id=@survey_id@">#survey.Delete_this_survey#</a> #survey.lt_-_Removes_all_questio#<br>
	<a href="survey-copy?survey_id=@survey_id@">#survey.Copy_this_survey#</a> #survey.lt_-_Lets_you_use_this_s#
	</td></tr>
</table>
<br />

<h3>#survey.Questions#</h3>
<table cellspacing=0>
<if @questions:rowcount@ eq 0>
    <tr class="odd">
  </else>
<td></td><td><a href="question-add?section_id=@survey_info.section_id@">#survey.add_new_question#</a></tr></tr>
</if>
<multiple name="questions">

  <if @questions.rownum@ odd>
    <tr class="odd">
  </if>
  <else>
    <tr class="even">
  </else>

<td valign="top">@questions.rownum@.  <a name="@questions.sort_order@"></a></td>

<td><a	href="question-modify?question_id=@questions.question_id@&section_id=@section_id@&survey_id=@survey_id@">#survey.Edit#</a>
<if @questions.active_p@ eq "f"><span style="color: #f00;">#survey.inactive#</span></if>
<a href="question-copy?question_id=@questions.question_id@&sort_order=@questions.sort_order@">#survey.Copy#</a>
<a href="question-add?section_id=@section_id@&after=@questions.sort_order@">#survey.Add_New#</a><img src="../graphics/spacer.gif" border="0" alt="" width="10">
<if @questions.rownum@ lt @questions:rowcount@ ><a
	  href="question-swap?section_id=@section_id@&survey_id=@survey_id@&sort_order=@questions.sort_order@&direction=down"><img src="../graphics/down" border="0" alt="#survey.Move_Down#"></a></if><if @questions.rownum@ gt 1><a
	  href="question-swap?section_id=@section_id@&survey_id=@survey_id@&sort_order=@questions.sort_order@&direction=up"><img src="../graphics/up.gif" border="0" alt="#survey.Move_Up#"></a></if><a href="question-delete?question_id=@questions.question_id@&survey_id=@survey_id@"><img src="../graphics/delete.gif" border="0" alt="#survey.Delete#"></a></td></tr>

  <if @questions.rownum@ odd>
    <tr class="odd">
  </if>
  <else>
    <tr class="even">
  </else>
<td colspan="3">
  <blockquote>@questions.question_display;noquote@</blockquote>
</td></tr>
<if @questions.rownum@ eq @questions:rowcount@>
  <if @questions.rownum@ odd>
    <tr class="even">
  </if>
  <else>
    <tr class="odd">
  </else>
<td></td><td><a href="question-add?section_id=@survey_info.section_id@">#survey.add_new_question#</a></tr></tr>
</if>
</multiple>
</table>      


