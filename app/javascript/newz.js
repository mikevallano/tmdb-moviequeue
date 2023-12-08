var delayTime = 500

document.addEventListener('DOMContentLoaded', () => {
  console.log('newz loaded')
  $('.dropdown-toggle').dropdown()
})

$(document).on('turbo:load', () => {
  console.log('turbo via jquery!')
})

document.addEventListener('turbo:load', function () {
  document
    .querySelectorAll('.autocomplete-auto-submit')
    .forEach(function (form) {
      var source = form.dataset.autocompleteSource

      $(form).autocomplete({
        source: source,
        minLength: 4,
        delay: delayTime,
        select: function (event, ui) {
          form.value = ui.item.value
          form.closest('form').submit()
          $('#overlay-modal').show()
        },
      })
    })

  $('.autocomplete-search-field').autocomplete({
    minLength: 4,
    delay: delayTime,
    source: $('.autocomplete-search-field').data('autocomplete-source'),
  })

  // $('#header-movie-search, ul.ui-autocomplete').css({
  //   position: 'relative',
  //   'max-width': '455px',
  // })

  // Generic selector to trigger autocomplete on the movie show page
  $('.list-dropdown').autocomplete({
    source: $('.list-dropdown').data('autocomplete-source'),
    minLength: 0,
    select: function (event, ui) {
      handleAddToListAutocompleteSelect($('.list-dropdown'), ui)
    },
  })

  $('.ui-autocomplete-input').click(triggerClickForListAutocomplete)
})

// $(document)
//   .on('change', 'form#new_listing select, form#new_rating select', function () {
//     $(this).closest('form').submit()
//   })
//   .on('input', '#trailer-text-field', function () {
//     if ($('#trailer-text-field').val().length > 4) {
//       $('#add-trailer-btn').prop('disabled', false)
//     } else {
//       $('#add-trailer-btn').prop('disabled', true)
//     }
//   })

function handleAddToListAutocompleteSelect(element, ui) {
  // populate the form field with the id of the autocomplete-selected list
  element.parent().find('.list-id-field').val(ui.item.id)
  // submit the form
  element.parent().submit()
}

function triggerClickForListAutocomplete() {
  // hack to show all lists when initially clicking
  // in the field. this triggers a backspace keypress
  var evt = jQuery.Event('keydown')
  evt.which = 8 // backspace
  evt.keyCode = 8
  $(this).trigger(evt)
}
