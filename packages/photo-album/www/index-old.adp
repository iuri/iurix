<master>
<property name="title">@folder_name;noquote@</property>
<property name="context">@context;noquote@</property>

<if @use_ajaxpa_p@ eq 1>
<include src="/packages/ajax-photoalbum-ui/lib/ajaxpa-include" package_id="@package_id@" layoutdiv="pacontainer">
</if>


<h1>#photo-album.Photos#</h1>
<table width="100%">
  <tr>
    <td align="left" valign="top">#photo-album.Unsorted_Photos#
      <if @child_photo:rowcount@ gt 0>
        <table align="center" cellspacing="5" cellpadding="5">
	  <grid name=child_photo cols=4 orientation=horizontal>
	    <if @child_photo.col@ eq 1>
	      <tr align="center" valign="top">
	    </if>
	    <if @child_photo.rownum@ le @child_photo:rowcount@>
	      <td><a href="photo?photo_id=@child_photo.photo_id@"><img src="images/@child_photo.thumb_path@" height="@child_photo.thumb_height@" width="@child_photo.thumb_width@" alt="@child_photo.caption@" border="0"/></a><br />
		  <a href="photo?photo_id=@child_photo.photo_id@">@child_photo.caption@</a>
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
      </if>
      <else>
        <p>#photo-album.lt_This_album_does_not_c#</p>
      </else> 
    </td>
  </tr>
  <tr>
    <td align="left" valign="top">
      <hr>
      <h1>#photo-album.Navigate_throughout_albums#</h1>
        <table width="100">
	  <tr>    
	    <multiple name="child">
  	      <if @child.rownum@ odd><td class="list-odd"></if><else><td class="list-even"></else>
                <table width="100">
		  <tr>
		    <td align="center" valign="top">
		      <if @child.type@ eq "Folder">
		        <a href="./?folder_id=@child.item_id@"><img src="graphics/folder.gif" alt="@child.name@" border="0" /></a>
		      </if>
		      <else>
	                <if @child.iconic@ not nil><a href="album?album_id=@child.item_id@"><img src="images/@child.iconic@" alt="@child.name@" border="0" /></a></if><else><a href="album?album_id=@child.item_id@"><img src="graphics/album.gif" alt="@child.name@" /></a></else>
		      </else>    
		    </td>
		  </tr>
		  <tr>
		    <td align="center" valign="top">
  		      <if @child.type@ eq "Folder"><a href="./?folder_id=@child.item_id@"></if><else><a href="album?album_id=@child.item_id@"></else>
		      @child.name@</a><if @child.description@ not nil><br />@child.description@</if></td>
		  </tr>
		</table>
	    </multiple>
	  </td>
	</tr>
      </table>
    </td>
  </tr>
</table>
  

<if @admin_p@ eq 1>
  <div style="float: right"><ul>
  <if @subfolder_p@ eq 1>
    <li><a href="folder-add?parent_id=@folder_id@">#photo-album.Add_a_new_folder#</a></li>
  </if>
  <if @album_p@ eq 1>
    <li><a href="album-add?parent_id=@folder_id@">#photo-album.Add_a_new_album#</a></li>
  </if>
  <if @write_p@ eq 1>
    <li><a href="folder-edit?folder_id=@folder_id@">#photo-album.lt_Edit_folder_informati#</a></li>
  </if>
  <if @move_p@ eq 1>
    <li><a href="folder-move?folder_id=@folder_id@">#photo-album.lt_Move_this_folder_to_a#</a></li>
  </if>
  <if @delete_p@ eq 1>
    <li><a href="folder-delete?folder_id=@folder_id@">#photo-album.Delete_this_folder#</a></li>
  </if>
    <li><a href="/permissions/one?object_id=@folder_id@">#photo-album.lt_Modify_this_folders_p#</a></li>
    <li><a href="/shared/parameters?@parameter_url_vars@">#photo-album.Modify_this_pack#</a> </li>
  </if>
  </ul></div>
</if>

<if @child:rowcount@ gt 0>


<!--
<table border="0">
 <tr class="list-header">
  <td align=center>#photo-album.Name#</td>
  <td align=center>#photo-album.Description#</td>
 </tr>
</table>
-->

</if><else>
<p>#photo-album.lt_There_are_no_items_in#</p>
</else>

<if @collections@ gt 0>
<p><a href="clipboards">#photo-album.lt_View_all_of_your_clip#</a>.</p>
</if>

<if @shutterfly_p@ eq "t">
    <p class="hint">
      #photo-album.lt_To_order_prints_of_th#
      <a href="http://shutterfly.com">#photo-album.shutterflycom#</a> #photo-album.lt_for______printing_fro# <a href="clipboards">#photo-album.clipboard#</a> #photo-album.screen#
    </p>
</if>
</div>
