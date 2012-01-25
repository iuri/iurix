<master>
<property name="title">Create A Layout Managed Subsite</property>
<h1>Create A Layout Managed Subsite</h1>
A layout managed subsite is created by either mounting a new subsite of type Layout Managed
Subsite, or converting an existing subsite:
<p>
<ol>
<li>To create a new layout managed subsite, visit the parent subsite's advanced admin page.
Choose the "create new subsite" option.  If the Layout Managed Subsite package has been
installed, the create new subsite form will display a select widget which will allow you
to choose between "Subsite" (acs-subsite), "Layout Managed Subsite", and other subsite packages
you may have installed.  Choose the "Layout Managed Subsite" subsite type.  You should also
choose one of the OpenACS or Layout Managed Subsite themes, rather than the obsolete themes
provided for backwards compatibility.
<li>To convert an existing subsite, visit that subsite's admin page.  If the Layout Managed
Subsite package has been installed, you'll see an option listed under "Subsite Administration"
to convert the subsite type.  That link leads to a form which includes a select widget listing
the available subsite packages.  Choose "Layout Managed Subsite".
This is particularly useful if you want your main subsite, mounted at "/", to be a
Layout Managed Subsite, because initial install always mounts an instance of the standard
acs-subsite package at "/".
</ol>
