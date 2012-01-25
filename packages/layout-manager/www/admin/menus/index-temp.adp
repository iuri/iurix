<master>
<property name="context">@context;noquote@</property>
<property name="title">@page_title;noquote@</property>
<property name="admin_navbar_label">admin_menus</property>

@table;noquote@

<hr>
<form action=menu-action method=post>
  <table>
@table_header;noquote@

    <if @menus1:rowcount@ gt 0>
      <multiple name="menus1">
        <tr @bgcolor@>
          <td colspan=@menus1.indent_level@>&nbsp;</td>
          <td colspan=@colspan_level@> 
    	    <a href=@menus1.url@?menu_id=@menus1.menu_id@&return_url=@return_url@>@menus1.name@</a><br>
	    @menus1.label@<br>
            <tt>@menus1.visible_tcl@</tt>
          </td>
 	  <td>@menus1.enabled_p@</td>
	  <td>@menus1.sort_order@</td>
	  <td>@menus1.package_name@</td>

	  <td>
	    <input type=checkbox name=menu_id.@menu_id@>
	  </td>
	</tr>


      </multiple>
    </if>

    <tr>
      <td colspan=@colspan_temp@ align=right>
        <A href=new?[export_url_vars return_url]>New Menu</a>
      </td>
      <td>
        <input type=submit value='Del'>
      </td>
    </tr>
  </table>
</form>