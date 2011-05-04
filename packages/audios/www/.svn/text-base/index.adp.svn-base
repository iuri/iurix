<master>

<div class="buttons">
  <table width="100%">
    <tr>
      <td valign="top" align="left"><h1>#audios.Audios#</h1></td>
      <td valign="top" align="right">
      	  <formtemplate id="search" style="inline"></formtemplate>

	  <p>@notification_chunk;noquote@</p>
      </td>
    </tr>
    <if @admin_p@>
    <tr>
      <td valign="top" align="left">
        #audios.Admin#: <a href="@add_audio_url@">#audios.New#</a>
      </td>
      <td>&nbsp;</td>
    </tr>
    </if>
  </table>
</div>


<table width="100%" valign="top" align="center">
  <tr>
    <td width="30%" valign="top" align="center">
      <h1>#audios.Recent_Audios#</h1>
      <table width="100%" valign="top" align="center">
        <tr>

	<if @recent_audios:rowcount@ gt 0>
          <multiple name="recent_audios">
            <td valign="top" align="center">
       	      <a href="@recent_audios.url@audio-view?audio_id=@recent_audios.audio_id@&return_url=@return_url@">
	      <img  width="48px" src="@recent_audios.image_audio_url@"></a><br>
	      @recent_audios.audio_name;noquote@<br>
	    </td>
	  </multiple>
	</if>
	<else>
	  #audios.No_records#
	</else>
	</tr>
      </table>
      <hr>
    </td>  
    <td width="10%" valign="top" align="center">&nbsp;</td>
    <td width="60%" valign="top" align="center">   
     	<h1>#audios.Most_Popular#</h1> 
      <table width="100%" valign="top" align="center">
        <tr>

	<if @popular_audios:rowcount@ gt 0>
          <multiple name="popular_audios">
            <td valign="top" align="center">
       	      <a href="@popular_audios.url@audio-view?audio_id=@popular_audios.audio_id@">
	      <img  width="48px" src="@popular_audios.image_audio_url@"></a><br>
	      @popular_audios.audio_name;noquote@<br>
	    </td>
	  </multiple>
	</if>
	<else>
	  #audios.No_records#
	</else>
	</tr>
      </table>
	
      <hr>
    </td>
  </tr>
</table>
<hr>
<if @audios:rowcount@ gt 0>
<table width="100%" valign="top" align="center">
  <tr>
    <td valign="top" align="center">
      <h1>#audios.More_Audios#</h1>
      <table width="100%" valign="top" align="center">
        <tr>
          <multiple name="audios">
      	    <td valign="top" align="center">
	      <a href="@audios.url@audio-view?audio_id=@audios.audio_id@">
	      <img  width="48px" src="@audios.image_audio_url@"></a><br>
	      @audios.audio_name;noquote@<br>
	    </td>
	  </multiple>
	</tr>
      </table>
    </td>
  </tr>
</table>
</if>

