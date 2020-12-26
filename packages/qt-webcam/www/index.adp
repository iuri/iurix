<!doctype html>
<html lang=”en”>
<head>
<meta charset="utf-8">
<meta http-equiv="x-ua-compatible" content="ie=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<!-- Name of your awesome camera app -->
<title>Camera App</title>
<!-- Link to your main style sheet-->
<link rel="stylesheet" href="./css/style.css">
</head>
<body>
<!-- Camera -->
<main id="camera">

  <!-- Camera sensor -->
  <canvas id="camera--sensor"></canvas>

  <!-- Camera view -->
  <video id="camera--view" autoplay playsinline></video>


  <!-- Camera output -->
  <img src="//:0" alt="" id="camera--output">



   <!-- Camera trigger -->
  <button id="camera--trigger">Take a picture</button>

</main>
<!-- Reference to your JavaScript file -->
<script src="./js/jquery-3.5.1.js" type="text/javascript"></script>

<script src="./js/app.js"></script>
</body>
</html>