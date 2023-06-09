import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="favorite"
export default class extends Controller {

  fire() {
    console.log("hello")
  }
}
