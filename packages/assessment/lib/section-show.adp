<h3>#assessment.Items#</h3>

<formtemplate id="show_section">
<table cellspacing="0">
<if @items:rowcount@ eq 0>
</if>

<multiple name="items">

  <if @items.rownum@ odd>
    <tr class="odd">
  </if>
  <else>
    <tr class="even">
  </else>

<td valign="top">@items.rownum@. @items.name@<if @items.required_p;literal@ true> <span style="color:red>*</span> </if>
<if @items.max_time_to_complete@ not nil> (#assessment.max_time# @items.max_time_to_complete@) </if>
(@items.points@ #assessment.points#)
</td></tr>

  <if @items.rownum@ odd>
    <tr class="odd">
  </if>
  <else>
    <tr class="even">
  </else>
<td>
    <if @items.presentation_type@ ne fitb>@items.title;noquote@<br></if>
    <if @items.presentation_type@ eq rb or @items.presentation_type@ eq cb>
      <formgroup id="response_to_item.@items.as_item_id@">
        @formgroup.widget;noquote@ @formgroup.label;noquote@<br>
      </formgroup>
    </if>
    <elseif @items.presentation_type@ eq fitb>
      @items.html;noquote@
    </elseif>
    <else>
      <formwidget id="response_to_item.@items.as_item_id@">
    </else>
    <if @items.subtext@ not nil>
      <div class="form-help-text">
      <img src="/shared/images/info.gif" width="12" height="9" alt="[i]" title="Help text" border="0">
      <noparse>@items.subtext@</noparse>
      </div>
    </if>
</td></tr>

</multiple>
</table>      
</formtemplate>
