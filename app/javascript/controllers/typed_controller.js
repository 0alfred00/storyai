import { Controller } from "@hotwired/stimulus"
import Typed from "typed.js"

// Typed.js for loading text animation

export default class extends Controller {
  static values = {
    sentences: Array,
    typeSpeed: Number,
    backSpeed: Number,
    shuffle: Boolean,
    loop: Boolean
  }

  connect() {
    // Console logging for testing
    // console.log("Typed controller connected");

    // Set the default values for the Typed.js options
    const options = {
      strings: this.sentencesValue,
      typeSpeed: this.typeSpeedValue,
      backSpeed: this.backSpeedValue,
      shuffle: this.shuffleValue,
      loop: this.loopValue
    };

    // Initialize Typed.js
    new Typed(this.element, options);
  }
}
