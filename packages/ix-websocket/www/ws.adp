<!-- https://wiki.tcl-lang.org/page/WebSocket
https://core.tcl-lang.org/tcllib/doc/tcllib-1-17/embedded/www/tcllib/files/modules/websocket/websocket.html#2
-->
<!DOCTYPE html>
<html>
  <head>
    <title>ws log</title>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap.min.css">
    <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap-theme.min.css">
    <script src="//ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"></script>
    <script language="javascript" type="text/javascript">  
      //let socket = new WebSocket("wss://javascript.info/article/websocket/demo/hello");
      let socket =   new WebSocket("ws://192.199.241.130:5008/api/subscribe?auth_token=9fb6e731-b342-4952-b0c1-aa1d0b52757b&event_type=extract");

      
      
      socket.onopen = function(e) {
      alert("[open] Connection established");
      alert("Sending to server");
      socket.send("My name is John");
      };
      
      socket.onmessage = function(event) {
      var jsonstring = JSON.parse(event.data);
      console.log(jsonstring);
      
      alert(`[message] Data received from server: ${event.data}`);
      
      if(jsonstring.result.faces[0].attributes.hasOwnProperty('emotions')){
        alert("IT Works");
      }
      
      
      };
      
      socket.onclose = function(event) {
      if (event.wasClean) {
      alert(`[close] Connection closed cleanly, code=${event.code} reason=${event.reason}`);
      } else {
      // e.g. server process killed or network down
      // event.code is usually 1006 in this case
      alert('[close] Connection died');
      }
      };
      
      socket.onerror = function(error) {
      alert(`[error] ${error.message}`);
      };



      


      
      var wsUri = "ws://192.199.241.130:5008/api/subscribe?auth_token=9fb6e731-b342-4952-b0c1-aa1d0b52757b&event_type=extract";
      var output;
      var state;
      var websocket = 0;
      var interval;

      function init() {
        output = document.getElementById('output');
        state = document.getElementById('state');
        startAutoScroll();
      }

      function testWebSocket() { 
        if ("WebSocket" in window) {
          websocket = new WebSocket(wsUri);
        } else {
          websocket = new MozWebSocket(wsUri);
        }
        websocket.onopen = function(evt) { onOpen(evt) }; 
        websocket.onclose = function(evt) { onClose(evt) }; 
        websocket.onmessage = function(evt) { onMessage(evt) }; 
        websocket.onerror = function(evt) { onError(evt) }; 
      }

			function onOpen(evt) 		{ state.innerHTML = '<span style="color:green;">CONNECTED</span>';  }
			function onClose(evt) 		{ state.innerHTML = '<span style="color:red;">DISCONNECTED</span>'; testWebSocket(); }  
			function onMessage(evt) 	{ writeToScreen("RESPONSE:", "blue", evt.data); /*websocket.close();*/ }  
			function onError(evt) 		{ console.log(evt); writeToScreen("ERROR:", "red", evt.data); }  
			function doSend(message) 	{ websocket.send(message); writeToScreen("SENT: ", "green",  message);}
			
			function writeToScreen(tag, color, message) {  if (interval != "") {$( '#output').append(message);} }
			function clearOutput() { output.innerHTML = ''; }
			function startAutoScroll() {
			   interval = window.setInterval(function() {
			      var elem = document.getElementById('logwindow');
			      elem.scrollTop = elem.scrollHeight;
			    }, 1000);
			    $( '#logging').html('Stop logging');
			}
			function stopAutoScroll() { clearInterval(interval); $( '#logging').html('Start logging'); interval = "";}
			function toggleLogging() { if (interval == "") {startAutoScroll();} else {stopAutoScroll()};}


      

      $( document ).ready(function() { init()});

    </script>
    <style>
      .wrapper {
      background-color: #fec;
      margin: auto;
      position: relative;
      }
      .header {
      height: 40px;
      background-color: green;
      color: #fff;
      }
      .content {
      position:absolute;
      bottom:0px;
      top: 40px;
      width:100%;
      overflow: auto;
      background-color: #333;
      color: #666;
      }
      .button {
      appearance: button;
      -moz-appearance: button;
      -webkit-appearance: button;
      text-decoration: none; font: menu; color: ButtonText;
      display: inline-block; padding: 2px 8px;
      }
      pre {
      font-size: x-small;
      }
    </style>
  </head>
  
  <body role="document">
    
    <div class="container-fluid theme-showcase" role="main">
      <div class="page-header">
	<h1>Websocket LogViewer</h1>
      	<p class="lead">running at  </p>
      </div>
      
      <div style="margin: 5px 0px;">
	Status: <span id="state">Uninitialized</span>
      </div>
      <p>
	<button type="button" class="btn btn-default" onclick="clearOutput();">Clear Output</button>
	<button type="button" class="btn btn-default" onclick="toggleLogging();" id="logging">Toggle logging on</button>
      </p>
      <div class="wrapper">
	<div class="header">
	</div>
	<div id="logwindow" style="overflow-y: scroll; height:600px;">
	  <pre id="output"></pre>
	</div> 
      </div>
      
  </body>
</html>
