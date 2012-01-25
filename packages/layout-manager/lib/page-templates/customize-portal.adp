
<slave>

<script type="text/javascript">
  jQuery(document).ready(
	function () {
		jQuery('.getDrag').Sortable(
			{
				accept			: 'itemDrag',
				helperclass		: 'dragAjuda',
				activeclass 	        : 'dragAtivo',
				hoverclass 		: 'dragHover',
				handle			: 'h1',
				opacity			: 0.7,
				onChange 		: function()
				{	    
				},
				onStart : function()
				{
				},
				onStop : function()
				{
					<if @columns@ eq 1>
					   jQuery('.main-content-padding').children().each(function(i) {
					    	var divs = jQuery(this);
						new Ajax.Request('@element_modify_url@',{asynchronous:true,method:'post',parameters:'return_url=@return_url@&page_column=1&pageset_id=@pageset_id@&page_id=@page_id@&sort_key='+ i + '&element_id=' + jQuery(divs).attr('id')}); 
					    });
					</if>
					<if @columns@ eq 2>
					   jQuery('.main-content-padding').children().each(function(i) {
					        var divs = jQuery(this);
						new Ajax.Request('@element_modify_url@',{asynchronous:true,method:'post',parameters:'return_url=@return_url@&page_column=1&pageset_id=@pageset_id@&page_id=@page_id@&sort_key='+ i + '&element_id=' + jQuery(divs).attr('id')}); 
					    });
					    
					    jQuery('.sidebar-1-padding').children().each(function(i) {
					    	var divs = jQuery(this);
						new Ajax.Request('@element_modify_url@',{asynchronous:true,method:'post',parameters:'return_url=@return_url@&page_column=2&pageset_id=@pageset_id@&page_id=@page_id@&sort_key='+ i + '&element_id=' + jQuery(divs).attr('id')}); 
					    }); 
					 </if>
					 
					 <if @columns@ eq 3>
					    jQuery('.main-content-padding').children().each(function(i) {
					        var divs = jQuery(this);
					        new Ajax.Request('@element_modify_url@',{asynchronous:true,method:'post',parameters:'return_url=@return_url@&page_column=1&pageset_id=@pageset_id@&page_id=@page_id@&sort_key='+ i + '&element_id=' + jQuery(divs).attr('id')}); 
					    });
					    
					    jQuery('.sidebar-1-padding').children().each(function(i) {
					    	var divs = jQuery(this);
						new Ajax.Request('@element_modify_url@',{asynchronous:true,method:'post',parameters:'return_url=@return_url@&page_column=2&pageset_id=@pageset_id@&page_id=@page_id@&sort_key='+ i + '&element_id=' + jQuery(divs).attr('id')}); 
					    }); 

   				            jQuery('.sidebar-2-padding').children().each(function(i) {
					        var divs = jQuery(this);
						new Ajax.Request('@element_modify_url@',{asynchronous:true,method:'post',parameters:'return_url=@return_url@&page_column=3&pageset_id=@pageset_id@&page_id=@page_id@&sort_key='+ i + '&element_id=' + jQuery(divs).attr('id')}); 
					     });
					  </if>
				}
			}
		);
	}
);
</script>
