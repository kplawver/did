import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static targets = ["datePicker"]

  jumpToDate() {
    const date = this.datePickerTarget.value
    if (date) {
      Turbo.visit(`/journal/${date}`)
    }
  }
}
