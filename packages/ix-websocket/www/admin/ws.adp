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
			console.log(jsontring);
			
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
