<master src="master">
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>

  <property name="current_location">Product Search</property>
  <property name="search_text">@search_text@</property>
  <property name="category_id">@category_id@</property>
  <property name="subcategory_id">@subcategory_id@</property>
  <property name="combocategory_id">@combocategory_id@</property>

  <div class="page-wrapper" style="margin-top:6%;">


    <include src="/packages/ecommerce/lib/toolbar"/>

    <div style="text-align:center; padding:15px;">
    
    <include src="/packages/ecommerce/lib/searchbar" combocategory_id=@combocategory_id@ category_id=@category_id@ subcategory_id=@subcategory_id@ search_text=@search_text@ />

    @search_results;noquote@
    </div>
  </div>


