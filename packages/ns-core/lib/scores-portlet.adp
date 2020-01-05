
<script type="text/javascript">
  google.charts.load('current', {'packages':['bar']});
  google.charts.setOnLoadCallback(drawChart);
  function drawChart() {
    var data = google.visualization.arrayToDataTable([
      @data1;noquote@
      @data2;noquote@
    ]);

    var options = {
      chart: {
        title: '#ns-core.Scores_per_Lawyer#',
	subtitle: 'Score no periodo: Nov./2018-Dez./2019',
      },
      bars: 'vertical',
      vAxis: {format: 'decimal'},
      height: 400,
      colors: [@colors;noquote@]
      };

      var chart = new google.charts.Bar(document.getElementById('chart_div'));
      chart.draw(data, google.charts.Bar.convertOptions(options));

      var btns = document.getElementById('btn-group');
      btns.onclick = function (e) {
        if (e.target.tagName === 'BUTTON') {
	  options.vAxis.format = e.target.id === 'none' ? '' : e.target.id;
	  chart.draw(data, google.charts.Bar.convertOptions(options));
	}
      }
    }

</script>


<div id="chart_div"></div>


