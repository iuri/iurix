<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html;charset=ISO-8859-1" />
<meta http-equiv="Author" content="MediaEvent Services GmbH & Co. KG, http://mediaeventservices.com" />
<meta http-equiv="Copyright" content="&copy;&nbsp;2007 MediaEvent Services" />
<title>Slideflow demo</title>
<link href="css/reset.css" media="all" rel="Stylesheet" type="text/css" />
<link href="css/gallery.css" media="all" rel="Stylesheet" type="text/css" />
<link href="css/slideflow.css" media="all" rel="Stylesheet" type="text/css" />
<script type="text/javascript" src="js/scriptaculous/lib/prototype.js"></script>
<script type="text/javascript" src="js/scriptaculous/src/scriptaculous.js?load=effects"></script>
<script type="text/javascript" src="js/slideflow/slideflow.js"></script>
<script type="text/javascript" src="js/slideflow/slider.js"></script>
<script type="text/javascript" src="js/slideflow/scrolling.js"></script>
<script type="text/javascript" src="js/xmlparser/xmlparser.js"></script>
<!--[if lte IE 6]>
	<script type="text/javascript" src="js/ie6fix/ie6fix.js"></script>
<![endif]-->
<script type="text/javascript">
<!--
var numPhotos;
var slideFlowSlider;
var slideFlow;
var currentImg;
var preloader;
var fadeInTimeout;
var scrollHandler;
var photos;
var currentEffect;
var slHover;

var SLIDE_TPL = {
	'b_vertical' : false, 'b_watch': true	/* update while dragging */, 'n_controlWidth': 300, 'n_controlHeight': 7,
	'n_sliderWidth': 14, 'n_sliderHeight': 7, 'n_pathLeft' : 0, 'n_pathTop' : 0, 'n_pathLength' : 300-14, 'n_zIndex': 1
}

var SLIDE_INIT = {
	'n_minValue' : 0, 'n_maxValue' : 100, 'n_value' : 0, 'n_step' : 1
}

var SLIDEFLOW_DATA = {
	'imgWidthNormal': 100, 'imgWidthTilted': 50, 'imgHeight': 90, 'slideDistance': 10,
	'onCenterClick': handleSlideClick, 'handleSlideMove': handleSlideMove, 'containerElement': null,
	'pathLeft': '/content-repository-content-files', 'pathCenter': '/content-repository-content-files', 
	'pathRight': '/content-repository-content-files','transparentImg': 'images/transparent.gif', 'cursorOpenHand': 'images/openhand.cur', 
	'cursorClosedHand': 'images/closedhand.cur', 'images_left':null, 'images_center':null, 'images_right':null
}

function handleSlideMove(pos) {
	if (slideFlowSlider)
		slideFlowSlider.f_setValue(pos, false, true /* kein update */);
}

function handleSlideClick(imgNumber) {
	swapPhoto(imgNumber);
}

function handleSlideSeek(pos) {
	slideFlow.disableMoveUpdate();
	slideFlow.glideToPerc(pos);
}

function swapPhoto(photoNumber) {
    /* Preload */
    var imgSrc = '/content-repository-content-files' + photos.item(photoNumber - 1).getElementsByTagName("src_large")[0].childNodes[0].nodeValue;
    var wasPreloading = (preloader != undefined);
    preloader = new Image;
    preloader.src = imgSrc;
    currentImg = photoNumber;

    /* Fade out and show new photo */
    if (!wasPreloading) {
		if (currentEffect && currentEffect.state != 'finished')
			currentEffect.cancel();

    	currentEffect = new Effect.Fade($('fadeArea'), { duration:0.4, to: 0.001, afterFinish: fadeIn });
    }
}

function skipPhoto(offset) {
	photoNumber = currentImg + offset;
	if (photoNumber < 1 || photoNumber > numPhotos)
		return;

	swapPhoto(photoNumber);
	slideFlow.glideToSlide(photoNumber);
}

