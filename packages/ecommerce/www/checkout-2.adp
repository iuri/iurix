<master src="master">
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <property name="signatory">@ec_system_owner;noquote@</property>


  <div class="page-wrapper" style="margin-top:6%;">
    <include src="/packages/ecommerce/lib/checkout-progress" step="2">
    <blockquote>
      <p>#ecommerce.Please_verify_that_lt# </p>
      <div class="row">
	<div class="col-sm-3"></div>      
  	<div class="col-sm-2">#ecommerce.Quantity#</div>
	<div class="col-sm-4">#ecommerce.Item#</div>
	<div class="col-sm-3"></div>
      </div>  	 
      <form method="post" action="@form_action@">
        @rows_of_items;noquote@
    	<p>@tax_exempt_options;noquote@</p>
        <div class="row">
	  <div class="col-sm-3"></div>      
  	  <div class="col-sm-2"></div>
	  <div class="col-sm-4">
	    <button type="submit" name="submit" class="button-pink">#ecommerce.Next#</button></div>
	  <div class="col-sm-3"></div>
        </div>  	 
      </form>
    </blockquote>
  </div>