require 'rails_helper'

# Delete links rely on Turbo's data-turbo-method (rails-ujs isn't loaded, so a
# plain `method: :delete` on link_to would send a GET). JS-driven specs for
# these were flaky in headless Chrome, so assert the markup instead.
RSpec.feature "Delete links", type: :feature, feature: :true do
  let(:user) { create(:user) }
  let(:movie) { create(:movie) }

  before { sign_in_user(user) }

  scenario "rating delete link uses Turbo DELETE" do
    rating = create(:rating, user: user, movie: movie)
    visit movie_ratings_path(movie)

    expect(page).to have_css(
      "a[data-turbo-method='delete'][href='#{movie_rating_path(movie, rating)}']", text: "Delete"
    )
  end

  scenario "review delete link uses Turbo DELETE" do
    review = create(:review, user: user, movie: movie, body: "it were awesome")
    visit movie_reviews_path(movie)

    expect(page).to have_css(
      "a[data-turbo-method='delete'][href='#{movie_review_path(movie, review)}']", text: "Delete"
    )
  end
end
