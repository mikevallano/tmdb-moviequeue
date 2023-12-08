import 'controllers'
import '@hotwired/turbo-rails'
import 'jquery'
import 'jquery-ui'
import 'bootstrap'
import './newz.js'

document.addEventListener('turbo:load', () => {
  console.log('loaded turbo!')
})

document.addEventListener('DOMContentLoaded', () => {
  console.log('DOM loaded')
})

console.log('in application.js')
