<!-- Generated by ::xowiki::ADP_Generator on Thu Oct 15 15:20:12 -03 2020 -->
<!-- The following DIV is needed for overlib to function! -->
          <div id="overDiv" style="position:absolute; visibility:hidden; z-index:1000;"></div>    
          <div class='xowiki-content'>

 @top_includelets;noquote@
 <if @body.menubarHTML@ not nil><div class='visual-clear'><!-- --></div>@body.menubarHTML;noquote@</if>
 <if @page_context@ not nil><h1>@body.title@ (@page_context@)</h1></if>
 <else><h1>@body.title@</h1></else>
 <if @folderhtml@ not nil> 
 <div class='folders' style=''>@folderhtml;noquote@</div> 
 <div class='content-with-folders'>@content;noquote@</div> 
 </if>
    <else>@content;noquote@</else>

</div> <!-- class='xowiki-content' -->
