import { Controller } from "@hotwired/stimulus"

const COLOR_MAP = {
  did: "input-success",
  thought: "input-info",
  idea: "input-warning",
  win: "input-accent",
  emotion: "input-error"
}

export default class extends Controller {
  static targets = ["select", "input"]

  updateColor() {
    const tag = this.selectTarget.value
    const input = this.inputTarget

    // Remove all color classes
    Object.values(COLOR_MAP).forEach(cls => input.classList.remove(cls))

    // Add new color class
    if (COLOR_MAP[tag]) {
      input.classList.add(COLOR_MAP[tag])
    }

    input.focus()
  }

  reset() {
    this.inputTarget.value = ""
    this.inputTarget.focus()
  }
}
