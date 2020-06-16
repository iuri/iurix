<master src="master">
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <property name="signatory">@ec_system_owner;noquote@</property>

  <property name="current_location">your-account</property>

  <div class="page-wrapper">

    <h1>#ecommerce.My_orders#</h1>

    <div class="box-white" style="text-align:center;margin-left:12%; width:73%;">    

      <if @orders:rowcount@ gt 0>
      <br>
        <div class="row" style="background-color:#cccccc;">
	  <div class="col-sm-3"></div>
	  <div class="col-sm-3">Numero do Pedido</div>
	  <div class="col-sm-3">Data</div>
	  <div class="col-sm-3">Status</div>
        </div>
  
	<multiple name="orders">
	  <a href="order?order_id=@orders.order_id@">
	    <div class="row">
	      <div class="col-sm-3"><img src="https://www.evex.co/themes/front/ico/EvexCarrinhoOlhinho.png" width="15%">
	      </div>
	      <div class="col-sm-3">@orders.order_id@</div>
	      <div class="col-sm-3">@orders.confirmed_date@</div>
	      <div class="col-sm-3">@orders.status;noquote@</div>
	    </div>
	  </a>
      	</multiple>
      </if>
      <else>
        #ecommerce.Theres_no_orders#
      </else>
        <div class="row">
	  <div class="col-sm-12">
        <button class="button-pink" style="width:200px;" onclick="javascript:window.location.replace('https://www.evex.co/welcome/search_items')" style="float:left;">#ecommerce.Request_proposals#</button>
</div>

    </div>
  </div>
