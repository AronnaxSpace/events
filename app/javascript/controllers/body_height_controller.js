import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    document.body.style.height = `${window.innerHeight}px`
  }

  recalculate() {
    document.body.style.height = `${window.innerHeight}px`
  }
}
