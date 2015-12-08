require 'rails_helper'

feature "User can create a new tag" do

  let(:user) { FactoryGirl.create(:user) }
  let(:email) { FFaker::Internet.email }

  context "with signed in user" do

    scenario "users can tag a movie" do

      sign_up_with(email, "password")
      visit(api_search_path)
      api_search_for_movie
      api_more_info
      all('#new_listing option')[0].select_option
      VCR.use_cassette('tmdb_add_movie') do
        click_button("add movie to list")
      end
      click_link("movies")
      fill_in "tag_list", with: "dark comedy, spooky"
      click_button("add tags", match: :first)
      expect(page).to have_content("added")
      expect(page).to have_content("dark-comedy")
      expect(page).to have_content("spooky")

    end #user can tag movie

  end #signed in user context

end #final