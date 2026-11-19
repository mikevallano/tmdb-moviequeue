import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="modal"
export default class extends Controller {
  connect() {}

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
