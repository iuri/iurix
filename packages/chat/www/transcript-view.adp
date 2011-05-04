<!--
     Chat transcript preview.

     @author David Dao (ddao@arsdigita.com)
     @creation-date November 27, 2000
     @cvs-id $Id: transcript-view.adp,v 1.7 2007/11/19 01:14:16 donb Exp $
-->
<master>
<property name="context">@context_bar;noquote@</property>
<property name="title">#chat.Transcript_preview#</property>

[<a href="transcript-edit?transcript_id=@transcript_id@&room_id=@room_id@">#chat.Edit#</a>]
<ul>
<li>#chat.Name#: <b>@transcript_name@</b>
<li>#chat.Description#: <b><i>@description@</i></b>


<ul>
<p>@contents;noquote@
</ul>
</ul>


