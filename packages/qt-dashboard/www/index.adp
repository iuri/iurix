<master>


<div class="container" width="100%">

  <div class="row">
     <div class="col-sm-2">
     	  <img src="/resources/qt-dashboard/images/ds-logo.png" width="200px">
     </div>
     <div class="col-sm-8">
     	  <div style="font-size: 4.0rem;letter-spacing: 5.5px;color: #0B18F1;text-align: center;font-weight: 400;margin: 1rem 0;line-height: 1.3;" >
	  	       E.D.S. EL POLO<br>CO.PMXCO.BOG.AO1
          </div>

     </div>
     <div class="col-sm-2" style="float:right;">
     	  <div style="font-size: 3.0rem; text-align: left; margin-left: 5.0rem; color: #0B18F1;font-weight:800;">
	  DATA<br>
	  STREET<br>
	  PERFORMANCE<br>
	  </div>
     </div>
  </div>


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

<script>
    google.charts.load('current', {'packages':['corechart']});
    google.charts.setOnLoadCallback(drawDailyChart);

    function drawDailyChart() {
	var data = google.visualization.arrayToDataTable([
							  ['Element', 'Density', { role: 'style' }],
							  @data_html;noquote@
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
	var chart = new google.visualization.ColumnChart(document.getElementById('columnchart_values'));
	chart.draw(view, options);
    }
 
</script>

  <div class="row">
    <div class="col-sm-12">
      <div id="columnchart_values" style="width: 100%; height: 300px;"></div>
    </div>
  </div>


  <br>
  <div class="row block2_gray_box" style="margin-top:100px;">
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

