import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    document.addEventListener("turbo:before-morph-element", this._closeOnMorph)
  }

  disconnect() {
    document.removeEventListener("turbo:before-morph-element", this._closeOnMorph)
  }

  _closeOnMorph = (event) => {
    if (
      event.target === this.element &&
      this.element.open &&
      event.detail.newElement &&
      !event.detail.newElement.hasAttribute("open")
    ) {
      this.element.close()
    }
  }
}
