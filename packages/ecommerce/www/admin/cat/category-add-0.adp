<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<form method=post action=category-add>
@export_form_vars_html;noquote@
<p>Name: <input type=text name=category_name size=30>
<input type=submit value="Add"></p>
</form>

