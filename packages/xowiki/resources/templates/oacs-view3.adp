<!-- Generated by ::xowiki::ADP_Generator on Wed Sep 02 18:56:14 -03 2020 -->
<master>
                  <property name="context">@context;literal@</property>
                  <if @item_id@ not nil><property name="displayed_object_id">@item_id;literal@</property></if>
                  <property name="&body">body</property>
                  <property name="&doc">doc</property>
                  <property name="head">
        <style type='text/css'>
        table.mini-calendar {width: 227px ! important;font-size: 80%;}
        div.tags h3 {font-size: 80%;}
        div.tags blockquote {font-size: 80%; margin-left: 20px; margin-right: 20px;}
        </style>
        <link rel='stylesheet' href='/resources/xowiki/cattree.css' media='all' >
        <link rel='stylesheet' href='/resources/calendar/calendar.css' media='all' >
        <script language='javascript' src='/resources/acs-templating/mktree.js' async type='text/javascript'></script>
      @header_stuff;literal@</property>
<!-- The following DIV is needed for overlib to function! -->
          <div id="overDiv" style="position:absolute; visibility:hidden; z-index:1000;"></div>    
          <div class='xowiki-content'>

      <%
      if {$::::xowiki::search_mounted_p} {
        template::add_event_listener  -id wiki-menu-do-search-control  -script {
            document.getElementById('do_search').style.display = 'inline';
            document.getElementById('do_search_q').focus();
          }
      }
      %>
      <div id='wikicmds'>
      <if @view_link@ not nil><a href="@view_link@" accesskey='v' title='#xowiki.view_title#'>#xowiki.view#</a> &middot; </if>
      <if @edit_link@ not nil><a href="@edit_link@" accesskey='e' title='#xowiki.edit_title#'>#xowiki.edit#</a> &middot; </if>
      <if @rev_link@ not nil><a href="@rev_link@" accesskey='r' title='#xowiki.revisions_title#'>#xotcl-core.revisions#</a> &middot; </if>
      <if @new_link@ not nil><a href="@new_link@" accesskey='n' title='#xowiki.new_title#'>#xowiki.new_page#</a> &middot; </if>
      <if @delete_link@ not nil><a href="@delete_link@" accesskey='d' title='#xowiki.delete_title#'>#xowiki.delete#</a> &middot; </if>
      <if @admin_link@ not nil><a href="@admin_link@" accesskey='a' title='#xowiki.admin_title#'>#xowiki.admin#</a> &middot; </if>
      <if @notification_subscribe_link@ not nil><a href='/notifications/manage' title='#xowiki.notifications_title#'>#xowiki.notifications#</a>
      <a href="@notification_subscribe_link@" class="notification-image-button">&nbsp;</a>&middot; </if>
      <if @::xowiki::search_mounted_p@ true><a href='#' id='wiki-menu-do-search-control' title='#xowiki.search_title#'>#xowiki.search#</a> &middot; </if>
      <if @index_link@ not nil><a href="@index_link@" accesskey='i' title='#xowiki.index_title#'>#xowiki.index#</a></if>
      <div id='do_search' style='display: none'>
      <form action='/search/search'><div><label for='do_search_q'>#xowiki.search#</label><input id='do_search_q' name='q' type='text'><input type="hidden" name="search_package_id" value="@package_id@"><if @::__csrf_token@ defined><input type="hidden" name="__csrf_token" value="@::__csrf_token;literal@"></if></div></form>
      </div>
      </div>
 
          <div style="width: 100%"> <!-- contentwrap -->

          <div style="float:left; width: 245px; font-size: 85%;">
          <div style="background: url(/resources/xowiki/bw-shadow.png) no-repeat bottom right;
     margin-left: 6px; margin-top: 6px; padding: 0px;
">
          <div style="position:relative; right:6px; bottom:6px;  border: 1px solid #a9a9a9; padding: 5px 5px; background: #f8f8f8">
          <include src="/packages/xowiki/www/portlets/weblog-mini-calendar" &__including_page=page
          summary="0" noparens="0">
          <include src="/packages/xowiki/www/portlets/include" &__including_page=page
          portlet="tags -decoration plain">
          <include src="/packages/xowiki/www/portlets/include" &__including_page=page
          portlet="tags -popular 1 -limit 30 -decoration plain">
          <hr>
          <include src="/packages/xowiki/www/portlets/include" &__including_page=page
          portlet="presence -interval {30 minutes} -decoration plain">
          <hr>
          <a href="contributors" title="Show People contributing to this XoWiki Instance">Contributors</a>
          </div>
          </div> <!-- background -->

          <div style="background: url(/resources/xowiki/bw-shadow.png) no-repeat bottom right;
     margin-left: 6px; margin-top: 6px; padding: 0px;
">
          <div style="position:relative; right:6px; bottom:6px;  border: 1px solid #a9a9a9; padding: 5px 5px; background: #f8f8f8">
          <include src="/packages/xowiki/www/portlets/include" &__including_page=page
          portlet="categories -open_page [list @name@] -decoration plain">
          </div></div>  <!-- background -->
          </div>

          <div style="margin-left: 260px;"> <!-- content -->
           @top_includelets;noquote@
 <if @body.menubarHTML@ not nil><div class='visual-clear'><!-- --></div>@body.menubarHTML;noquote@</if>
 <if @page_context@ not nil><h1>@body.title@ (@page_context@)</h1></if>
 <else><h1>@body.title@</h1></else>
 <if @folderhtml@ not nil> 
 <div class='folders' style=''>@folderhtml;noquote@</div> 
 <div class='content-with-folders'>@content;noquote@</div> 
 </if>
    <else>@content;noquote@</else>
          </div> <!-- content -->
          </div> <!-- contentwrap -->

        
@footer;noquote@
</div> <!-- class='xowiki-content' -->
