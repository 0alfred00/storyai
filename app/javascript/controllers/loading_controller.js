import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="loading"
export default class extends Controller {
  static targets = ["loading","createForm"]
  connect() {
  // const form = this.element("story-form");
  }
  showLoading() {
    this.loadingTarget.style.display = "block";
    this.createFormTarget.style.display = "none";
  }
}
