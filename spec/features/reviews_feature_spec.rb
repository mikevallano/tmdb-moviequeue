require 'rails_helper'

feature "User can create a new review" do

  let(:user) { FactoryGirl.create(:user) }
  let(:user2) { FactoryGirl.create(:user) }
  let(:movie) { FactoryGirl.create(:movie) }
  let(:list) { FactoryGirl.create(:list, owner_id: user.id) }
  let(:list2) { FactoryGirl.create(:list, owner_id: user2.id) }
  let(:listing) { FactoryGirl.create(:listing, list_id: list.id, movie_id: movie.id) }
  let(:listing2) { FactoryGirl.create(:listing, list_id: list2.id, movie_id: movie.id) }

  context "with signed in user" do

    scenario "users can create a review" do

      listing
      sign_in_user(user)
      click_link "movies"
      click_link "Show"
      click_link "Review this movie"
      fill_in 'Body', with: "OMG. best. movie. eva."

      expect { click_button 'Create Review' }.to change(Review.by_user(user), :count).by(1)
      expect(page).to have_content("successfully")
      expect(page).to have_content("OMG. best. movie. eva.")

    end #end create review scenario

    scenario "movie show page shows only the current user's review" do

      listing
      sign_in_user(user)
      click_link "movies"
      click_link "Show"
      click_link "Review this movie"
      fill_in 'Body', with: "OMG. best. movie. eva."
      click_button 'Create Review'
      click_link "Sign Out"

      listing2
      sign_in_user(user2)
      click_link "movies"
      click_link "Show"
      expect(page).not_to have_content("OMG")
      click_link "Sign Out"

      sign_in_user(user)
      click_link "movies"
      click_link "Show"
      expect(page).to have_content("OMG")


    end #only current user's review

  end #end signed-in context



end # feature end