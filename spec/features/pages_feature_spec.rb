require 'rails_helper'

RSpec.feature "Pages feature spec", :type => :feature do

  let(:user) { FactoryBot.create(:user) }

  describe "search by title" do

    before(:each) do
      sign_in_user(user)
      visit(root_path)
    end

    scenario "users can search for a movie from the homepage" do
      VCR.use_cassette('movie_title_search_home_page') do
        fill_in "movie_title", with: 'fargo'
      end
       VCR.use_cassette('movie_search_home') do
        click_button "search_by_title_home_button"
      end
      expect(page).to have_selector("#modal_link_275")
    end

    scenario "users can search for a movie from the header", js: true do
      skip "Need to switch to poltergiest"
      VCR.use_cassette('movie_title_search_header') do
        fill_in "movie_title_header", with: 'fargo'
      end
       VCR.use_cassette('movie_search_header') do
        find('#header_movie_search').native.send_keys(:return)
      end
      expect(page).to have_selector("#modal_link_275")
    end

  end

end
