<master>

<include src="/packages/ix-currency/lib/currencies-display">
<h1><p align="right">
  <if @admin_p@ eq 1>
    <a href="admin/">Admin</a> |
  </if>
  <a href="autodeinfracaofederal">Auto de Infra&ccedil;&atilde;o</a> | <a href="/blog/">Blog</a> | <a href="/currencies/">C&acirc;mbio</a> @current_date;noquote@
</p></h1>
<h1>#ix-currency.Convert_Currency#</h1>
<form name="currency_converter">

<input type="text" id="amount" value="#ix-currency.Insert_the_amount#">
<select id="from_cur" name="from_cur">
<option value="">#ix-currency.From#</option>
<multiple name="currencies"><option value="">@currencies.code;noquote@</options></multiple>
</select>
<select id="to_cur" name="to_cur">
<option value="">#ix-currency.To#</option>
<multiple name="currencies"><option value="">@currencies.code;noquote@</options></multiple>
</select>
<input type="button" onclick="get_currency();" value="#ix-currency.Ok#">

</form>

 <script type="text/javascript"
          src="https://www.google.com/jsapi?autoload={
            'modules':[{
              'name':'visualization',
              'version':'1',
              'packages':['corechart']
            }]
          }"></script>

    <script type="text/javascript">
      google.setOnLoadCallback(drawChart);

      function drawChart() {
        var data = google.visualization.arrayToDataTable([
	['Year', 'BRL','USD','EUR'],
	['Jan', 3.85, 1, 0.89],
	['Feb', 3.75, 1, 2.99],
	['Mar', 5.35, 1, 0.49],
	['Apr', 5.39, 1, 0.29],
        ]);

        var options = {
          title: 'Currencies',
          curveType: 'function',
          legend: { position: 'bottom' }
        };

        var chart = new google.visualization.LineChart(document.getElementById('curve_chart'));

        chart.draw(data, options);
      }
    </script>





<div id="curve_chart" style="width: 900px; height: 500px"></div>

