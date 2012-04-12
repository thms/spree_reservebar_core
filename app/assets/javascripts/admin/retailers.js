jQuery(document).ready(function(){  
  jQuery("#retailer_id").change(function(){
  	var retailer_id = jQuery("#retailer_id :selected").val();
  	window.location = window.location + '/get_retailer_data?retailer_id=' + $(this).val();
  });

});
