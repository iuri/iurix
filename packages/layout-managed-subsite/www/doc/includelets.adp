<master>
<property name="title">Managing an application's includelets</property>
<h1>Managing an Application's Includelets</h1>
When you enter the <i>Manage Includelets</i> page from the <i>Add Applications</i> page,
you'll be presented with two lists.  The first list contains layout elements that have
been bound to this application within the pageset being configured.  For each element
the "title",
internal "includelet name", "state" ("hidden" from users, or "full", displayed on a page),
and buttons to delete or copy the element are displayed.
<p>Currently, you can only change element attributes like its title, theme and state from
the page configuration UI.  The only actions you can take from the <i>Manage Includelets</i>
page are to copy the element, or to delete the element (which perversely can't be done from the page configuration
page, mostly to keep users from destroying their environment if they're allowed to have
personal pagesets).
<p>Below this list is a list of includelets which can be bound to elements and added to
the pageset being configured.  Unless the includelet is marked "singleton", you can add an
includelet as a new layout element as many
times as you want.  For example, you might want to include an instance of the forums includlet
on each page displayed to the user.  To do so, add the includelet as a new layout element
once for each layout page that will be created for the subsite, then add them individually to
each page in the page configuration UI.
<p>When you're done adding includelets or deleting elements, click on the "return
to add applications" button.  This will allow you to manage includelets and layout elements
for another application, or to resume adding new applications.  If you're running the
wizard, when you're finished click the "next" button to advance to the next configuration
step.
