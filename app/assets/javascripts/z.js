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


    // This hides the 'year select' field until a year is selected
    // $(function() {
    //   $("#year_select_discover_search").hide();
    //   $("#year_field_discover_search").on("change",function() {
    //     var year = this.value;
    //     if (year == "") return; // please select - possibly you want something else here

    //     $("#year_select_discover_search").show();
    //   });
    // });


// autocomplete

// the final closer
