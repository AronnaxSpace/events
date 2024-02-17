import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "checkbox", "drawer" ]

  connect() {
    this.loadingContent = this.drawerTarget.innerHTML
    this.sizes = {
      "xs": ["w-full", "sm:w-1/2", "lg:w-1/3", "xl:w-1/4"],
      "sm": ["w-full", "sm:w-11/12", "md:w-8/12", "lg:w-1/2", "xl:w-1/3"],
      "md": ["w-full", "lg:w-2/3", "xl:w-1/2"],
      "lg": ["w-full", "xl:w-2/3"]
    }
  }

  open(event) {
    console.log(event.params.size)
    const size = event.params.size ?? "sm"
    this.drawerTarget.classList.add(...this.sizes[size])
    this.drawerTarget.innerHTML = this.loadingContent
    this.checkboxTarget.checked = true
  }

  close(event) {
    this.checkboxTarget.checked = false
  }
}
