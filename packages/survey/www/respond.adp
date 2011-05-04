<master>
<property name=title>#survey.One_Survey_name#</property>
<property name=context>@context;noquote@</property>
<property name="header_stuff">
<script type="text/javascript">
	function disableHandler (form_name, max_size, search_pattern) {
		// Corrige tamanho do campo, já que o primeiro índice no JavaScript é zero
		var max_size = max_size - 1;
		var form_size = document.forms[form_name].elements.length;
		var i = 0;
		var k = 0;
		var inputs = new Array();
		for (j = 0; j < form_size; ++j) {
			var element_name = document.forms[form_name].elements[j].name
			if (element_name.search(search_pattern) != -1) {
				inputs[i] = document.forms[form_name].elements[j];
				i++;
			}
		}
		for (var i = 0; i < inputs.length; i++) {
			var input = inputs[i];
			input.onclick = function (evt) {
				if (this.checked) {
					++k;
					if (k > max_size) {
						for (var l = 0;l < inputs.length; ++l) {
							if (inputs[l].checked) {
								inputs[l].disabled = false;
							} else {
								inputs[l].disabled = true;
							}
						}
					}
				} else {
					k = k - 1;
					if (k <= max_size) {
						for (var l = 0;l < inputs.length; ++l) {
							inputs[l].disabled = false;
						}
					}
				}
				return true;
			};
		}
	}
	
</script>

</property>
<body onload="@javascript_load;noquote@">

    <table border="0" cellpadding="0" cellspacing="0" width="100%">
      <form enctype=multipart/form-data method="post" action="process-response" id="responses">
	<if @initial_response_id@ not nil><input type="hidden"
	name="initial_response_id" value="@initial_response_id@"></if>
        <tr>
          <td class="tabledata">@description;noquote@</td>
        </tr>
	<tr>
	  <td class="tabledata"><span style="color: #f00;">*</span> #survey.lt_denotes_a_required_qu#</td>                
	</tr>        
        <tr>
          <td class="tabledata"><hr noshade size="1" color="#dddddd"></td>
        </tr>
        
        <tr>
          <td class="tabledata">
	    @form_vars;noquote@
            <include src="one_@display_type;noquote@" questions=@questions;noquote@>
            <hr noshade size="1" color="#dddddd">
              <input type="submit" value="@button_label@">
          </td>
        </tr>
        
      </form>
    </table>
