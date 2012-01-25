<master src="/packages/openacs-default-theme/lib/plain-master">
<if @doc@ defined><property name="&doc">doc</property></if>
<if @body@ defined><property name="&body">body</property></if>
<if @head@ not nil><property name="head">@head;noquote@</property></if>
<if @focus@ not nil><property name="focus">@focus;noquote@</property></if>
<if @context@ not nil><property name="context">@context;noquote@</property></if>
<if @show_tabs_p@ true>
<property name="&navigation">navigation</property>
</if>
<property name="main_content_p">@main_content_p@</property>

<if @pageset_page_p@>
  <slave>
</if>
<else>
  <include src="@theme.template@" title="@title@" &="__adp_slave">
</else>
