<master src="master">
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <property name="signatory">@ec_system_owner;noquote@</property>

  <div class="page-wrapper">

    <h1>#ecommerce.Order# @order_id@</h1>


    <div class="box-white" style="text-align:center; width:73%;">    

      <blockquote>
      <pre>
      Status: @status;noquote@
      @summary;noquote@
      </pre>


      </blockquote>
      <button class="button-yellow" onclick="javascript:window.history.back();">Voltar</button>
    </div>
  </div>

<!--
<!-- <include src="/packages/ecommerce/lib/toolbar"> -->
<!-- <include src="/packages/ecommerce/lib/searchbar"> -->

-->