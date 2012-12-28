// Reloads page when selected retailer changes on admin
jQuery(document).ready(function(){  
  jQuery("#retailer_id").change(function(){
  	var retailer_id = jQuery("#retailer_id :selected").val();
  	
  	if (window.location.pathname.indexOf("orders") == -1) {
			window.location = window.location + '/get_retailer_data?retailer_id=' + retailer_id;
		} else {
			if (retailer_id != "") {
				if (window.location.search.length == 0) {
					window.location = window.location.pathname + '?search[retailers_id_equals]=' + retailer_id;
				} else if (window.location.search.indexOf("retailers_id_equals") == -1) {
					window.location = window.location.pathname + window.location.search + '&search[retailers_id_equals]=' + retailer_id;
				} else {
					//alert(unescape(window.location.search));
					unescape_search_string = unescape(window.location.search);
					replaced_search_string = unescape_search_string.replace(/search\[retailers_id_equals\]=\d+/,"search[retailers_id_equals]="+retailer_id)
					window.location = window.location.pathname + replaced_search_string;
				}
			} else {
				window.location = window.location.pathname + window.location.search.replace(/search\[retailers_id_equals\]=\d+/,"");
			}
		}
  });

});
