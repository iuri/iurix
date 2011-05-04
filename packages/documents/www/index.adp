<master>

<table width="100%">
    <tr>
      <td valign="top" align="left"><h1>#documents.Documents#</h1></td>
      <td width="100%" valign="top" align="right">
      	  <formtemplate id="search" style="inline"></formtemplate>
      </td>
     </tr>
</table>
<table width="100%">
    <if @admin_p@>
    <tr>
      <td valign="top" align="left">
        #documents.Admin#: <a href="document-ae">#documents.New#</a><br><br>
      </td>
    </tr> 
    </if>
    <tr>
      <td valign="top" align="center">
      	  <br><br> <h1>#documents.Types#</h1>
      </td>
    </tr>
    <tr>
      <td valign="top" align="center">
        <table width="100%">
	  <tr>
 	    <td valign="top" align="center">
	        <a href="index">#documents.Most_recent#</a>
	    </td>		
      	    <multiple name="document_types">
 	      <td valign="top" align="center">
	        <a href="@document_types.type_url@">@document_types.title;noquote@</a>
	      </td>		
  	    </multiple>
	  </tr>
	</table>
   	   </td>
    </tr>

<if @folder_p@ eq 1>
    <tr>
      <td valign="top" align="center">
      	  <br><br><b>#documents.Type#:</b> @folder_title;noquote@ <br><br>
      </td>
    </tr>
    <tr>
      <td valign="top" align="center">
        <table width="100%">
	  <tr>
	    <if @folder_content:rowcount@ gt 0>
	      <multiple name="folder_content">
 	        <td valign="top" align="center">
	          <a href="@folder_content.item_url;noquote@"><img src="@folder_content.image_url@"><br>@folder_content.title;noquote@</a>
	        </td>		
  	      </multiple>
            </if>
	    <else>
		#documents.No_records#
	    </else> 
	  </tr>
	</table>
      </td>
    </tr>
</if>
<else>
    <tr>
      <td valign="top" align="center">
        <table width="100%">

    <tr>
      <td valign="top" align="center">
      	  <br><br> <h1>#documents.Most_recent#</h1>
      </td>
    </tr>
	  <tr>
      	    <multiple name="most_recent">
 	      <td valign="top" align="center">
	      	 <a href="@most_recent.item_url;noquote@"><img src="@most_recent.image_url@"><br>@most_recent.title;noquote@</a>
	      </td>		
  	    </multiple>
	  </tr>
	</table>
      </td>
    </tr>

</else>
  </table>
