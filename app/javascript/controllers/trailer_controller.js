import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="trailer"
const isValidUrl = (string) => {
  try {
    if (string.includes('youtube.com') && new URL(string)) {
      return true
    } else {
      return false
    }
  } catch (err) {
    return false
  }
}

export default class extends Controller {
  connect() {}

  validateInput(event) {
    const trailerSubmitButton = document.querySelector('#add-trailer-btn')
    trailerSubmitButton.disabled = !isValidUrl(event.target.value)
  }

  modalTester() {
    console.log('this.element.dataset:', this.element.dataset)
    const modalId = this.element.dataset.target
    console.log('modalId:', modalId)
    const modalEl = $(`${modalId}`)
    console.log('modalEl:', modalEl)
    setTimeout(() => {
      console.log('showing modal?')
      $(`${modalId}`).modal('show')
    }, 500)
    // console.log('got clicked')
    // $('#exampleModal').modal('show')
  }

  modalCloseTester() {
    $('.modal').modal('hide')
    location.reload()
  }
}
