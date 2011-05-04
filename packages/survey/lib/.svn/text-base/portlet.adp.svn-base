<if @display_empty_p@ true or @active:rowcount@ gt 0>
  <div id="@id@" class="@class@">
    <h3><a href="@base_url@">Enquete</a></h3>
	<if @include_p@ not nil>
	  <multiple name="active">
  	    <include src="respond" survey_id="@active.survey_id@" name="@active.name@" base_url="@active.base_url@">
		<br>
		&raquo;&nbsp;<a href="@base_url@responses?survey_id=@active.survey_id@">#survey.View_Responses#</a>
	  </multiple>
	</if>
	<else>
      <if @active:rowcount@ eq 0><em>None active</em></if>
      <else>
        <ul>
          <multiple name="active">
            <li><a href="@active.url@">@active.name@</a>
	      </multiple>
        </ul>
      </else>
	</else>
  </div>
</if>
