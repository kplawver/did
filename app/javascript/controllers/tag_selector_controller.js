import { Controller } from "@hotwired/stimulus"

const INPUT_COLOR_MAP = {
  did: "input-success",
  thought: "input-info",
  idea: "input-warning",
  win: "input-accent",
  emotion: "input-error"
}

const SELECT_COLOR_MAP = {
  did: "select-success",
  thought: "select-info",
  idea: "select-warning",
  win: "select-accent",
  emotion: "select-error"
}

export default class extends Controller {
  static targets = ["select", "input"]

  connect() {
    this.applyColors()
  }

  updateColor() {
    this.applyColors()
    this.inputTarget.focus()
  }

  applyColors() {
    const tag = this.selectTarget.value
    const input = this.inputTarget
    const select = this.selectTarget

    Object.values(INPUT_COLOR_MAP).forEach(cls => input.classList.remove(cls))
    Object.values(SELECT_COLOR_MAP).forEach(cls => select.classList.remove(cls))

    if (INPUT_COLOR_MAP[tag]) input.classList.add(INPUT_COLOR_MAP[tag])
    if (SELECT_COLOR_MAP[tag]) select.classList.add(SELECT_COLOR_MAP[tag])
  }

  reset() {
    this.inputTarget.value = ""
    this.inputTarget.focus()
  }
}
