import { Controller } from '@hotwired/stimulus'

// Suggests values for a text input from a JSON endpoint that takes ?term=
// and returns an array of strings.
//
// <input data-controller="autocomplete"
//        data-autocomplete-url-value="/tmdb/movie_autocomplete"
//        data-autocomplete-submit-value="true">   <!-- optional: submit the form on pick -->
export default class extends Controller {
  static values = {
    url: String,
    submit: { type: Boolean, default: false },
    minLength: { type: Number, default: 4 },
    delay: { type: Number, default: 500 },
  }

  connect() {
    this.list = document.createElement('ul')
    this.list.className = 'autocomplete-results'
    this.list.id = `autocomplete-${Math.random().toString(36).slice(2)}`
    this.list.setAttribute('role', 'listbox')
    this.list.hidden = true
    this.list.addEventListener('mousedown', this.onListMousedown)
    document.body.appendChild(this.list)

    this.element.setAttribute('autocomplete', 'off')
    this.element.setAttribute('role', 'combobox')
    this.element.setAttribute('aria-autocomplete', 'list')
    this.element.setAttribute('aria-controls', this.list.id)
    this.element.setAttribute('aria-expanded', 'false')

    this.element.addEventListener('input', this.onInput)
    this.element.addEventListener('keydown', this.onKeydown)
    this.element.addEventListener('blur', this.close)
  }

  disconnect() {
    clearTimeout(this.timer)
    this.abortController?.abort()
    this.element.removeEventListener('input', this.onInput)
    this.element.removeEventListener('keydown', this.onKeydown)
    this.element.removeEventListener('blur', this.close)
    this.list.remove()
  }

  onInput = () => {
    clearTimeout(this.timer)
    const term = this.element.value.trim()
    if (term.length < this.minLengthValue) return this.close()

    this.timer = setTimeout(() => this.fetchResults(term), this.delayValue)
  }

  async fetchResults(term) {
    this.abortController?.abort()
    this.abortController = new AbortController()

    try {
      const url = `${this.urlValue}?term=${encodeURIComponent(term)}`
      const response = await fetch(url, {
        headers: { Accept: 'application/json' },
        signal: this.abortController.signal,
      })
      if (!response.ok) return this.close()

      this.render(await response.json())
    } catch (error) {
      if (error.name !== 'AbortError') this.close()
    }
  }

  render(results) {
    this.list.replaceChildren(
      ...results.map((text) => {
        const item = document.createElement('li')
        item.setAttribute('role', 'option')
        item.textContent = text
        return item
      })
    )
    this.activeIndex = -1
    results.length ? this.open() : this.close()
  }

  open() {
    const rect = this.element.getBoundingClientRect()
    this.list.style.top = `${rect.bottom + window.scrollY}px`
    this.list.style.left = `${rect.left + window.scrollX}px`
    this.list.style.minWidth = `${rect.width}px`
    this.list.hidden = false
    this.element.setAttribute('aria-expanded', 'true')
  }

  close = () => {
    this.list.hidden = true
    this.activeIndex = -1
    this.element.setAttribute('aria-expanded', 'false')
    this.element.removeAttribute('aria-activedescendant')
  }

  onKeydown = (event) => {
    if (this.list.hidden) return

    switch (event.key) {
      case 'ArrowDown':
        event.preventDefault()
        this.highlight(this.activeIndex + 1)
        break
      case 'ArrowUp':
        event.preventDefault()
        this.highlight(this.activeIndex - 1)
        break
      case 'Enter':
        // With nothing highlighted, let Enter submit what was typed.
        if (this.activeIndex >= 0) {
          event.preventDefault()
          this.select(this.items[this.activeIndex])
        } else {
          this.close()
        }
        break
      case 'Escape':
        this.close()
        break
    }
  }

  // mousedown (not click) so the input's blur doesn't close the list first.
  onListMousedown = (event) => {
    const item = event.target.closest('li')
    if (!item) return

    event.preventDefault()
    this.select(item)
  }

  highlight(index) {
    const items = this.items
    if (!items.length) return

    this.activeIndex = (index + items.length) % items.length
    items.forEach((item, i) => {
      const active = i === this.activeIndex
      item.classList.toggle('active', active)
      item.setAttribute('aria-selected', active)
      if (active) {
        item.id ||= `${this.list.id}-${i}`
        this.element.setAttribute('aria-activedescendant', item.id)
      }
    })
  }

  select(item) {
    this.element.value = item.textContent
    this.close()
    if (this.submitValue) this.element.form?.requestSubmit()
  }

  get items() {
    return Array.from(this.list.children)
  }
}
