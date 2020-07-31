



  <div class="row">
     <div class="col-sm-12 block_title">
     	  #qt-dashboard.Vehicles#
     </div>
  </div>

  <div class="row">
    <div class="col-sm-12 block1_green_box" style="background-image: linear-gradient(to bottom,#05c105,#2e8704); text-align: center;">
      <div class="block1_first_text" style="color: #ffffff; 
font-size: 2.8rem;
    text-transform: uppercase;
    margin-block-start: 1em;
    margin-block-end: 1em;
    margin-inline-start: 0px;
    margin-inline-end: 0px;
    font-weight: bold;
    display: block;
    margin: 1rem 0;
    line-height: 1.3;">#qt-dashboard.Today#</div>
      <div class="block1_second_text" style="color: #ffffff;
    text-transform: uppercase;
    margin: 1rem 0;
    line-height: 1.3;
    display: block;
    font-size: 6.5rem;
    font-weight: bold;
">@today.total@</div>
      <div class="block1_third_text" style="color: #00ff00; font-size: 2.5rem">@today.date@</div>
      <div class="block1_fourth_text" style="display: block;
    margin: 0;
    color: #FFFFFF !important;
    font-size: 2rem;
    text-transform: uppercase;
    font-weight: 600;">@today.diff@%</div>
    </div>
  </div>
  <br>

  <div class="row">
    <div class="col-sm-12">
      <div id="daily_chart_values" style="width: 100%; height: 300px;"></div>
    </div>
  </div>



  <div class="row block2_gray_box" style="margin-top:15%;">
    <div class="col-sm-4">
      <div class="block2_first_text">#qt-dashboard.Yesterday#</div>
      <div class="block2_second_text">@yesterday.total@</div>
    </div>
    <div class="col-sm-4" >
      <div class="block2_first_text">#qt-dashboard.This_Week#</div>
      <div class="block2_second_text">@week.total@</div>
    </div>
    <div class="col-sm-4">
      <div class="block2_first_text">#qt-dashboard.This_Month#</div>
      <div class="block2_second_text">@month.total@</div>
    </div>
  </div>

  <br>



  <div class="row"  style="margin-top:15%;">
    <div class="col-sm-12">
      <div id="weekly_chart_values" style="width: 100%; height: 300px;"></div>
    </div>
  </div>


  <div class="row" style="margin-top:15%;">
    <div class="col-sm-12">
      <div id="monthly_chart_values" style="width: 100%; height: 300px;"></div>
    </div>
  </div>





<script>
    google.charts.load('current', {'packages':['corechart']});
    google.charts.setOnLoadCallback(drawDailyChart);
    google.charts.setOnLoadCallback(drawWeeklyChart);
    google.charts.setOnLoadCallback(drawMonthlyChart);

    function drawDailyChart() {
	var data = google.visualization.arrayToDataTable([
							  ['Element', 'Density', { role: 'style' }],
							  @daily_data_html;noquote@
							  ]);

	var view = new google.visualization.DataView(data);
	view.setColumns([0, 1,
			 { calc: 'stringify',
			     sourceColumn: 1,
			     type: 'string',
			     role: 'annotation' },
			 2]);

	var options = {
	    title: 'Cantidad de vehiculos/hora',
	    width: '100%',
	    height: 400,
	    bar: {groupWidth: '95%'},
	    legend: { position: 'none' },
	};
	var chart = new google.visualization.ColumnChart(document.getElementById('daily_chart_values'));
	chart.draw(view, options);
    }

    function drawWeeklyChart() {
	var data = google.visualization.arrayToDataTable([
							  ['Element', 'Density', { role: 'style' }],
							  @weekly_data_html;noquote@
							  ]);

	var view = new google.visualization.DataView(data);
	view.setColumns([0, 1,
			 { calc: 'stringify',
			     sourceColumn: 1,
			     type: 'string',
			     role: 'annotation' },
			 2]);

	var options = {
	    title: 'Cantidad de vehiculos/semana',
	    width: '100%',
	    height: 400,
	    bar: {groupWidth: '95%'},
	    legend: { position: 'none' },
	};
	var chart = new google.visualization.ColumnChart(document.getElementById('weekly_chart_values'));
	chart.draw(view, options);
    }




    function drawMonthlyChart() {
	var data = google.visualization.arrayToDataTable([
							  ['Element', 'Density', { role: 'style' }],
							  @monthly_data_html;noquote@
							  ]);

	var view = new google.visualization.DataView(data);
	view.setColumns([0, 1,
			 { calc: 'stringify',
			     sourceColumn: 1,
			     type: 'string',
			     role: 'annotation' },
			 2]);

	var options = {
	    title: 'Cantidad de vehiculos/mes',
	    width: '100%',
	    height: 400,
	    bar: {groupWidth: '95%'},
	    legend: { position: 'none' },
	};
	var chart = new google.visualization.ColumnChart(document.getElementById('monthly_chart_values'));
	chart.draw(view, options);
    }

</script>

