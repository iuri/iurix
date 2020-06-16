<master src="master">
  <property name="doc(title)">@title@</property>
  <property name="context">@context;noquote@</property>
  <property name="signatory">@ec_system_owner;noquote@</property>

  <property name="current_location">shopping-cart</property>

 
  <div class="page-wrapper" style="margin-top:6%;">
    <h1>#ecommerce.My_shopping_cart#</h1>
    <div class="box-white" style="text-align:center; width:73%; margin-left:13%;">
      <include src="/packages/ecommerce/lib/toolbar">
      <include src="/packages/ecommerce/lib/searchbar">

      <blockquote>
        <p>#ecommerce.When_you_re_lt#</p>
      </blockquote>
      <br>
      <button class="button-pink" onclick="javascript:window.location.replace('https://www.evex.co/welcome/search_items');">#ecommerce.Continue_Shopping#</button>
    </div>
  </div>