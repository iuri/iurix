<!--
     Display a list of available rooms.

     @author David Dao (ddao@arsidigta.com)
     @creation-date November 13, 2000
     @cvs-id $Id: index.adp,v 1.10 2008/11/09 23:29:23 donb Exp $
-->
<master src="chat-master">
<property name="title">Messages</property>
<property name="context">{Messages}</property>
<property name="&doc">doc</property>


<script language="javascript" type="text/javascript">
    <!--
    function popitup(url) {
         newwindow=window.open(url,'chat-popup','height=400,width=400');
         if (window.focus) {newwindow.focus()}
         return false;
    }
    // -->
</script>

<if @warning@ not nil>
<div style="border: 1px solid red; padding: 5px; margin: 10px;">
    @warning;noquote@
</div>
</if>

<listtemplate name="rooms"></listtemplate>
