<master>
<property name="title">Personal Pagesets or not?</property>
<h1>Personal Pagesets or not?</h1>
<b><i>Personal pagesets are not yet implemented</i></b>
A <i>pageset</i> is a set of pages managed by the <i>Layout Manager</i> as a unit.  The
first thing you must decide for your subsite is whether or not to provide each individual
with their own configurable pageset, or one pageset shared by all.
<p>Advantages and disadvantages are:
<ul>
  <li>Personal pagesets allow each individual user to determine which layout elements
      to display, the number of pages that make up the pageset, and the arrangement of
      layout elements on individual pages.  Unless they're an administrator of the
      <i>Layout Managed Subsite</i> package, they will not be allowed to add new
      applications to the subsite.
  <li>The <i>Layout Manager</i> package heavily caches the database queries needed to
      compute the information necessary to render layout pages and elements.  When all
      users share a single pageset, the number of queries that must be cached is quite
      small.  If users each have their own pageset, the number of queries that must be
      cached is multipied by the number of users of the subsite.  This can cause poor
      cache performance or require a large cache size to be specified for the database
      cache pool.
  <li>Users might confuse themselves by accidently hiding layout elements, moving them
      to an unfamiliar page, etc.  This might increase the effort required to support
      a site substantially.
  <li>Having one shared layout pageset allows you to lay out the subsite precisely without
      worrying about users specifying experimenting with odd themes for elements, etc.  If
      you're going to allow users to have their own layout pagesets, keep the graphic
      design dead-simple!  Resist the temptation to create themes that only work on the
      left or right side of a page, for instance.
</ul>
