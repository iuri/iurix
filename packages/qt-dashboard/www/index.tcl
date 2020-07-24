ad_page_contract {}


ns_log Notice "Running TCL script index.tcl"


set url "https://dashboard.qonteo.com/api/totalgender"


set l_qty [list]
set body [list {"task": "yesterday"}]
set result [qt::dashboard::persons::get -body $body -url $url]

set l_data [split [string map {"[" "" "]" "" "{" "" "}" ""} [dict get $result body]] ","]
foreach {gender qty} $l_data {
    lappend l_qty [lindex [split $qty ":"] 1]   
}

array set yesterday [list female [lindex $l_qty 0] \
			 male [lindex $l_qty 1] \
			 total [expr [lindex $l_qty 0] + [lindex $l_qty 1]]]
ns_log Notice "YESTERDAY [parray yesterday]"




set l_qty [list]
set body [list {"task": "today"}]
set result [qt::dashboard::persons::get -body $body -url $url]

set l_data [split [string map {"[" "" "]" "" "{" "" "}" ""} [dict get $result body]] ","]
foreach {gender qty} $l_data {
    lappend l_qty [lindex [split $qty ":"] 1]   
}

array set today [list \
		     female [lindex $l_qty 0] \
		     female_diff [expr 100 - \
				      [expr \
					   [expr [lindex $l_qty 0] * 100] / $yesterday(female)]] \
		     male [lindex $l_qty 1] \
		     male_diff [expr 100 - \
				    [expr \
					 [expr [lindex $l_qty 1] * 100] / $yesterday(male)]]\
		     total [expr [lindex $l_qty 0] + [lindex $l_qty 1]]]
		 
ns_log Notice "TODAY [parray today]"






set l_qty [list]
set body [list {"task": "lastweek"}]
set result [qt::dashboard::persons::get -body $body -url $url]

set l_data [split [string map {"[" "" "]" "" "{" "" "}" ""} [dict get $result body]] ","]
foreach {gender qty} $l_data {
    lappend l_qty [lindex [split $qty ":"] 1]   
}

array set lastweek [list \
			female [lindex $l_qty 0] \
			male [lindex $l_qty 1] \
			total [expr [lindex $l_qty 0] + [lindex $l_qty 1]]]
ns_log Notice "LASTWEEK [parray lastweek]"









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



template::head::add_css -href "/resources/qt-dashboard/styles/dashboard.css"
# <!-- Latest compiled and minified CSS -->
template::head::add_css -href "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"

# <!-- Optional theme -->
template::head::add_css -href "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css"

# <!-- Latest compiled and minified JavaScript -->
template::head::add_javascript -src "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"
