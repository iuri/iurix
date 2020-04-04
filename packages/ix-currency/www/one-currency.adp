<master>
<property name="header_stuff"></property>
<property name="context">@context;noquote@</property>
<property name="title">@title;noquote@</property>

<SCRIPT Language="JavaScript" src="/resources/diagram/diagram/diagram.js"></SCRIPT></property>

<include src="/packages/ix-currency/lib/currencies-display">

<h1>USD $1 | @pretty_code;noquote@
<if @diff@ lt 0.0000><span style="color:red;">$@rate;noquote@ @diff;noquote@ @percent;noquote@%</span> </if>
<else>
  <if @diff@ gt 0><span style="color:green;">$@rate;noquote@ @diff;noquote@ @percent;noquote@%</span> </if>
  <else><span style="color:blue;">$@rate;noquote@ @diff;noquote@ @percent;noquote@%</span> </else>
</else>

 <script id="facebook-jssdk" src="//connect.facebook.net/en_GB/all.js#xfbml=1"></script>
  <div class="fb-like" data-href="@page_url@" data-send="false" data-layout="button_count" data-width="200" data-show-faces="false"></div>

<!--   <a href="http://www.facebook.com/sharer.php?u='@url@'" target="_blank" ><img src="img/en/icon-sahre-fb.png" alt="" /> </a> -->

 </h1>




<include src="chart-line" &="rate" &="percent" &="diff" &="usd_rate" &="code" &="pretty_code">
<div data-href="http://iurix.com/ix-currency/" data-layout="button"></div>
      		  