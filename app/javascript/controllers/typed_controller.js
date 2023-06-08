import { Controller } from "@hotwired/stimulus"
import Typed from "typed.js"

// Connects to data-controller="typed"
// export default class extends Controller {
//   connect() {
//   }
// }

export default class extends Controller {
  static values = {
    sentences: Array
  }

  connect() {
    const options = {strings: this.sentencesValue, typeSpeed: 0};
    new Typed(this.element, options)
  }
}
