// Path: app/javascript/controllers/loading_controller.js
import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="loading"
export default class extends Controller {
  static targets = ["loading","createForm","recentcards","loadingcards","loadedcards","link"]

  connect() {
    console.log("Loading controller connected");
  }

  showLoading(event) {
    // console logging for testing
    console.log("showLoading executed");

    // Prevent reloading the page
    event.preventDefault();

    // Hide the default content of the #recent-cards element
    // $('#recent-cards').hide();
    this.recentcardsTarget.classList.add("d-none");

    // Show the loading card and 2 most recently created stories
    // $('#loading-cards').show();
    this.loadingcardsTarget.classList.remove("d-none");

    // Submit the form data using AJAX
    const form = document.getElementById("story-form");
    const formData = new FormData(form);
    fetch(form.action, {
      method: "POST",
      body: formData
    })
      .then(response => response.text())
      .then(data => {
        // Perform any additional actions after the submission is complete

        // Check if the new story has been created every second
        let counter = 0;
        const intervalId = setInterval(() => {
          fetch("/stories/check_story")
            .then(response => response.json())
            .then(data => {
              if (data.storyCreated || counter >= 45) {
                clearInterval(intervalId);
                // Perform any additional actions after the story has been created

                // update the link to the new story
                const link = this.linkTarget.querySelector("a");
                link.href = `/stories/${data.storyId}`;

                // Hide the loading card and show the loaded card
                this.loadingcardsTarget.classList.add("d-none");
                this.loadedcardsTarget.classList.remove("d-none");
              }
              counter++;
            });
        }, 1000);
      });
  }
}
