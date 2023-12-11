document.addEventListener('turbo:load', function () {
  document
    .querySelectorAll('.autocomplete-auto-submit')
    .forEach(function (form) {
      var source = form.dataset.autocompleteSource

      $(form).autocomplete({
        source: source,
        minLength: 4,
        delay: 500,
        select: function (event, ui) {
          form.value = ui.item.value
          form.closest('form').submit()
          $('#overlay-modal').show()
        },
      })
    })

  $('.autocomplete-search-field').autocomplete({
    minLength: 4,
    delay: 500,
    source: $('.autocomplete-search-field').data('autocomplete-source'),
  })
})
