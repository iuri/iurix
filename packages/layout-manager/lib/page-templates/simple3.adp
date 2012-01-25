<master src="customize-portal">
<property name="page_id"></property>
<property name="columns">3</property></master>


<div id="main">
  <div id="main-content">
    <div class="main-content-padding  getDrag">
      <list name="element_id_list" value="@columns.2@">
        <include src="/packages/layout-manager/lib/render/render-element"
          &="pageset"
          element_id="@element_id_list:item@"
	  column=3>
      </list>
    </div> <!-- /main-content-padding -->
  </div> <!-- /main-content -->

  <div id="sidebar-1">
    <div class="sidebar-1-padding getDrag">
      <list name="element_id_list" value="@columns.1@">
        <include src="/packages/layout-manager/lib/render/render-element"
          &="pageset"
          element_id="@element_id_list:item@"
	  column=2>
      </list>
    </div> <!-- /sidebar-1-padding -->
  </div> <!-- /sidebar-1 -->
</div> <!-- /main -->
      
<div id="sidebar-2">
  <div class="sidebar-2-padding getDrag">
    <list name="element_id_list" value="@columns.3@">
       <include src="/packages/layout-manager/lib/render/render-element"
         &="pageset"
         element_id="@element_id_list:item@"
	  column=1>
    </list>
  </div> <!-- /sidebar-2-padding -->
</div> <!-- /sidebar-2 -->
