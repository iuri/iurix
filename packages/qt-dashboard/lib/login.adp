<property name="focus">@focus;literal@</property>


<div class="foto-fondo">
<div class="container">
<div class="registro row">
<div class="col-md-4 col-md-offset-4">
<div class="panel panel-login">
<div class="panel-heading">
<div class="row">
</div>
<hr>
</div>
<div class="panel-body">
<div class="row">
<div class="col-lg-12">
<formtemplate id="login"></formtemplate>
<if @forgotten_pwd_url@ not nil>
  <if @email_forgotten_password_p;literal@ true>
  <a href="@forgotten_pwd_url;literal@" true>#acs-subsite.Forgot_your_password#</a>
  <br>
  </if>
</if>
</div>
</div>
</div>
<div class="form-group">
<div class="row">
<div class="col-lg-12">
<div class="text-center">
<if @self_registration;literal@ true>

<if @register_url@ not nil>
  #qt-dashboard.Dont_have_an_account#<br>
  <a href="@register_url@">#qt-dashboard.SignUp#</a>
</if>

</if>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>

<script type="text/javascript">

$(document).ready(function() {
  $.post("/api/login", {
    email: "rzevallos@hexas.biz",
    password: "52283681"
  }).then(function(data) {
   // window.location.replace(data);
    // If there's an error, log the error
  }).catch(function(err) {
    console.log(err);
  });
});
</script>