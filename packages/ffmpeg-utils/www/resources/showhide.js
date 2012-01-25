$(document).ready(function() {
// Hides the block1
    $('#block1-show').click(function() {
        $('#block1').show('slow');
	$('#block1').hide();
        $('#block2').hide('fast');
        $('#block3').hide('fast');
	return false;
    });
    
    $('#block2-show').click(function() {
        $('#block2').show('slow');
        $('#block2').hide();
	$('#block1').hide('fast');
        $('#block3').hide('fast');
	return false;
    });

    $('#block3-show').click(function() {
        $('#block3').show('slow');
        $('#block3').hide();
        $("#block3").toggle();
        $('#block2').hide('fast');
	$('#block1').hide('fast');
	return false;
    });
});