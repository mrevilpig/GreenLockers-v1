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

$('.modal-box-logs-trigger').click(function(){
	var bid = $(this).attr('box-id');
	$('#log-box-id').html(bid);
	$.get( "/logs/box/" + bid + '.json', function( data ) {
		if (data.status == 'error')
			return;
		if (data.status == 'success')
		{
			var html = '';
			var res = data.result;
			if (res.length == 0)
			{
				html += "<tr><td colspan='4' style='text-align:center; font-size:23px; color:#999'>No Logs Found.</th></tr>";
			}
		  	for (var i = 0; i < res.length; i++) 
		  	{
			  	html += "<tr ";
			  	if (res[i].action_type == 'Normal' || res[i].action_type == 'Fix')
			  		html += "class='green'";
			  	else if (res[i].action_type == 'Abnormal')
			  		html += "class='yellow'";
			  	else if (res[i].action_type == 'Error')
			  		html += "class='red'";
			  	else if (res[i].action_type == 'Manual')
			  		html += "class='blue'";
			  	html += ">";
			  	html += "<td>" + res[i].sentence + "</td>";
			  	html += "<td>" + res[i].package_info + "</td>";
			  	html += "<td>" + res[i].time + "</td>";
			  	html += "<td>" + res[i].access + "</td>";
			  	html += "</tr>";
			}
			$( "tbody.logs" ).html( html );
		}
	});
});
