<master src=./master>
<property name="survey_id">@survey_id@</property>

<property name=title>#survey.lt_survey_name_Responses_1#</property>
<property name=context>@context;noquote@</property>
    <table border="0" cellpadding="0" cellspacing="0" width="100%">
      <form enctype=multipart/form-data method="post" action="process-response">
	<if @initial_response_id@ not nil><input type="hidden"
	name="initial_response_id" value="@initial_response_id@"></if>
        <tr>
          <td class="tabledata">@description@</td>
        </tr>
	<tr>
	  <td class="tabledata"><span style="color: #f00;">*</span> denotes a required question</td>                
	</tr>        
        <tr>
          <td class="tabledata"><hr noshade size="1" color="#dddddd"></td>
        </tr>
        
        <tr>
          <td class="tabledata">
	    @form_vars;noquote@
            <include src="one_@display_type@" questions=@questions;noquote@>
            <hr noshade size="1" color="#dddddd">
              <input type="submit" value="@button_label@">
          </td>
        </tr>
        
      </form>
    </table>
