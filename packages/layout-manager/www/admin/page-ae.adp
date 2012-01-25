<master>

<if @page_edit_p@>
    <include src="/packages/layout-manager/lib/page-configure" pageset_id="@pageset_id@" page_id="@page_id@">
</if>
<else>
<table width="100%">
  <tr><td valign="top" align="right">
  <if @admin_p@>
        #layout-manager.Admin_Menu#:
        <if @customize_p@>
        <a href="@customize_turn_url@">#layout-manager.Customize_layout_turn_Off#</a> |
        <a href="@add_item_url@">#layout-manager.Add_this_page_to_menu#</a> |
        <a href="@edit_theme_url@">#layout-manager.Edit_Theme#</a> |
        <a href="@add_page_url@">#layout-manager.New_Page#</a> |
      </if>
      <else>
        <a href="@customize_turn_url@">#layout-manager.Customize_layout_turn_On#</a>
      </else>
  </if>

  </td></tr>
</table>


<formtemplate id="page-add"></formtemplate>
</else>