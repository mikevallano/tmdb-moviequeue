import { Controller } from '@hotwired/stimulus'

const MAX_QUERY_PREVIEW_LENGTH = 80

// Connects to data-controller="suggestions"
// Getting suggestions takes a while, so swap the form and any previous
// results for a loading message describing what was asked for.
export default class extends Controller {
  static targets = ['list', 'query', 'message']

  connect() {
    // Turbo's cached snapshot (e.g. after hitting Back) may have been taken mid-load
    this.element.classList.remove('is-loading')
  }

  submit() {
    const message = this.loadingMessage()
    if (!message) return // nothing was asked for, so the page just reloads the form

    this.messageTarget.textContent = message
    this.element.classList.add('is-loading')
  }

  loadingMessage() {
    const list = this.listTarget.selectedIndex > 0 ? this.listTarget.selectedOptions[0].text : null
    let query = this.queryTarget.value.trim()
    if (query.length > MAX_QUERY_PREVIEW_LENGTH) query = `${query.slice(0, MAX_QUERY_PREVIEW_LENGTH)}…`

    if (list && query) return `Finding movies like ${list}: "${query}"`
    if (list) return `Finding movies like ${list}`
    if (query) return `Finding movies for "${query}"`
    return null
  }
}
