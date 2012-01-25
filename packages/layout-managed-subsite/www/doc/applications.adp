<master>
<property name="title">Adding Applications</property>
<h1>Adding Applications</h1>
After you decide whether or not to allow personal pagesets, the wizard will run
the "add applications" admin page.  This page will first list applications that have already
been mounted (if they support includelets), their URL, and includelets that have been
bound as <i>layout elements</i> to each application.
<p>Following this list (which is initially empty) is a list of applications which support
includelets and are available to be mounted.  Note that you can mount as many instances
of each application as you want.  This makes sense for some packages (<i>content-includelet</i>,
for instance), but not for others (<i>file-storage</i>).  You'll need to depend on your
knowledge of each application to decide when it makes sense for you to mount a package
more than once.  Note that this is no different than when deciding how many instances of
a package to mount when configuring a "normal" subsite outside the context of the
<i>Layout Manager Integration</i> package.
<p>When you mount an application, it will be listed in the top half of the page, with no
layout elements bound to it.  Click on the <i>Manage Includelets</i> action link.  This is
described on a separate documentation page.
