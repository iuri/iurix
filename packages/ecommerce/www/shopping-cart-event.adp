<master src="master">
  <property name="doc(title)">@title@</property>
  <property name="context">@context;noquote@</property>
  <property name="signatory">@ec_system_owner;noquote@</property>

  <property name="current_location">shopping-cart</property>
 
  <div class="page-wrapper" style="margin-top:6%;">
<!--
    <div class="row">
      <div class="col-sm-8">
      </div>
      <div class="col-sm-4">
        <if @user_id@ ne 0>
          <p>#ecommerce.If_you_are_not#  If you're not @first_names@ @last_name@
          <button class="button-pink" onclick="javascript:window.location.replace('@logout_url@');">#ecommerce.click_here#</button></p>
        </if>
      </div>
    </div>
-->
    <h1>#ecommerce.My_shopping_cart#</h1>

    <div class="box-white" style="text-align:center; width:73%; margin-left:13%;">


      <if @product_counter@ ne 0>
        <form method=post action=shopping-cart-quantities-change>
          <div class="row" style="background-color:#cccccc; display:inline-block; width:100%;" >
    	    <div class="col-sm-2">#ecommerce.Description#</div>
	    <div class="col-sm-2">#ecommerce.Options#</div>
	    <div class="col-sm-2">#ecommerce.Quantity#</div>
	    <div class="col-sm-2">#ecommerce.Price_Item#</div>
	    <if @product_counter@ gt 1> <div class="col-sm-2">#ecommerce.Subtotal#</div> </if>
            <div class="col-sm-2"><!--#ecommerce.Action#--></div>
          </div>
      
	  <multiple name="in_cart">
      	    <div class="row" style="display:inline-block; width:100%;" >
              <div class="col-sm-2">
	        <!-- Commented out product name  @in_cart.sku;noquote@ <a href="product?product_id=@in_cart.product_id@">@in_cart.product_name;noquote@</a> -->
	  	@in_cart.product_name;noquote@
	      </div>
	      <div class="col-sm-2">
	        <if @in_cart.color_choice@ not nil>
	          Color: @in_cart.color_choice@
	        </if>
              	<if @in_cart.size_choice@ not nil>
	          <br>Size: @in_cart.size_choice@
	        </if>
                <if @in_cart.style_choice@ not nil>
	          <br>Style: @in_cart.style_choice@
	        </if>
	      </div>
	      <div class="col-sm-2">
                <input type="text" name="quantity.@in_cart.product_id@" value="@in_cart.quantity@" size="@max_quantity_length@" maxlength="@max_quantity_length@">
                <input type="hidden" name="color_choice" value="@in_cart.color_choice@">
                <input type="hidden" name="size_choice" value="@in_cart.size_choice@">
                <input type="hidden" name="style_choice" value="@in_cart.style_choice@">
	      </div>
	      <div class="col-sm-2">@in_cart.price;noquote@</div>
	      <if @product_counter@ gt 1> <div class="col-sm-2">@in_cart.line_subtotal@</div> </if>
              <div class="col-sm-2">
	        <a style="padding:10px;" href="shopping-cart-delete-from?@in_cart.delete_export_vars@"><i class="fa fa-trash" title="delete"></i></a>
	      </div>
            </div>
          </multiple>
          <div class="row" style="background-color:#cccccc;">
            <div class="col-sm-4">Total:</div>
      	    <div class="col-sm-2">@product_counter@ </div>
      	    <if @product_counter@ gt 1><div class="col-sm-2">&nbsp;</div></if>
      	    <div class="col-sm-2">
              <if @includes_display_zero_as_items@ true>**</if>
	      @pretty_total_price@</div>
      	    <div class="col-sm-2"><input type=submit value="#ecommerce.Update#"></div>
          </div>


    	  <if @shipping_gateway_in_use@ false>
      	    <if @no_shipping_options@ false>
              <div class="row">
      	        <if @product_counter@ gt 1><div class="col-sm-4" style="float:right;"></if>
      	        <else><div class="col-sm-3" style="float:right;"></else>
                  @shipping_options@
		</div>
		<div class="col-sm-2">@total_reg_shipping_price@</div>
	  	<div class="col-sm-2">
	    	  <if @paypal_standard_mode@ eq 3>@paypal_checkout_button_stand;noquote@</if>
	    	  <else>standard</else>
 	  	</div>
      	      </div>
      	      <if @offer_express_shipping_p@ true>
                <div class="row">
            	  <if @product_counter@ gt 1><div class="col-sm-4"></if>
            	  <else> <div class="col-sm-3"></else>
            	  &nbsp;</div>
            	  <div class="col-sm-2" style="float:rightl">@total_exp_shipping_price@</div>
	    	  <div class="col-sm-2">
	      	    <if @paypal_standard_mode@ eq 3>
	              @paypal_checkout_button_expr;noquote@
	      	    </if>
	      	    <else>express</else>
	    	  </div>
	  	</div>
              </if>
      	      <if @offer_pickup_option_p@ true>
                <div class="row">
            	  <if @product_counter@ gt 1><div class="col-sm-4"> </if>
            	  <else><td colspan="3"></else>&nbsp;</div>
            	  <div class="col-sm-2"> style="float:right;">$0.00 <!-- @shipping_method_pickup@ --> </div>
	    	  <div class="col-sm-2">pickup</div>
          	</div>
              </if>
      	    </if>
    	  </if>

    	  <if @includes_display_zero_as_items@ true>
      	    <div class="row">
              <div class="col">
                <p>** - Special message for items marked as @display_price_of_zero_as@</p>
      	      </div>
      	    </div>
    	  </if>
    	  <multiple name="tax_entries">
      	    <div class="row">
              <div class="col">
      	        <p> Residents of @tax_entries.state@, @tax_entries.pretty_tax@ sales tax will be added to your order on checkout.*</p>
	      </div>
      	    </div>
    	  </multiple>
        </form>
      </if>
    























