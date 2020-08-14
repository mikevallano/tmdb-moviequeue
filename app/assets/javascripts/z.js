$(document).ready(function(){
  $(".autocomplete-auto-submit").autocomplete({
    source: $(".autocomplete-auto-submit").data("autocomplete-source"),
    minLength: 4,
    select: function(event, ui) {
      $(".autocomplete-auto-submit").val(ui.item.value);
      $(this).closest("form").submit();
      $("#overlay-modal").show(); }
    });

  $( ".autocomplete-search-field" ).autocomplete({
    minLength: 4,
    source: $(".autocomplete-search-field").data("autocomplete-source")
  });

  $('#header-movie-search, ul.ui-autocomplete').css({
    'position': 'relative',
    'max-width': '455px',
    'z-index': 1100
  });

  $('.list-dropdown').autocomplete({
    source: $('.list-dropdown').data('autocomplete-source'),
    minLength: 0,
    select: function(event, ui) {
      handleAddToListAutocompleteSelect($('.list-dropdown'), ui)
    }
  })

  $('.ui-autocomplete-input').click(triggerClickForListAutocomplete)
});

$(document)
  .on('change', 'form#new_listing select, form#new_rating select', function() {
    $(this).closest("form").submit();
  })
  .on('input', '#trailer-text-field', function() {
    if ($("#trailer-text-field").val().length > 4 ) {
      $('#add-trailer-btn').prop("disabled", false);
    } else {
      $('#add-trailer-btn').prop("disabled", true);
    }
  });

function handleAddToListAutocompleteSelect(element, ui) {
  // populate the form field with the id of the autocomplete-selected list
  element.parent().find('.list-id-field').val(ui.item.id)
  // submit the form
  element.parent().submit()
}

function triggerClickForListAutocomplete() {
  // hack to show all lists when initially clicking
  // in the field. this triggers a backspace keypress
  var evt = jQuery.Event('keydown');
  evt.which = 8; // backspace
  evt.keyCode = 8
  $(this).trigger(evt)
}
