import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["publicToggle", "favoriteToggle", "favoriteCount"]

  connect() {
    // Console logging for testing
    console.log("Toggle controller connected");
  }

  async togglePublic(event) {
    // Get the story ID from the data attribute
    const storyId = event.target.getAttribute('data-story-id');

    // Make an HTTP request to update the public attribute
    const response = await fetch(`/stories/${storyId}`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      },
      body: JSON.stringify({
        story: {
          public: !event.target.classList.contains('fa-lock-open')
        }
      })
    });

    // Check if the operation was successful
    if (response.ok) {
      // Update the UI accordingly
      event.target.classList.toggle('fa-lock-open');
    } else {
      // Handle any errors
    }
  }

  async toggleFavorite(event) {
    // Get the story ID from the data attribute
    const storyId = event.target.getAttribute('data-story-id');

    // Determine whether to create or delete a favorite
    const method = event.target.classList.contains('card-heart-liked') ? 'DELETE' : 'POST';
    const url = method === 'POST' ? `/stories/${storyId}/favorites` : `/favorites/${storyId}`;

    // Make an HTTP request to create/delete a favorite
    const response = await fetch(url, {
      method: method,
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      },
      body: JSON.stringify({
        user_id: current_user.id
      })
    });

    // Check if the operation was successful
    if (response.ok) {
      // Update the UI accordingly
      event.target.classList.toggle('card-heart-liked');
      const favoriteCount = parseInt(this.favoriteCountTarget.textContent);
      this.favoriteCountTarget.textContent = method === 'POST' ? favoriteCount + 1 : favoriteCount - 1;
    } else {
      // Handle any errors
    }
  }
}
