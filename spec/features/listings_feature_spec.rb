require 'rails_helper'

feature "User can search for a movie and add it to their list" do

  let(:email) { FFaker::Internet.email }

  scenario "users can add a movie to their list" do

    sign_up_with(email, "password")
    visit(api_search_path)
    api_search_for_movie #method in features_helper

    api_more_info #method in features_helper

    all('#new_listing option')[0].select_option
    VCR.use_cassette('tmdb_add_movie') do
      click_button("add movie to list")
    end
    expect(page).to have_content("added to your list")

  end

   scenario "users can remove a movie from their list" do

    sign_up_with(email, "password")
    visit(api_search_path)
    api_search_for_movie #method in features_helper

    api_more_info #method in features_helper

    all('#new_listing option')[0].select_option
    VCR.use_cassette('tmdb_add_movie') do
      click_button("add movie to list")
    end
    click_link("Lists")
    click_link("Show")
    click_link("Remove from this list")
    expect(page).to have_content("Movie was removed from list.")

  end


end