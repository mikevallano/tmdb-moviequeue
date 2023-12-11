import 'controllers'
import '@hotwired/turbo-rails'
import 'jquery'
import 'jquery-ui'
import 'bootstrap'
import './autocomplete.js'

document.addEventListener('turbo:load', () => {
  console.log('loaded turbo!')
})

document.addEventListener('DOMContentLoaded', () => {
  console.log('DOM loaded')
  $('.dropdown-toggle').dropdown()
})

$(document).on('turbo:load', () => {
  console.log('turbo via jquery!')
})
