$('.modal-assign-trigger').click(function(){
	$( "tbody.body-assign" ).html( "" );
	var package_id = $(this).attr('package-id');
	var barcode = $(this).attr('barcode');
	var reassign = $(this).attr('reassign');
	if ( reassign == 'true' )
		$('#myModalLabel-assign').html('Reassign Packge '+barcode);
	else
		$('#myModalLabel-assign').html('Assign Packge '+barcode);
	$( "#package-id" ).val( package_id );
	$('.row-for-box').removeClass('selected');
	$('#assign-button').attr('disabled', true);
	$('#box-id').val("");
	$('#box-info').val("");
	$.get( "packages/"+package_id + '/get_available_boxes.json', function( data ) {
	  if ( data.status == 'error' )
	  	return;
	  if ( data.status == 'success')
	  {
		  var html = "";
		  var res = data.result;
		  for (var i = 0; i < res.length; i++) {
		  	html += "<tr class='row-for-box' id='row-for-"+ res[i].id +"'>";
		  	html += "<td>" + res[i].name;
		  	if (res[i].backup == true )
		  		html += " (backup)";
		  	html += "</td>";
		  	html += "<td>" + res[i].locker_name + "</td>";
		  	html += "<td>" + res[i].branch_name + "</td>";
		  	html += "<td>" + res[i].print_size + "</td>";
		  	html += "<td class='cell-for-button'>";
		  	html += '<span class="btn btn-default btn-xs assign btn-success" bid="'+res[i].id+'" binfo="'+ res[i].locker_name + '-' + res[i].name 
		  			+'    Branch: '+ res[i].branch_name +'    Size: '+ res[i].print_size;
		  	if (res[i].backup == true )
		  		html += " (backup)    ";	
		  	html +=	'"';
		  	if (res[i].backup == true )
		  		html += " backup='true'";
		  	else
		  		html += " backup='false'";
		    if (reassign == 'true')
		    	html += " reassign='true'";
		  	html += '><span class="glyphicon glyphicon-ok"></span> Assign</span>';
		  	html += '<span class="btn btn-default btn-xs cancel btn-danger" bid="'+res[i].id+'"><span class="glyphicon glyphicon-remove"></span> Cancel</span>'
		  	html += "</td>";
		  	html += "</tr>";
		  }
		  $( "tbody.body-assign" ).html( html );
		  
			$('.assign').click(function(){
				$('.row-for-box').removeClass('selected');
				var bid = $(this).attr('bid');
				var binfo = $(this).attr('binfo');
				$('#row-for-'+bid).addClass('selected');
				$('#assign-button').attr('disabled', false);
				$('#box-info').val(binfo);
				$('#box-id').val(bid);
				if ($(this).attr('backup') == 'true' && $(this).attr('reassign') == 'true' )
					$('form#assign_box_form').attr('action', '/boxes/reassign_backup');
				else if ( $(this).attr('backup') == 'true' )
					$('form#assign_box_form').attr('action', '/boxes/assign_backup');
				else if ( $(this).attr('reassign') == 'true' )
					$('form#assign_box_form').attr('action', '/boxes/reassign');
				else
					$('form#assign_box_form').attr('action', '/boxes/assign');
			});
			
			$('.cancel').click(function(){
				var bid = $(this).attr('bid');
				$('#row-for-'+bid).removeClass('selected');
				$('#assign-button').attr('disabled', true);
				$('#box-info').val("");
				$('#box-id').val("");
			});

	  }
	});
});


$('.modal-package-logs-trigger').click(function(){
	var pid = $(this).attr('package-id');
	$('#log-package-id').html(pid);
	$.get( "/logs/package/" + pid + '.json', function( data ) {
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
			  	html += "<td>" + res[i].box_info + "</td>";
			  	html += "<td>" + res[i].time + "</td>";
			  	html += "<td>" + res[i].access + "</td>";
			  	html += "</tr>";
			}
			$( "tbody.logs" ).html( html );
		}
	});
});


