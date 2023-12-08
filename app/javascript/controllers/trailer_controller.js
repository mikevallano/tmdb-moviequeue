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
}
