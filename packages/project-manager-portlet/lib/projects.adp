    <listtemplate name="projects"></listtemplate>
  
   <br>
   <center>
   <if @more_p@ eq 1>
	<if @user_space_p@ eq 1>
            <a href="project-manager/index?user_space_p=1&is_observer_p=f" class="button">#project-manager-portlet.More#</a>
	</if>
	<else>
  	    <a href="project-manager/index" class="button">#project-manager-portlet.More#</a>
        </else>
   </if>
   <center>
   <br>	