function fadeIn() {
	fadeInTimeout = null;

	if (!preloader)
		return;
	else if (preloader.complete) {
		if (currentEffect && currentEffect.state != 'finished')
			currentEffect.cancel();
	    currentEffect = new Effect.Appear($('fadeArea'), {duration: 0.8, beforeSetup: function(effect) {
		$('photo').src = preloader.src;
		$('title').innerHTML = photos.item(currentImg - 1).getElementsByTagName("title")[0].childNodes[0].nodeValue;
		$('subtitle').innerHTML = photos.item(currentImg - 1).getElementsByTagName("subtitle")[0].childNodes[0].nodeValue;
		preloader = undefined;
	      }});
	} else if (!fadeInTimeout) {
		fadeInTimeout = window.setTimeout("fadeIn()", 100);
	}
}

function handleWheel(delta) {
	if (slideFlow)
		slideFlow.scroll(delta);
}

function handleKeys(evt) {
    evt = (evt) ? evt : ((window.event) ? event : null);
    if (evt) {
    	//debugLog("key " + evt.keyCode);
		switch (evt.keyCode) {
			case 40: /* down */
			case 39: /* right */
				skipPhoto(1);
				return false;
				break;
			case 38: /* up */
			case 37: /* left */
				skipPhoto(-1);
				return false;
				break;
		 }
    }
}

function init() {
	swapPhoto(1);
	slideFlowSlider.f_show();
	document.onkeydown = handleKeys;
	scrollHandler = new ScrollHandler(handleWheel);
	
	/* Preload slider hover */
	slHover = new Image;
	slHover.src = "images/seekslider-hover.gif";	

	/* IE6 hover fix */
	if (window.ieFixHover) {
		 $$('.sliderbutton').each(ieFixHover);
	}
}

// -->
</script>
</head>
<body onload="init();">

<multiple name="show_opts">
   <if @show_opts.rownum@ gt 1> | </if>
    <if @show_opts.selected_p@><b>@show_opts.label@ (@show_opts.count@)</b> </if>
    <else><a href="@show_opts.url@">@show_opts.label@ (@show_opts.count@)</a> </else>
</multiple>

<multiple name="photos">
  @photos.left_url@
  @photos.right_url@
</multiple>

<div id="frame">
  <div id="fadeArea">
    <div id="wrapper"><img id="photo" src="images/transparent.gif"/></div>
    <h1 id="title">&nbsp;</h1>
    <h2 id="subtitle">&nbsp;</h2>
  </div>
  <div id="navigation" ondragstart="return false" onselectstart="return false">
    <div id="slideflow">
      <script type="text/javascript">
	<!--
		httpReq = getHttpReq();

		if (httpReq) {
			xmlDoc = getXmlDoc(httpReq, "/photo-album/resources/xml/photos-temp.xml");
			if (xmlDoc) {
				photos = xmlDoc.getElementsByTagName("photo");

				SLIDEFLOW_DATA['containerElement'] = $('slideflow');
				
				SLIDEFLOW_DATA['images'] = new Array();
				SLIDEFLOW_DATA['images_left'] = new Array();
				SLIDEFLOW_DATA['images_center'] = new Array();
				SLIDEFLOW_DATA['images_right'] = new Array();
										
				for (var i=0; i < photos.length; i++) {
					SLIDEFLOW_DATA['images'][i] = photos.item(i).getElementsByTagName("src")[0].childNodes[0].nodeValue;
					SLIDEFLOW_DATA['images_left'][i] = photos.item(i).getElementsByTagName("src_left")[0].childNodes[0].nodeValue;
					SLIDEFLOW_DATA['images_center'][i] = photos.item(i).getElementsByTagName("src_center")[0].childNodes[0].nodeValue;
					SLIDEFLOW_DATA['images_right'][i] = photos.item(i).getElementsByTagName("src_right")[0].childNodes[0].nodeValue;
				}

				slideFlow = new Slideflow(SLIDEFLOW_DATA);
				numPhotos = photos.length;
			}
		}
	//-->
	</script>
    </div>
    <div id="sliderparent">
      <script type="text/javascript">
			<!--
				slideFlowSlider = new slider(SLIDE_INIT, SLIDE_TPL);
				slideFlowSlider.onSetValue = handleSlideSeek;
			// -->
	</script>
    </div>
  </div>
 </div>
 <div id="footer"><a href="http://mediaeventservices.com">MediaEvent Services</a></div>
</body>
</html>
