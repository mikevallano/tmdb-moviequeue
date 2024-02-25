import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="modal"
export default class extends Controller {
  connect() {}

  open() {
    // Since we do a request to the controller to load the
    // modal into the DOM, the delay is to wait until the
    // modal is in the DOM before tring to open it.

    // In production, the response is much faster, which is
    // the purpose of the waitTime difference.

    // This logic can go away when we refactor how we're
    // handling modals, and/or writing our own.

    const waitTime =
      document.head.querySelector('meta[name=rails_env]').content ===
      'production'
        ? 400
        : 900
    const modalId = this.element.dataset.target
    setTimeout(() => {
      $(`${modalId}`).modal('show')
    }, waitTime)
  }

  close() {
    $('.modal').modal('hide')
    // this hack was in place before.
    // for some reason when clicking the close button,
    // the page will be frozen unless reloading
    location.reload()
  }

  openModal() {
    const movieModal = document.querySelector(`#modal_${this.element.id}`)
    movieModal.classList.remove('hidden')
    // todo: stop video when modal closes
    // let trailerVideo
    // const stopTrailer = (vid) => {
    //   vid.contentWindow.postMessage(
    //     '{"event":"command","func":"stopVideo","args":""}',
    //     '*'
    //   )
    // }
    // setTimeout(() => {
    //   trailerVideo = movieModal.querySelector('iframe')
    //   console.log('trailerVideo:', trailerVideo)
    // }, 1000)
    document.addEventListener('click', (event) => {
      if (event.target == movieModal) {
        movieModal.classList.add('hidden')
        // stopTrailer(trailerVideo)
      }
    })
  }

  closeModal() {
    this.element.closest('.modal').classList.add('hidden')
  }
}
