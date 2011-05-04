<master>
<table width="100%">
  <tr>
    <td valign="top">
        <h1 style="margin-left:100px">Contact Info</h1>
    	<p style="text-align: center;">Iuri de Araujo Sampaio</p>
	<p style="text-align: center;">Phone: 55 11 8778 4294
	<br />&nbsp;&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 55 61 8103 4906</p>
	<p style="text-align: center;">Email: iuri.sampaio@gmail.com&nbsp;</p>
	<hr>
    </td>
  </tr>
  <tr>
    <td valign="top">
        <if @msg@ not nil>
	    <h1 style="color:red;">@msg;noquote@</h1>
	</if>
    	<include src="/packages/email/lib/send-email">
    </td>
  </tr>
</table>