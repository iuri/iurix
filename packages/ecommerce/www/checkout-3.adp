<master src="master">
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <property name="signatory">@ec_system_owner;noquote@</property>

  <div class="page-wrapper" style="margin-top:6%;">
    <if @display_progress@ true>
      <include src="/packages/ecommerce/lib/checkout-progress" step="6">
    </if>

    <blockquote>

      <form method="post" action="finalize-order">
        @export_form_vars_html;noquote@
       	@order_summary;noquote@
 	<input type="submit" value="#ecommerce.To_buy#">
      </form>
    </blockquote>
  </div>