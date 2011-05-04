<property name="context">@context;noquote@</property>
<property name="&doc">doc</property>
<property name="focus">ichat_form.msg</property>



    <script language="javascript" type="text/javascript">
    <!--
    function popitup(url) {
         newwindow=window.open(url,'file-add','height=200,width=400');
         if (window.focus) {newwindow.focus()}
         return false;
    }
    // -->
    </script>



<h1>@doc.title@</h1>
<p>
<a href="room-exit-popup?room_id=@room_id@" class="button" title="#chat.exit_msg#">#chat.Log_off#</a> 
<a href="chat-transcript?room_id=@room_id@" class="button" title="#chat.transcription_msg#">#chat.Transcript#</a>
<a href="@html_room_url@" class="button" title="#chat.html_client_msg#">#chat.Hml#</a>
<a href="@invite_user_url;noquote@" class="button" onclick="return popitup('invite-user')">#chat.Invite_user#</a>
<a href="@file_add_url;noquote@" class="button" onclick="return popitup('file-add?room_id=@room_id@&return_url=@return_url;noquote@')" target="_blank">#chat.Add_file#</a>


</p>

@chat_frame;noquote@
