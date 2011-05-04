<master>
<property name="title">@title@</property>
<property name="context">@context@</property>
<property name="header_suppress">1</property>
<property name="displayed_object_id">@album_id@</property>

<script language="JavaScript" type="text/javascript" src="/photo-album/www/resources/ContenFlow/contentflow.js"></script>

@page_nav;noquote@
@message;noquote@

<if @photo_p@ eq 1> |
  <a href="photo-new?album_id=@album_id@&return_url=@this_url@">#photo-album.lt_Add_a_single_photo_to#</a> |
  <a href="photos-add?album_id=@album_id@&return_url=@this_url@">#photo-album.lt_Add_a_collection_of_p#</a> |
  <a href="photos-edit?album_id=@album_id@&page=@page@&return_url=@this_url@">#photo-album.Edit_these_photos#</a> |
</if>
<else>
<if @logged_p@ ne 0> 
  <a href="photo-new?album_id=@album_id@&return_url=@this_url@">#photo-album.lt_Add_a_single_photo_to#</a></li> |
  <a href="photos-add?album_id=@album_id@&return_url=@this_url@">#photo-album.lt_Add_a_collection_of_p#</a></li> |
  <a href="photos-edit?album_id=@album_id@&page=@page@&return_url=@this_url@">#photo-album.Edit_these_photos#</a></li> |
</if>
</else>


<h2>Album: @title@</h2>


<if @child_photo:rowcount@ gt 0>
<table align="center" cellspacing="5" cellpadding="5">
<grid name=child_photo cols=4 orientation=horizontal>
<if @child_photo.col@ eq 1>
<tr align="center" valign="top">
</if>
<if @child_photo.rownum@ le @child_photo:rowcount@>


<td>
<div class="ContentFlow">
  <div class="loadIndicator"><div class="indicator"></div></div>
  <div class="flow">

      <!-- Add as many items as you like. -->

<a href="photo?photo_id=@child_photo.photo_id@"><img class="item" src="images/@child_photo.thumb_path@" height="@child_photo.thumb_height@" width="@child_photo.thumb_width@" alt="@child_photo.caption@" border="0"/></a><br />
<a href="photo?photo_id=@child_photo.photo_id@">@child_photo.caption@</a>

  </div>
  <div class="globalCaption"></div>
  <div class="scrollbar"><div class="slider"><div class="position"></div></div></div>
</div>


</td>
</if>
<else>
<td>&nbsp;</td>
</else>
<if @child_photo.col@ eq 4>
</tr>
</if>
</grid>
</table>
@page_nav;noquote@
</if><else>
<p>#photo-album.lt_This_album_does_not_c#</p>
</else>

<ul>
<if @write_p@ eq 1>
  <li><a href="album-edit?album_id=@album_id@&return_url=@this_url@">#photo-album.lt_Edit_album_attributes#</a></li>
</if>
<if @move_p@ eq 1>
  <li><a href="album-move?album_id=@album_id@">#photo-album.lt_Move_this_album_to_an#</a></li>
</if>
<if @admin_p@ eq 1>
  <li><a href="/permissions/one?object_id=@album_id@">#photo-album.lt_Modify_this_albums_pe#</a></li>
  <li><a href="photos-delete?album_id=@album_id@">#photo-album.Clean_this_album#</a></li>
</if>
<if @delete_p@ eq 1>
  <li><a href="album-delete?album_id=@album_id@">#photo-album.Delete_this_album#</a></li>
</if>
</ul>
<p style="color: #999999;">#photo-album.lt_Click_on_the_small_ph#
</p>
<if @collections@ gt 0>
<p><a href="clipboards">#photo-album.lt_View_all_of_your_clip#</a>.</p>
</if>

