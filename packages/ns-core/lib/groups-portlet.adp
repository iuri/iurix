<script type="text/javascript">

google.charts.load("current", {packages:["corechart"]});

google.charts.setOnLoadCallback(drawChart);

function drawChart() {
  var data = google.visualization.arrayToDataTable([
    ['Grupos', 'Usuarios por Grupo'],
    @groups_html;noquote@
  ]);
  
  var options = {
    title: 'Usuarios: ' + @reg_users_total;noquote@,
    pieHole: 0.1,
  };

  var chart = new google.visualization.PieChart(document.getElementById('donutchart'));
  chart.draw(data, options);
}
</script>



<div id="donutchart" style="height: 500px;"></div>


<if @admin_p@>
  <a href="admin/">Admin</a>
  <a href="/admin/groups/">Novo Grupo</a>
  <a href="/acs-admin/users/user-add">Novo Usuario</a>
  

</if>
