<master>
<property name="context">@context;noquote@</property>
<property name="title">@subsite_name;noquote@</property>

<form method="post" action="@package_url@pageset-configure-2">
  <input type="hidden" name="return_url" value="@return_url@">
  <input type="hidden" name="pageset_id" value="@pageset_id@">
  <input type="hidden" name="page_id" value="@page_id@">
  <input type="hidden" name="op" value="change_page_template">
  <strong>#layout-manager.Template#:</strong>
  <select name="page_template">
    <multiple name="page_templates">
      <option value="@page_templates.name@"
        <if @page_templates.name@ eq @page.page_template@> selected</if>>
        @page_templates.description@
      </option>
    </multiple>
  </select>
  <input type=submit value="#layout-manager.Update#">
</form>


