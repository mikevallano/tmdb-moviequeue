require 'rails_helper'

feature "User can visit the search page" do

 let(:email) { FFaker::Internet.email }


  scenario "users visits search page successfully" do

    sign_up_with(email, "password")
    visit(api_search_path)
    expect(page).to have_content("Search the TMDB Database")

  end

  scenario "users searches for a movie and the API returns results" do

    sign_up_with(email, "password")
    visit(api_search_path)
    api_search_for_movie #method in features_helper

    expect(page).to have_content("1996-04-05")
    expect(page).to have_content("Fargo")

  end

  scenario "users clicks 'more info' and sees more info returned from API" do

    sign_up_with(email, "password")
    visit(api_search_path)
    api_search_for_movie #method in features_helper

    api_more_info #method in features_helper
    expect(page).to have_content("Genres: Crime, Drama, Thriller")

  end


end