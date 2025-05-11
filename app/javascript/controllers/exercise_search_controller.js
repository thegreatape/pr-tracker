import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["query", "results"]

  connect() {
    // Clear any existing results when the controller connects
    this.resultsTarget.innerHTML = ""
  }

  search(event) {
    event.preventDefault()
    const query = this.queryTarget.value
    const exerciseId = this.element.querySelector("[name='exercise_id']").value
    
    // Clear existing results before fetching new ones
    this.resultsTarget.innerHTML = ""
    
    if (query.trim() === "") return

    fetch(`/exercises/search?query=${encodeURIComponent(query)}&exercise_id=${exerciseId}`, {
      headers: {
        "Accept": "text/html"
      }
    })
    .then(response => response.text())
    .then(html => {
      this.resultsTarget.innerHTML = html
    })
  }
} 