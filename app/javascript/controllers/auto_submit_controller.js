import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="auto-submit"
export default class extends Controller {
  connect() {
    this.isSubmitting = false
  }

  submit(event) {
    // Prevent duplicate submissions - check and set flag synchronously
    if (this.isSubmitting) {
      event.preventDefault()
      event.stopImmediatePropagation()
      return
    }

    // Set flag immediately before any async operations
    this.isSubmitting = true

    // Prevent the event from bubbling to avoid double triggers
    event.preventDefault()
    event.stopImmediatePropagation()

    // Submit the form
    this.element.requestSubmit()

    // Reset after submission completes
    setTimeout(() => {
      this.isSubmitting = false
    }, 1000)
  }
}
