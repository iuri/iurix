<master>
<property name="title">Install application and includelet packages</property>
<h1>Install Application and Includelet Packages</h1>
Before you can build your subsite's layout using the <i>Layout Managed Subsite</i>
package's wizard, you must install all of the packages you'd like to use with this
subsite. If you forget some, you can install them afterwards and revisit the appropriate
admin UI pages to add the includelets and their associated applications to the subsite,
but it's easiest to do so before running the wizard.
<p>Each includelet package depends on an application package, typically a standalone package
such as <i>forums</i>.  In some cases, an includelet package will provide it's own application,
for example the <i>content-includelet</i> package, which provides simple content management
for an individual includelet but which is not meant to be used standalone outside of the
<i>Layout Manager</i> environment.
<p>The standard naming convention for includelet packages is to apply a "-includelets" suffix
to a base application name. Thus <i>forums-includelets</i> is based in the <i>forums</i>
application package, <i>file-storage-includelets</i> the <i>file-storage</i> package, etc.
<p>Correctly implemented includelet packages will include a dependency on their base
application package, and will be marked as a <i>service</i>, not <i>application</i>.  To
install an includelets package and its base application package, go to the <i>acs-admin</i>
install software page, select <i>services</i>, and select the includelets you'd like to
install.
<p>After completion, restart AOLserver.  These includelets and applications are now ready
for use by the <i>Layout Manager</i> and <i>Layout Managed Subsite</i> packages.
