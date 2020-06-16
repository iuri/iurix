<master src="master">
  <property name="doc(title)">@title@</property>
  <property name="context">@context;noquote@</property>
  <property name="signatory">@ec_system_owner;noquote@</property>

  <property name="current_location">your-account</property>



  <div class="page-wrapper" style="margin-top:6%;">
    <h1>#ecommerce.My_shopping_cart#</h1>
    <include src="/packages/ecommerce/lib/toolbar">

    <div style="text-align:center; padding:15px;">
    
      <include src="/packages/ecommerce/lib/searchbar">
    
      <blockquote>
        <p>We think that you are @user_name@. <br> If not, please <a href="@register_link@">log in</a>. Otherwise,</p><br>
        <form method=post action="shopping-cart-save-2">
          <center>
            <button class="button-pink" type=submit>Continue</button>
          </center>
        </form>
      </blockquote>
    </div>
  </div>
</div>