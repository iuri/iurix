<master src="master">
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <property name="signatory">@ec_system_owner;noquote@</property>



  <h1>#ecommerce.Confirmation#</h1>
  <div class="box-white" style="margin-left:9%;width:86%; text-align:center;">
  <if @comments_need_approval@ true>
    <p>#ecommerce.Your_review_has_been_lt# <a
      href="@ec_system_owner@">@ec_system_owner@</a>.</p>
  </if>
  <else>
    <p>Your review has been received. Thanks for sharing your
      thoughts with us! Your review is now viewable from the
      @product_name page@.</p>
  </else>
  <br>
  <button class="button-pink" onclick="javascript:window.location.replace('@product_link@');">#ecommerce.Return#</button>
</blockquote>
