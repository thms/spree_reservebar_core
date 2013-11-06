var add_image_handlers = function() {
  $("#main-image").data('selectedThumb', $('#main-image img').attr('src'));
  $('ul.thumbnails li').eq(0).addClass('selected');

  $('ul.thumbnails').delegate('a', 'click', function(event) {
    $("#main-image").data('selectedThumb', $(event.currentTarget).attr('href'));
    $("#main-image").data('selectedThumbId', $(event.currentTarget).parent().attr('id'));
    $(this).mouseout(function() {
      $('ul.thumbnails li').removeClass('selected');
      $(event.currentTarget).parent('li').addClass('selected');
    });
    return false;
  });
  $('ul.thumbnails').delegate('li', 'mouseenter', function(event) {
    $('#main-image img').attr('src', $(event.currentTarget).find('a').attr('href'));
  });
  $('ul.thumbnails').delegate('li', 'mouseleave', function(event) {
    $('#main-image img').attr('src', $("#main-image").data('selectedThumb'));
  });
};

var show_variant_images = function(variant_id) {
  $('li.vtmb').hide();
  $('li.vtmb-' + variant_id).show();
  var currentThumb = $('#' + $("#main-image").data('selectedThumbId'));
  // if currently selected thumb does not belong to current variant, nor to common images,
  // hide it and select the first available thumb instead.
  if(!currentThumb.hasClass('vtmb-' + variant_id) && !currentThumb.hasClass('tmb-all')) {
    var thumb = $($('ul.thumbnails li:visible').eq(0));
    var newImg = thumb.find('a').attr('href');
    $('ul.thumbnails li').removeClass('selected');
    thumb.addClass('selected');
    $('#main-image img').attr('src', newImg);
    $("#main-image").data('selectedThumb', newImg);
    $("#main-image").data('selectedThumbId', thumb.attr('id'));
  }
}

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
