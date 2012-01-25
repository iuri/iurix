<table width="100%">
  <tr>
<td valign="top" align="right">
  <if @admin_p@> 
        #layout-manager.Admin_Menu#:
        <if @customize_p@>
	<a href="@customize_turn_url@">#layout-manager.Customize_layout_turn_Off#</a> |
	<a href="@add_page_url@">#layout-manager.New_Page#</a> |
	<a href="@edit_page_url@">#layout-manager.Edit_Page#</a> |
	<a href="@add_item_url@">#layout-manager.Add_this_page_to_menu#</a> |
	<a href="@edit_layout_url@">#layout-manager.Edit_Layout#</a> |
	<a href="@edit_theme_url@">#layout-manager.Edit_Theme#</a> |
	<a href="@edit_menu_url@">#layout-manager.Edit_Menu#</a> |
	

	<if @vertical_menu_p@ eq 1>
          <a href="@menu_turn_url@">#layout-manager.Turn_Off_Menu#</a> 
	</if>
	<if @vertical_menu_p@ eq 0>
          <a href="@menu_turn_url@">#layout-manager.Turn_On_Menu#</a> 
	</if>
      </if>
      <else>
        <a href="@customize_turn_url@">#layout-manager.Customize_layout_turn_On#</a>
      </else>
  </if>
  </td></tr>
</table>


<table width="100%">
<tr>
<if @vertical_menu_p@ eq 1>
  <td align="left" valig="top" valign="top" width="20%">
    <div id="navesqu getDrag">
      <ul class="sf-menu sf-vertical" style="border-bottom:1px solid #ccc;">
                @vertical_menu;noquote@
      </ul>
    </div>
    <if @admin_p@> 
      <if @customize_p@>
        <h1>#layout-manager.Admin_Menu#</h1>
        <div class="portal_customize_elements">
          <ul>
            <multiple name="hidden_elements_list">
	      <li><a href="@hidden_elements_list.show_url@">@hidden_elements_list.element_name@</a></li>
	    </multiple> 
          </ul>
        </div>
        <div class="portal_customize_layout">
          <ul>
            <multiple name="layouts_list">
	      <li><img src="/resources/theme-zen/images/@layouts_list.image@.gif">
	      <span class="tipo_disposicao">
	      <a href="one-community-portal-layout?page_id=@page_id@&pageset_id=@pageset_id@&layout_id=@layouts_list.layout_id@&return_url=@return_url@">@layouts_list.name@</a></span>
	      <br /><a href="one-community-portal-layout?page_id=@page_id@&pageset_id=@pageset_id@&layout_id=@layouts_list.layout_id@&return_url=@return_url@">Selecionar disposição</a></li>
	    </multiple>
          </ul> 
        </div>
      </if>
    </if>
  </td>
  <td align="left" valign="top" width="80%">
</if>
<else> <td align="left" valig="top" width="100%"> </else>



<include src="/packages/layout-manager/lib/render/render-page" &="pageset">


</td></tr></table>