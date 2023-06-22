// Path: app/javascript/controllers/loading_controller.js
import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="loading"
export default class extends Controller {
  static targets = ["linknextchapter", "loadingprompt", "loadedprompt", "loading", "createForm", "createFormShow","recentcards","loadingcards","loadedcards","link"]
  static values = {
    followup: String
  }

  connect() {
    // Console logging for testing
    // console.log("Loading controller connected");
  }

  showLoading(event) {
    // console logging for testing
    // console.log("showLoading executed");

    // Prevent reloading the page at form submit
    event.preventDefault();

    // Callback if creating story from index page (aka initial story)
    const indexFunc = (data) => {
      // Update the link to the new story after it has been created
      const link = this.linkTarget.querySelector("a");
      link.href = `/stories/${data.storyId}`;

      // Hide the loading card and show the loaded card
      this.loadingcardsTarget.classList.add("d-none");
      this.loadedcardsTarget.classList.remove("d-none");
    }

    // Callback if creating story from show page (aka follow up story)
    const showFunc = (data) => {
      // Update the link to the new story after it has been created
      const link = this.linknextchapterTarget.querySelector("a");
      link.href = `/stories/${data.storyId}`;

      // Hide the loading card and show the loaded card
      this.loadingpromptTarget.classList.add("d-none");
      this.loadedpromptTarget.classList.remove("d-none");
    }

    // Check if on index page or show page
    if (this.followupValue) {
      // Hide the form of the prompt interface
      this.createFormTarget.classList.add("d-none");
      // Show the loading animation inside prompt interface
      this.loadingpromptTarget.classList.remove("d-none");
      this.fetchStory(showFunc)
    } else {
      // Hide the default content of the #recent-cards element
      this.recentcardsTarget.classList.add("d-none");
      // Show the loading card and 2 most recently created stories
      this.loadingcardsTarget.classList.remove("d-none");
      this.fetchStory(indexFunc)
    }
  }

  // Post form data to server, then check once per second
  fetchStory(callback) {
    const form = document.getElementById("story-form");
    const formData = new FormData(form);
    fetch(form.action, {
      method: "POST",
      body: formData
    })
      .then(response => response.text())
      .then(data => {
        // Check if the new story has been created every second
        let counter = 0;
        const intervalId = setInterval(() => {
          fetch("/stories/check_story")
            .then(response => response.json())
            .then(data => {
              // If counter exceeded, force show loaded card with link to last story
              if (data.storyCreated || counter >= 35) {
                clearInterval(intervalId);
                callback(data);
              }
              counter++;
            });
        }, 1000);
      });
  }
}
