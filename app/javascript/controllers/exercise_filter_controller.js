import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "exercise", "section"]

  connect() {
    // Initialize with all exercises visible
    this.filter()
  }

  filter() {
    const searchTerm = this.inputTarget.value.toLowerCase()
    this.exerciseTargets.forEach(exercise => {
        const exerciseName = exercise.textContent.toLowerCase()
        const isVisible = exerciseName.includes(searchTerm)
        exercise.closest('tr').style.display = isVisible ? '' : 'none'
    })
  }
} 