function disableSaveOnClick() {
  $('form.edit_spree_order').submit(function() {
	if ($('#checkout_form_payment').valid()) {
    	$(this).find(':submit, :image').attr('disabled', true).removeClass('primary').addClass('disabled');
	}
  });
}
