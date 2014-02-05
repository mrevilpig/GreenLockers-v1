$('.modal-trigger').click(function(){
	$('#box-id').val($(this).attr('box-id'));
	$('.row-for-package').removeClass('selected');
	$('#assign-button').attr('disabled', true);
	$('#package-id').val("");
	$('#package-info').val("");
});
$('.modal-backup-trigger').click(function(){
	$('#backup-box-id').val($(this).attr('box-id'));
	$('.row-for-backup-package').removeClass('selected');
	$('#backup-assign-button').attr('disabled', true);
	$('#backup-package-id').val("");
	$('#backup-package-info').val("");
});
$('.assign').click(function(){
	$('.row-for-package').removeClass('selected');
	var pid = $(this).attr('pid');
	var pinfo = $(this).attr('pinfo');
	$('#row-for-'+pid).addClass('selected');
	$('#assign-button').attr('disabled', false);
	$('#package-info').val(pinfo);
	$('#package-id').val(pid);
});
$('.backup-assign').click(function(){
	$('.row-for-backup-package').removeClass('selected');
	var pid = $(this).attr('pid');
	var pinfo = $(this).attr('pinfo');
	$('#row-for-backup-'+pid).addClass('selected');
	$('#backup-assign-button').attr('disabled', false);
	$('#backup-package-info').val(pinfo);
	$('#backup-package-id').val(pid);
});

$('.cancel').click(function(){
	var pid = $(this).attr('pid');
	$('#row-for-'+pid).removeClass('selected');
	$('#assign-button').attr('disabled', true);
	$('#package-info').val("");
	$('#package-id').val("");
});

$('.backup-cancel').click(function(){
	var pid = $(this).attr('pid');
	$('#row-for-backup-'+pid).removeClass('selected');
	$('#backup-assign-button').attr('disabled', true);
	$('#backup-package-id').val("");
	$('#backup-package-info').val("");
});
