<master>
<property name="title">@title@</property>
<property name="context">@context_list@</property>

<form method=POST action=photos-delete>
<if @photo_id@ not nil>
  <input type=hidden name=photo_id value="@photo_id;noquote@">
</if>
<if @album_id@ not nil>
  <input type=hidden name=album_id value=@album_id@>
</if>
<input type=hidden name=confirmed_p value="t">

<p>#photo-album.lt_Are_you_sure_you_want_album#
<p>
<center>
<input type=submit value="#photo-album._Yes_Delete#">
</center>

</form>

