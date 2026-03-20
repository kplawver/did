import { Controller } from "@hotwired/stimulus"

const MONTH_NAMES = [
  "January", "February", "March", "April", "May", "June",
  "July", "August", "September", "October", "November", "December"
]

export default class extends Controller {
  static targets = ["form", "dateInput", "grid", "monthLabel", "trigger", "calendar"]
  static values = { dueDate: String }

  connect() {
    const d = new Date(this.dueDateValue + "T00:00:00")
    this.displayYear = d.getFullYear()
    this.displayMonth = d.getMonth()
    this.renderCalendar()
  }

  disconnect() {
    this.cancelHide()
  }

  show() {
    this.cancelHide()
    const cal = this.calendarTarget
    cal.classList.remove("hidden")

    const triggerRect = this.triggerTarget.getBoundingClientRect()
    const calW = 240
    const calH = cal.offsetHeight || 260

    // Horizontal: align right edge to trigger right, clamp to viewport
    const left = Math.min(triggerRect.right - calW, window.innerWidth - calW - 8)

    // Vertical: prefer above, fall back to below
    const spaceAbove = triggerRect.top - 8
    const spaceBelow = window.innerHeight - triggerRect.bottom - 8
    const top = spaceAbove >= calH || spaceAbove >= spaceBelow
      ? triggerRect.top - calH - 4
      : triggerRect.bottom + 4

    cal.style.left = `${Math.max(8, left)}px`
    cal.style.top = `${Math.max(8, top)}px`
  }

  scheduleHide() {
    this.hideTimeout = setTimeout(() => this.calendarTarget.classList.add("hidden"), 150)
  }

  cancelHide() {
    clearTimeout(this.hideTimeout)
  }

  prevMonth() {
    if (this.displayMonth === 0) { this.displayMonth = 11; this.displayYear-- }
    else { this.displayMonth-- }
    this.renderCalendar()
  }

  nextMonth() {
    if (this.displayMonth === 11) { this.displayMonth = 0; this.displayYear++ }
    else { this.displayMonth++ }
    this.renderCalendar()
  }

  selectDate(event) {
    this.dateInputTarget.value = event.currentTarget.dataset.date
    this.calendarTarget.classList.add("hidden")
    this.formTarget.requestSubmit()
  }

  renderCalendar() {
    const { displayYear: year, displayMonth: month } = this
    this.monthLabelTarget.textContent = `${MONTH_NAMES[month]} ${year}`

    const firstDayOfWeek = (new Date(year, month, 1).getDay() + 6) % 7 // Monday = 0
    const daysInMonth = new Date(year, month + 1, 0).getDate()
    const today = new Date()
    const selected = this.dueDateValue

    let html = ["M", "T", "W", "T", "F", "S", "S"]
      .map(d => `<div class="text-center text-xs text-base-content/40 font-medium pb-1">${d}</div>`)
      .join("")

    for (let i = 0; i < firstDayOfWeek; i++) html += `<div></div>`

    for (let day = 1; day <= daysInMonth; day++) {
      const dateStr = `${year}-${String(month + 1).padStart(2, "0")}-${String(day).padStart(2, "0")}`
      const isSelected = dateStr === selected
      const isToday = day === today.getDate() && month === today.getMonth() && year === today.getFullYear()

      let cls = "flex items-center justify-center text-xs rounded-full w-6 h-6 mx-auto cursor-pointer hover:bg-base-300 transition-colors"
      if (isSelected) cls += " !bg-primary text-primary-content"
      else if (isToday) cls += " font-bold ring-1 ring-primary ring-offset-1"

      html += `<div class="${cls}" data-date="${dateStr}" data-action="click->due-date-picker#selectDate">${day}</div>`
    }

    this.gridTarget.innerHTML = html
  }
}
