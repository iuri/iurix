<property name=title>#survey.One_Survey_name#</property>
<property name=context>@context;noquote@</property>

      <form enctype=multipart/form-data method="post" action="@base_url@process-response" id="responses">
		<if @initial_response_id@ not nil><input type="hidden"
	name="initial_response_id" value="@initial_response_id@"></if>
        <div class="data"><b>@description;noquote@</b></div>
        <div class="data"><hr noshade size="1" color="#dddddd"></div>
        <div class="data">
	      @form_vars;noquote@
          <include src="one_list" questions=@questions;noquote@>
          <hr noshade size="1" color="#dddddd">
          <input type="submit" value="@button_label@">
		</div>
      </form>
