<!-- Generated by ::xowiki::ADP_Generator on Sun Oct 04 00:27:02 -03 2020 -->
<master>
                  <property name="context">@context;literal@</property>
                  <if @item_id@ not nil><property name="displayed_object_id">@item_id;literal@</property></if>
                  <property name="&body">body</property>
                  <property name="&doc">doc</property>
                  <property name="head">
      @header_stuff;literal@</property>
<!-- The following DIV is needed for overlib to function! -->
          <div id="overDiv" style="position:absolute; visibility:hidden; z-index:1000;"></div>    
          <div class='xowiki-content'>


<%
if {$book_prev_link ne ""} {
  template::add_event_listener  -id bookNavPrev.a  -preventdefault=false  -script [subst {TocTree.getPage("$book_prev_link");}]
}
if {$book_next_link ne ""} {
  template::add_event_listener  -id bookNavNext.a  -preventdefault=false  -script [subst {TocTree.getPage("$book_next_link");}]
}
%>                      <div style="float:left; width: 25%; font-size: .8em;
     background: url(/resources/xowiki/bw-shadow.png) no-repeat bottom right;
     margin-left: 6px; margin-top: 6px; padding: 0px;
">
                      <div style="position:relative; right:6px; bottom:6px; border: 1px solid #a9a9a9; padding: 5px 5px; background: #f8f8f8">
                      @toc;noquote@
                      </div></div>
                      <div style="float:right; width: 70%;">
                      <if @book_prev_link@ not nil or @book_relpos@ not nil or @book_next_link@ not nil>
                      <div class="book-navigation" style="background: #fff; border: 1px dotted #000; padding-top:3px; margin-bottom:0.5em;">
                      <table width='100%'
                      summary='This table provides a progress bar and buttons for next and previous pages'>
                      <colgroup><col width='20'><col><col width='20'>
                      </colgroup>
                      <tr>
                      <td>
                      <if @book_prev_link@ not nil>
                      <a href="@book_prev_link@" accesskey='p' id="bookNavPrev.a">
                      <img alt='Previous' src='/resources/xowiki/previous.png' width='15' id="bookNavPrev.img"></a>
                      </if>
                      <else>
                      <a href="" accesskey='p' id="bookNavPrev.a">
                      <img alt='No Previous' src='/resources/xowiki/previous-end.png' width='15' id="bookNavPrev.img"></a>
                      </else>
                      </td>

                      <td>
                      <if @book_relpos@ not nil>
                      <table width='100%'>
                      <colgroup><col></colgroup>
                      <tr><td style='font-size: 75%'><div style='width: @book_relpos@;' id='bookNavBar'></div></td></tr>
                      <tr><td style='font-size: 75%; text-align:center;'><span id='bookNavRelPosText'>@book_relpos@</span></td></tr>
                      </table>
                      </if>
                      </td>

                      <td id="bookNavNext">
                      <if @book_next_link@ not nil>
                      <a href="@book_next_link@" accesskey='n' id="bookNavNext.a">
                      <img alt='Next' src='/resources/xowiki/next.png' width='15' id="bookNavNext.img"></a>
                      </if>
                      <else>
                      <a href="" accesskey='n' id="bookNavNext.a">
                      <img alt='No Next' src='/resources/xowiki/next-end.png' width='15' id="bookNavNext.img"></a>
                      </else>
                      </td>
                      </tr>
                      </table>
                      </div>
                      </if>

                      <div id='book-page'>
                      <include src="view-page" &="package_id"
                      &="references" &="name" &="title" &="item_id" &="page" &="context" &="header_stuff" &="return_url"
                      &="content" &="references" &="lang_links" &="package_id"
                      &="rev_link" &="edit_link" &="delete_link" &="new_link" &="admin_link" &="index_link"
                      &="tags" &="no_tags" &="tags_with_links" &="save_tag_link" &="popular_tags_link"
                      &="per_object_categories_with_links"
                      &="digg_link" &="delicious_link" &="my_yahoo_link"
                      &="gc_link" &="gc_comments" &="notification_subscribe_link" &="notification_image"
                      &="top_includelets" &="folderhtml" &="page" &="doc" &="body">
                      </div>
                      </div>
                    
@footer;noquote@
</div> <!-- class='xowiki-content' -->
