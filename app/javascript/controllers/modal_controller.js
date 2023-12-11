import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="modal"
export default class extends Controller {
  connect() {}

  open() {
    // Since we do a request to the controller to load the
    // modal into the DOM, the delay is to wait until the
    // modal is in the DOM before tring to open it.
    // This logic can go away when we refactor how we're
    // handling modals, and/or writing our own.
    const modalId = this.element.dataset.target
    setTimeout(() => {
      $(`${modalId}`).modal('show')
    }, 300)
  }

  close() {
    $('.modal').modal('hide')
    // this hack was in place before.
    // for some reason when clicking the close button,
    // the page will be frozen unless reloading
    location.reload()
  }
}
