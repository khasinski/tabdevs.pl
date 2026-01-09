import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Listen for successful form submissions
    this.element.addEventListener("turbo:submit-end", this.handleSubmitEnd.bind(this))
  }

  disconnect() {
    this.element.removeEventListener("turbo:submit-end", this.handleSubmitEnd.bind(this))
  }

  toggle(event) {
    event.preventDefault()
    const form = this.element.querySelector(".comment-reply-form")
    if (form) {
      if (form.style.display === "none" || form.style.display === "") {
        form.style.display = "block"
        const textarea = form.querySelector("textarea")
        if (textarea) textarea.focus()
      } else {
        form.style.display = "none"
      }
    }
  }

  handleSubmitEnd(event) {
    if (event.detail.success) {
      const form = this.element.querySelector(".comment-reply-form")
      if (form) {
        form.style.display = "none"
        const textarea = form.querySelector("textarea")
        if (textarea) textarea.value = ""
      }
    }
  }
}
