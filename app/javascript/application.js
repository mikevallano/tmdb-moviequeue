import 'controllers'
import '@hotwired/turbo-rails'

document.addEventListener('turbo:load', () => {
  console.log('loaded turbo!')
})

document.addEventListener('DOMContentLoaded', () => {
  console.log('DOM loaded')
})

console.log('in application.js')
