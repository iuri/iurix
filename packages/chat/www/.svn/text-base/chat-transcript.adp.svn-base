<master>
<property name="context">@context;noquote@</property>
<property name="title">#chat.transcript_of_room# "@room_name;noquote@"</property>

<if @transcript_id@ eq 0>
<include src="/packages/chat/lib/current-messages" room_id=@room_id@>
</if>
<else>
<include src="/packages/chat/lib/transcript-view" room_id=@room_id@ transcript_id=@transcript_id@ write_p=@write_p@>
</else>
