<master src="master">
  <property name="doc(title)">@product_name;noquote@</property>
  <property name="context">@context;noquote@</property>
  <property name="signatory">@ec_system_owner;noquote@</property>

  <property name="combocategory_id">@combocategory_id@</property>
  <property name="search_text">@search_text@</property>
  <property name="category_id">@category_id@</property>
  <property name="subcategory_id">@subcategory_id@</property>  

  <div class="page-wrapper" style="margin-top:6%;">
    <include src="/packages/ecommerce/lib/toolbar">
    @product_code_output;noquote@
    
    <br>
    <include src="/packages/ecommerce/lib/product-files-list" product_id="@product_id@">
    <include src="/packages/ecommerce/lib/searchbar" category_id="@category_id@" subcategory_id="@subcategory_id@" search_text="@search_text@">

  </div>