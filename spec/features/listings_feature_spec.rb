require 'rails_helper'

RSpec.feature "Listings feature spec", :type => :feature do

  feature "User can search for a movie and add it to their list" do

    let(:email) { FFaker::Internet.email }
    let(:username) { FFaker::Internet.user_name }
    let(:user) { FactoryGirl.create(:user) }
    let(:user2) { FactoryGirl.create(:user) }
    let(:movie) { FactoryGirl.create(:movie) }
    let(:list) { FactoryGirl.create(:list, owner_id: user.id) }
    let(:list2) { FactoryGirl.create(:list, owner_id: user2.id) }
    let(:listing) { FactoryGirl.create(:listing, list_id: list.id, movie_id: movie.id) }
    let(:listing2) { FactoryGirl.create(:listing, list_id: list2.id, movie_id: movie.id) }

    scenario "users can add a movie to their list" do

      sign_up_with(email, username, "password")
      visit(api_search_path)
      api_search_for_movie #method in features_helper

      api_movie_more_info #method in features_helper

      all('#new_listing option')[0].select_option
      VCR.use_cassette('tmdb_add_movie') do
        click_button("add movie to list")
      end
      expect(page).to have_content("added to your list")

    end

     scenario "users can remove a movie from their list" do

      sign_up_with(email, username, "password")
      visit(api_search_path)
      api_search_for_movie #method in features_helper

      api_movie_more_info #method in features_helper

      all('#new_listing option')[0].select_option
      VCR.use_cassette('tmdb_add_movie') do
        click_button("add movie to list")
      end
      click_link("Lists")
      click_link("Show")
      click_link("Remove from this list")
      expect(page).to have_content("Movie was removed from list.")

    end

    scenario "user can update a listing's priority" do

      list
      movie
      listing

      sign_in_user(user)
      click_link "Lists"
      click_link "Show"
      fill_in "new priority", with: '9'
      click_button "Prioritize"
      expect(page).to have_content("Priority added.")
      expect(page).to have_content('9')

    end

  end

end #final