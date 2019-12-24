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

  $('#add-to-list-dropdown').autocomplete({
    source: $("#add-to-list-dropdown").data("autocomplete-source"),
    minLength: 0,
    select: function(event, ui) {
      handleAddToListAutocompleteSelect(event, ui)
    }
  })

  $('#add-to-list-dropdown').click(showAllListsForAutocomplete)
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

function handleAddToListAutocompleteSelect(event, ui) {
  $("#list_autocomplete_val").val(ui.item.id);
  $('form#new_listing').submit();
}

$(document).on('shown.bs.modal', function(){
  $('form#new_listing').click(showAllListsForAutocomplete)
  $('#add-to-list-dropdown').autocomplete({
    source: $("#add-to-list-dropdown").data("autocomplete-source"),
    minLength: 0,
    select: function(event, ui) {
      handleAddToListAutocompleteSelect(event, ui)
    }
  })
});

function showAllListsForAutocomplete() {
  // hack to show all lists when initially clicking
  // in the field. this triggers a backspace keypress
  let evt = jQuery.Event('keydown');
  evt.which = 8; // backspace
  evt.keyCode = 8
  $('#add-to-list-dropdown').trigger(evt)
}
