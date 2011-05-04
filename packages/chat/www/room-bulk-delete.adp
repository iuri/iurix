<!--
    Display confirmation for deleting selected chat rooms.

    @author iuri sampaio (iuri.sampaio@gmail.com)
    @creation-date January 11, 2011
-->
<master>
<property name="context">@context_bar;noquote@</property>
<property name="title">#chat.Confirm_room_delete#</property>

<form method="post" action="room-delete-2">	
<p>#chat.Are_you_sure_you_want_to_delete#?</p> 
<multiple name="rooms">
@rooms.room_id@ -  @rooms.pretty_name@<br>
</multiple>

<div>
  @hidden_vars;noquote@
  <input type=submit name=submit.x value=#acs-kernel.common_Yes#>
  <input type=submit name=cancel.x value=#acs-kernel.common_No#>
</div>
</form>


