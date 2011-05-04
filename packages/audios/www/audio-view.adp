<master>
<property name="title">@title;noquote@</property>
<property name="context">@context;noquote@</property>

<table width="100%" cellpadding="5" cellspacing="0">
  <tr>
    <td width="100%" valign="top" align="left">
    	<a href="javascript:history.back()">#audios.Go_Back#</a> | <a href="@url@download_orig_file?audio_id=@audio_id@">#audios.Download_Audio#</a> 
   	<if @admin_p@>
          | <a href="@url@audio-ae?audio_id=@audio_id@">#audios.Audio_Edit#</a> |
	  @add_tag_link;noquote@ | <a href="@url@audio-del?audio_id=@audio_id@">#audios.Audio_del#</a> |
	  
        </if> 
    </td>
  </tr>
</table>
<table width="100%" cellpadding="5" cellspacing="0">
  <tr>
    <td width="20%" valign="top" align="left">
      <div id="description">
        <h2>@audio.audio_name;noquote@</h2>
	#audios.Author#: @audio.author;noquote@<br>
	#audios.Group#: @group_name;noquote@<br>
	#audios.Source#: @audio.source;noquote@<br>
	#audios.Posted_by#: @creator_name@<br>
        #audios.in# @audio.audio_date;noquote@<br>

        <p> @audio.audio_description;noquote@</p>


      </div>
      <p>@notification_chunk;noquote@</p>
     
      <h1>#audios.Share_this_audio#</h1>
      <a href="http://twitter.com/share" class="twitter-share-button" data-count="none">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script><br>
   
      <a name="fb_share" type="button" href="http://www.facebook.com/sharer.php">Compartilhar</a><script src="http://static.ak.fbcdn.net/connect.php/js/FB.Share" type="text/javascript"></script><br>

      <a href="http://www.linkedin.com/shareArticle?mini=true&url=@return_url@&title=@audio.audio_name@&summary=@audio.audio_description@&source=@audio.source@"><img src="/resources/audios/linkedin_icon.gif" width="100" border=0 alt="Share on Linkedin"></a>
      

    </td>
    <td width="60%" valign="center" align="middle">


    <div id="flashcontent">
    Este texto será substituído pelo filme Flash.
    </div>

    <script type="text/javascript">
    	    var so = new SWFObject('/resources/audios/player.swf','mpl','580','395','9');
	    so.addParam('allowfullscreen','true');
	    so.addVariable('autostart','true');
	    so.addVariable('file','@url@@audio_id@.mp3');
	    so.write("flashcontent");
    </script>

	   @url@ | @audio_id@ | @audio_url@
	




      <h1>#audios.Comments#</h4>
      <a href="@comment_add_url@">Add a comment</a>
      @comments_html;noquote@



    </td>
    <td width="20%" valign="top" align="left">
      <table class="list-table" align="left" border="1" width="100%"> <tbody>
        <tr>
	  <td valign="top" align="center"> 
 	    <img style="width: 64px; height: 64px;" src="/resources/audios/Denuncie.png" align="left" />
	    <font size="2"><strong>Denunciar conteúdo impróprio? </strong></font>
            <br /><a href="/shared/send-email?sendto=687541&amp;return_url=">Clique Aqui</a>
          </td>
       	</tr> 
	<tr>
	  <td valign="top" align="center"> 
	    <h1>#audios.Related_Audios#</h1>
	    <multiple name="related_audios">
	      <a href="@related_audios.url@audio-view?audio_id=@related_audios.audio_id@">
              <img  width="50px" src="@related_audios.image_audio_url@"></a><br>
   	      @related_audios.audio_name;noquote@<br>
            </multiple>
	  </td>
	</tr>
	<tr>
	  <td>
	    <h1>#audios.Tags#</h1>
  	    <include src="/packages/tags/lib/tagcloud" item_id="@audio_id;noquote@">
	  </td>
	</tr>
	</tbody>
      </table>


    </td>
  </tr>
</table>


