require 'rails_helper'

feature "User can create a new rating" do

  let(:user) { FactoryGirl.create(:user) }
  let(:user2) { FactoryGirl.create(:user) }
  let(:movie) { FactoryGirl.create(:movie) }
  let(:list) { FactoryGirl.create(:list, owner_id: user.id) }
  let(:list2) { FactoryGirl.create(:list, owner_id: user2.id) }
  let(:listing) { FactoryGirl.create(:listing, list_id: list.id, movie_id: movie.id) }
  let(:listing2) { FactoryGirl.create(:listing, list_id: list2.id, movie_id: movie.id) }

  context "with signed in user" do

    scenario "users can create a rating" do

      listing
      sign_in_user(user)
      click_link "movies"
      click_link "Show"
      click_link "Rate this movie"
      fill_in 'Value', with: "9"

      expect { click_button 'Create Rating' }.to change(Rating.by_user(user), :count).by(1)
      expect(page).to have_content("successfully")
      expect(page).to have_content("9")

    end #end create rating scenario

    scenario "movie show page shows only the current user's rating" do

      listing
      sign_in_user(user)
      click_link "movies"
      click_link "Show"
      click_link "Rate this movie"
      fill_in 'Value', with: "9"
      click_button 'Create Rating'
      click_link "Sign Out"

      listing2
      sign_in_user(user2)
      click_link "movies"
      click_link "Show"
      expect(page).not_to have_content("9")
      click_link "Sign Out"

      sign_in_user(user)
      click_link "movies"
      click_link "Show"
      expect(page).to have_content("9")


    end #only current user's rating

  end # signed in user context

end #feature