<if @shipping_gateway_in_use@ true>
    @shipping_options;noquote@
</if>


<center>

<if @event_id@ eq 0>
  <if @paypal_standard_mode@ eq 0>
      <form method=post action="checkout-one-form">
        <input class="button-pink" type=submit value="#ecommerce.Proceed_to_Checkout#"><br>
      </form>
  </if><else>
    <if @paypal_standard_mode@ ne 3>
      @paypal_checkout_button;noquote@
    </if><else>
      <if @paypal_shipping_mode@ eq 1>
        @paypal_checkout_button;noquote@
      </if>
    </else>
  </else>
</if>
</center>




<if @product_counter@ eq 0>
  <div class="row">
    <div class="col-12">
      <img src="https://www.evex.co/themes/front/ico/shopping-cart-empty.svg" style="width:10%;"><br>
      #ecommerce.Your_Shopping_Cart_is_empty#<br><br>
      <button class="button-yellow" onclick="javascript:window.location.replace('https://www.evex.co/welcome/search_items');">#ecommerce.Select_products#</button>
    </div>
  </div>
</if>
<else>
  <div class="row">
    <div class="col-12">
      <button class="button-pink" onclick="javascript:window.location.replace('shopping-cart-save');">#ecommerce.Save_cart#</button>
    </div>
  </div>


  <if @event_id@ ne "">
       <br><br>
       <form id="request-proposal" onSubmit="return validateCart();" action="/eventos/request-proposal" method="POST">
         <input type="hidden" name="product_id" value="@product_ids@">
         <input type="hidden" name="event_id" value="@event_id@">
	 <input type="hidden" name="order_id" value="@order_id@">	
     	 <a class="button-yellow" href="#" style="float:left;" onclick="javascript:window.location.replace('https://www.evex.co/welcome/search_items')">#ecommerce.Select_products#</a>    	  
         <button class="button-pink" style="float:right;" id="submit">#ecommerce.Request_proposal#</button>
        </form>
	<br><br>
  </if><else>
    <div class="row">
      <div class="col-12">
         <h4 style="color:#ed125f;">#ecommerce.You_need_to_select_lt#</h4>
      </div>
    </div>
    <div class="row">
      <div class="col-sm-4" style="padding-bottom:5px;">
        <button class="button-gray" style="width:200px;" onclick="javascript:window.location.replace('https://www.evex.co/welcome/search_items')" style="float:left;">#ecommerce.Select_products#</button>    	  
      </div>
      <div class="col-sm-4" style="padding-bottom:5px;">	
         <button class="button-yellow" style="width:200px;" onclick="javascript:window.location.replace('/eventos/list');">Evento Existente</button>	     <br>
      </div>
      <div class="col-sm-4" style="padding-bottom:5px;">
      	 <button class="button-pink" style="width:200px;" onclick="javascript:window.location.replace('/eventos/new?return_url=/ecommerce/shopping-cart');" style="float:right;">Novo Evento</button>
      </div>
    </div>
  </else>
</else>
   
	 
 

<!--
  <ul>
   <if @previous_product_id_p@ eq 1>
      <li> <a href="index?product_id=@previous_product_id@">Continue Shopping</a> </li>  
    </if>
    <else>
      <li> <a href="index">Continue Shopping</a> </li> 
      <li> <a href="https://www.evex.co/welcome/search_items">#ecommerce.Continue_Shopping#</a> </li> 

    </else>
    <if @user_id@ eq 0>
      <li> <a href="/register/index?return_url=@return_url@">Log In</a> </li>
    </if>
    <else>
      <if @saved_carts_p@ not nil>
        <li><a href="shopping-cart-retrieve-2">Retrieve a Saved Cart</a> </li>
      </if>
    </else>

    <if @product_counter@ ne 0>
      <li><a href="shopping-cart-save">Save Your Cart for Later</a> </li>
    </if>
  </ul>
    -->
</div>



</div>





<script>
  function IvalidateCart() {
    var eventId = document.getElementById("event_id");
    alert(eventId);
    if (eventId.value == "") {
      alert("É necessário criar um evento para solicitar proposta");
      return false;
    }
    var productId = document.getElementByI("product_id");
    if (productId.value == "") { 
      alert('#ecommerce.Your_Shopping_Cart_is_empty# #ecommerce.Add_products#');
      return false;
    }

    return true;

  }
</script>