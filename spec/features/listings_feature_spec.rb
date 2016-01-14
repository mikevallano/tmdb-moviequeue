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

      api_search_then_add_movie_to_list

      expect(page).to have_content("added to your list")

    end

     scenario "users can remove a movie from their list from the list show page" do

      api_search_then_add_movie_to_list

      click_link "my_lists_nav_link"
      click_link "show_list_link_list_index"
      click_link "remove_movie_link_list_show"
      expect(page).to have_content("Movie was removed from list.")

    end

    scenario "user can update a listing's priority" do

      list
      movie
      listing

      sign_in_user(user)
      click_link "my_lists_nav_link"
      click_link "show_list_link_list_index"
      fill_in "new priority", with: '9'
      click_button "add_priority_button_list_show"
      expect(page).to have_content("Priority added.")
      expect(page).to have_content('9')

    end

  end

end #final