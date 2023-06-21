import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["publicToggle", "heartIcon", "favoriteCount"]

  connect() {
    // Console logging for testing
    console.log("Toggle controller connected");
  }

  async togglePublic(event) {
    // Console logging for testing
    console.log("togglePublic function executed");

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
    // Update the UI accordingly
    event.target.classList.toggle('fa-lock-open');
    event.target.classList.toggle('fa-lock');
  }

  async toggleFavorite(event) {
    // Console logging for testing
    console.log("toggleFavorite function executed");

    // Get the story ID and current user ID from the data attributes
    const storyId = event.target.getAttribute('data-story-id');
    const currentUserId = this.data.get('currentUserId');

    // Determine whether to create or delete a favorite
    const method = this.heartIconTarget.classList.contains('card-heart-liked') ? 'DELETE' : 'POST';
    const url = method === 'POST' ? `/stories/${storyId}/favorites` : `/favorites/${storyId}`;

    // Make an HTTP request to create/delete a favorite
    const response = await fetch(url, {
      method: method,
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      },
      body: JSON.stringify({
        user_id: currentUserId
      })
    });
    // Update the UI accordingly
    this.heartIconTarget.classList.toggle('card-heart-liked');
    const favoriteCount = parseInt(this.favoriteCountTarget.textContent);
    this.favoriteCountTarget.textContent = method === 'POST' ? favoriteCount + 1 : favoriteCount - 1;
  }
}
