<master src="customize-portal">
<property name="page_id">@page_id@</property>
<property name="columns">1</property></master>


<div id="main">
      
  <div id="main-content">
    <div class="main-content-padding getDrag">
      <list name="element_id_list" value="@columns.1@">
        <include src="/packages/layout-manager/lib/render/render-element"
          &="pageset"
          element_id="@element_id_list:item@"
	  column=1>
       </list>
    </div> <!-- /main-content-padding -->
  </div> <!-- /main-content -->
      
</div> <!-- /main -->
