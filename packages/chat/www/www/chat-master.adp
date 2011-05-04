<master>
<property name="title">@title;noquote@</property>
<property name="context">@context;noquote@</property>
<property name="header_stuff">   
    <link rel="stylesheet" type="text/css" href="/resources/css/chat.css">
    <style type="text/css">
        div.list {
            width: 800px;
        }
        div.formtemplate {
            width: 800px;
        }
    </style>
</property>


    <script language="javascript" type="text/javascript">
    <!--	    
    function popitup(url) {
	 newwindow=window.open(url,'chat-popup','height=400,width=400');
	 if (window.focus) {newwindow.focus()}
	 return false;
    }
    // -->
    </script>

<% 
    set user_id [ad_conn user_id]
    set package_url [ad_conn package_url]
%>



        <div id="list-button-bar">
        <if @context@ eq {Messages}>            
            <strong><span>#chat.Messages#</span></strong>
        </if>
        <else>
            <a href="@package_url;noquote@imessages" class="button">#chat.Messages#</a>
        </else>      
        <if @context@ eq {Chat rooms}>            
            <strong><span>>#chat.Chat_rooms#</span></strong>
        </if>
        <else>
            <a href="@package_url;noquote@index" class="button">#chat.Chat_rooms#</a>
        </else>      
	<if @admin_p@>
	    <a href="/admin/groups/" class="button">#chat.Groups#</a>
	</if>
        <if @context@ eq {Send Message}>
            <strong><span>#chat.Send_Message#</span></strong>
        </if>
        <else>
	    <a href="@package_url;noquote@message-new" class="button" onclick="return popitup('message-new')" >#chat.Send_Message#</a>
        </else>
	<if @msgs@ gt 0>
	   <a href="@package_url;noquote@imessages"><span style="color:red;">#chat.You_have# @msgs;noquote@ #chat.new_messages#</span></a>
	</if>
	<div align="right">#chat.Your_status_is# @chat_current_status@ <a href="@package_url;noquote@change-status?return_url=@return_url;noquote@" class="button">#chat.Change_Status#</a></div>
	
	
        </div>
<slave>
