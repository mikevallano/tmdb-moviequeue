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
    expect(page).to have_content("you betcha")

  end

  scenario "movie is added to the database if a user adds it to their list" do

    sign_up_with(email, "password")
    visit(api_search_path)
    api_search_for_movie #method in features_helper

    api_more_info #method in features_helper

    all('#new_listing option')[0].select_option
    VCR.use_cassette('tmdb_add_movie') do
      click_button("add movie to list")
    end
    expect(Movie.last.title).to eq("Fargo")

  end

  scenario "movie has genres after being added to the database" do

    sign_up_with(email, "password")
    visit(api_search_path)
    api_search_for_movie #method in features_helper

    api_more_info #method in features_helper

    all('#new_listing option')[0].select_option
    VCR.use_cassette('tmdb_add_movie') do
      click_button("add movie to list")
    end
    expect(Movie.last.genres).to include("Crime")

  end


end