$(document).ready(function() {
	if ($.url().segment()[0] == 'products') {

		if($('#product-variants option').length > 0) {
			var params = $.url().param();
			if (params["variant_id"] != null) {
				$('#product-variants select').val(params['variant_id']).change();
				show_variant_images($('#product-variants option:selected').attr('value'));
				$("[data-variant-id=" + params['variant_id'] + "]").show();
			} else {
			    	show_variant_images($('#product-variants option').eq(0).attr('value'));
				$("#product-variants .slider-item").first().show();
			}
		  }
	
		$('#product-variants select').on('change', function (event) {
			show_variant_images(this.value);
			$("#product-variants .slider-item").hide();
			$("[data-variant-id=" + this.value + "]").show();
		});

		$('#slider-right').on('click', function (event) {
			$('#product-variants option:selected').next().attr('selected', 'selected').change();
		});
		$('#slider-left').on('click', function (event) {
			$('#product-variants option:selected').prev().attr('selected', 'selected').change();
		});
	}
		
});
