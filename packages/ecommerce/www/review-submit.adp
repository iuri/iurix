<master src="master">


<h1>#ecommerce.Add_Review#</h1>
  <div class="box-white" style="margin-left:9%;width:86%; text-align:center;">
    <form method="post" action="review-submit-2" onSubmit="return validateForm();">
      <input type="hidden" name="product_id" value="@product_id@">
        <div class="form-group">
    	  <label class="form-check-label" for="rating-widget">#ecommerce.What_is_your_rating_lt#</label>
      	  @rating_widget;noquote@
	</div>
	  <div class="form-group">
    	    <label class="form-check-label" for="review-headline">#ecommerce.Please_enter_a_headline_lt#</label>
      	    <input type="text" size="50" class="form-control" name="one_line_summary">
	  </div>
      	  <div class="form-group">
    	    <label class="form-check-label" for="review-description">#ecommerce.Enter_your_review_below#</label>
      	    <textarea wrap name="user_comment" class="form-control" rows="6" cols="50"></textarea>
    	  </div>
	  <div class="form-group">    	  
    	      <button id="cancel" class="button-yellow" style="float:left;" name="cancel" value="">#ecommerce.Cancel#</button> 
    	      <button class="button-pink" type="submit" style="float:right;" value="1">#ecommerce.Save#</button>
	  </div>
	</form>
	<br><br><br>
      </div>



<script>

  function validateForm(form) {

    if(document.getElementById('online_summary').value == "") {
      alert("Título é obrigatorio!");
      return false;
    }
    if(document.getElementById('user_comment').value == "") {
      alert("Avaliação é obrigatória!");
      return false;
    }
    return true;
  }

</script>
