ad_page_contract {}


ns_log Notice "Running TCL script index.tcl"


set url "https://dashboard.qonteo.com/api/totalgender"


set body [list {"task": "today"}]


ns_log Notice "BODY $body"

#######################
# submit POST request
#######################
set requestHeaders [ns_set create]
set replyHeaders [ns_set create]
ns_set update $requestHeaders "Content-type" "application/json"

set h [ns_http queue -method POST \
	   -headers $requestHeaders \
	   -timeout 60.0 \
	   -body [list {"task": "today"}] \
	   $url]
set result [ns_http wait $h]

#######################
# output results
#######################
# ns_log notice "status [dict get $result status]"

ns_log Notice "RESLUT $result"


template::head::add_javascript -src "https://www.gstatic.com/charts/loader.js" -order 1
template::head::add_javascript -script {
    google.charts.load('current', {'packages':['corechart']});
    google.charts.setOnLoadCallback(drawDailyChart);
    google.charts.setOnLoadCallback(drawWeeklyChart);
    
    function drawDailyChart() {
	var data = google.visualization.arrayToDataTable([
							  ['Hours', 'Hombres', 'Mujeres', 'Peronas'],
							  ['6AM',  1000,      400, 1400],
							  ['7AM',  1170,      460, 1630],
							  ['8AM',  660,       1120, 1780],
							  ['9AM',  1030,      540, 1570]
							 ]);
	
	var options = {
	    title: 'Personas',
	    hAxis: {title: 'Tiempo (Horas)',  titleTextStyle: {color: '#333'}},
	    vAxis: {minValue: 0}
	};
	
	var chart = new google.visualization.AreaChart(document.getElementById('daily_chart_div'));
	chart.draw(data, options);
    }





    function drawWeeklyChart() {
	var data = google.visualization.arrayToDataTable([
							  ['Days', 'Hombres', 'Mujeres', 'Peronas'],
							  ['Lunes',  1000,      400, 1400],
							  ['7AM',  1170,      460, 1630],
							  ['8AM',  660,       1120, 1780],
							  ['9AM',  1030,      540, 1570]
							 ]);
	
	var options = {
	    title: 'Personas',
	    hAxis: {title: 'Tiempo (Horas)',  titleTextStyle: {color: '#333'}},
	    vAxis: {minValue: 0}
	};
	
	var chart = new google.visualization.AreaChart(document.getElementById('weekly_chart_div'));
	chart.draw(data, options);
    }


    
} -order 2



# <!-- Latest compiled and minified CSS -->
template::head::add_css -href "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"

# <!-- Optional theme -->
template::head::add_css -href "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css"

# <!-- Latest compiled and minified JavaScript -->
template::head::add_javascript -src "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"
