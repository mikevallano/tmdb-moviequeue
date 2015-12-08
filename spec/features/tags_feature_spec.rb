require 'rails_helper'

feature "User can create a new tag" do

  let(:user) { FactoryGirl.create(:user) }

  context "with signed in user" do

    scenario "users can tag a movie" do

      sign_in_user(user)
      visit(api_search_path)
      api_search_for_movie #method in features_helper
      api_more_info #method in features_helper
      all('#new_listing option')[0].select_option
      VCR.use_cassette('tmdb_add_movie') do
        click_button("add movie to list")
      end
      fill_in "tags", with: "dark comedy"
      click_button("add tags", match: :first)
      expect(page).to have_content("added")

    end #user can tag movie


  end #signed in user context

end #final