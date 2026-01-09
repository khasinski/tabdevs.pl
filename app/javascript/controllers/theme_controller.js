import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["icon"]

  connect() {
    this.applyTheme()
  }

  toggle() {
    const currentTheme = document.documentElement.getAttribute("data-theme")
    const newTheme = currentTheme === "dark" ? "light" : "dark"

    document.documentElement.setAttribute("data-theme", newTheme)
    localStorage.setItem("theme", newTheme)
    this.updateIcon(newTheme)
  }

  applyTheme() {
    const savedTheme = localStorage.getItem("theme")
    const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches
    const theme = savedTheme || (prefersDark ? "dark" : "light")

    document.documentElement.setAttribute("data-theme", theme)
    this.updateIcon(theme)
  }

  updateIcon(theme) {
    if (this.hasIconTarget) {
      this.iconTarget.textContent = theme === "dark" ? "\u2600" : "\u263E"
    }
  }
}
