// Set constraints for the video stream
var constraints = { video: { facingMode: "user" }, audio: false };
// Define constants
const cameraView = document.querySelector("#camera--view"),
      cameraOutput = document.querySelector("#camera--output"),
      cameraSensor = document.querySelector("#camera--sensor"),
      cameraTrigger = document.querySelector("#camera--trigger")
// Access the device camera and stream to cameraView
function cameraStart() {
    navigator.mediaDevices
        .getUserMedia(constraints)
        .then(function(stream) {
	    track = stream.getTracks()[0];
	    cameraView.srcObject = stream;
	})
        .catch(function(error) {
	    console.error("Oops. Something is broken.", error);
	});
}
// Take a picture when cameraTrigger is tapped
cameraTrigger.onclick = function() {
    cameraSensor.width = cameraView.videoWidth;
    cameraSensor.height = cameraView.videoHeight;
    cameraSensor.getContext("2d").drawImage(cameraView, 0, 0);
    cameraOutput.src = cameraSensor.toDataURL("image/webp");
    cameraOutput.classList.add("taken");


    uploadImage(cameraOutput.src);
    
};



function uploadImage(src) {
    alert("UploadFile " + src);
    var fd = new FormData();
    var files = src;

    alert("AFTER");
    // Check file selected or not 
    if(files.length > 0 ){
	fd.append('file',src);

	$.ajax({
	    url: 'upload-image',
	    type: 'post',
	    data: fd,
	    contentType: false,
	    processData: false,
	    success: function(response){
		if(response != 0){
		    alert("SUCCESS");
		    $("#img").attr("src",response);
		    $(".preview img").show(); // Display image element
		}else{
		    alert('file not uploaded');
		}
	    },
	});
    }
}


// Start the video stream when the window loads
window.addEventListener("load", cameraStart, false);
