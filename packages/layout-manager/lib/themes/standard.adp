<!-- Portal Element '@title@' begin -->

<if @element_id_p@><div class="portlet-wrapper itemDrag" id="@element_id@"></if>
<else><div class="portlet-wrapper></else>
  <if @title@ not nil>
    <div class="portlet-header">
      <div class="portlet-title">
        <if @element_id_p@><h1 id="@ds_name@">@title;noquote@
	  <if @customize@>
	    <if @admin_p@><span><a href="@hide_url@">x</a></span></if></h1></if>
	  </if>
	<else><h1 id="@ds_name@">@title;noquote@</h1></else>
      </div>
      <div class="portlet-controls"></div>
    </div>
  </if>
  <div class="portlet">
    <slave />
  </div> <!-- /portlet -->
</div> <!-- /portlet-wrapper -->


