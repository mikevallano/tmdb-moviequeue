require 'rails_helper'

RSpec.feature "Pages feature spec", type: :feature, feature: :true do

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
        click_button "Search"
      end
      expect(page).to have_selector(:xpath, "//*[@id='275']")
    end

    scenario "users see autocomplete suggestions when searching from the homepage", js: true do
      allow(MovieDataService).to receive(:get_movie_titles).with('farg').and_return(['Fargo'])

      fill_in "movie_title", with: 'farg'

      within('.autocomplete-results') do
        expect(page).to have_content('Fargo')
      end
    end

    scenario "users can search for a movie from the header", js: true do
      # The header search is hidden on narrow (mobile) screens
      page.driver.browser.manage.window.resize_to(1280,800)
      allow(MovieDataService).to receive(:get_movie_titles).and_return(['Fargo'])

      fill_in "movie_title_header", with: 'fargo'
      # Keep the cassette open until the results render, since the search
      # request is made by the server thread after Enter is pressed
      VCR.use_cassette('movie_search_header') do
        find_field("movie_title_header").send_keys(:return)
        expect(page).to have_css("[id='275']")
      end
    end

  end

end
