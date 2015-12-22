require 'rails_helper'

RSpec.feature "TMDB feature spec", :type => :feature do

  feature "User can visit the search page, search for movies and actors" do

    let(:email) { FFaker::Internet.email }
    let(:username) { FFaker::Internet.user_name }


    scenario "users visits search page successfully" do

      sign_up_with(email, username, "password")
      visit(api_search_path)
      expect(page).to have_content("Search the TMDB Database")

    end

    scenario "users searches for a movie and the API returns results" do

      sign_up_with(email, username, "password")
      visit(api_search_path)
      api_search_for_movie

      expect(page).to have_content("1996-04-05")
      expect(page).to have_content("Fargo")

    end

    scenario "users searches for an actor and the API returns results" do

      sign_up_with(email, username, "password")
      visit(actor_search_path)
      api_actor_search

      expect(page).to have_content("The Big Lebowski")

    end

    scenario "users searches for an actor not found and the page indicates results not found" do

      sign_up_with(email, username, "password")
      visit(actor_search_path)
      bad_api_actor_search

      expect(page).to have_content("No actor found for that search")

    end

    scenario "users searches for an two actors and the API returns results" do

      sign_up_with(email, username, "password")
      visit(two_actor_search_path)
      api_two_actor_search

      expect(page).to have_content("The Big Lebowski")

    end

    scenario "users searches for an two actors not found and the page indicates results not found" do

      sign_up_with(email, username, "password")
      visit(two_actor_search_path)
      bad_api_two_actor_search

      expect(page).to have_content("No movies found with those two in it")

    end

    scenario "users searches a movie not found and the page indicates movie not found" do

      sign_up_with(email, username, "password")
      visit(api_search_path)
      bad_api_search_for_movie

      expect(page).to have_content("No movie found for that search")

    end

    scenario "users clicks 'more info' and sees more info returned from API" do

      sign_up_with(email, username, "password")
      visit(api_search_path)
      api_search_for_movie

      api_more_info
      expect(page).to have_content("you betcha")

    end

    scenario "movie is added to the database if a user adds it to their list" do

      sign_up_with(email, username, "password")
      visit(api_search_path)
      api_search_for_movie

      api_more_info

      all('#new_listing option')[0].select_option
      VCR.use_cassette('tmdb_add_movie') do
        click_button("add movie to list")
      end
      expect(Movie.last.title).to eq("Fargo")

    end

    scenario "movie has genres after being added to the database" do

      sign_up_with(email, username, "password")
      visit(api_search_path)
      api_search_for_movie

      api_more_info

      all('#new_listing option')[0].select_option
      VCR.use_cassette('tmdb_add_movie') do
        click_button("add movie to list")
      end
      expect(Movie.last.genres).to include("Crime")

    end

    scenario "movie has actors after being added to the database" do

      sign_up_with(email, username, "password")
      visit(api_search_path)
      api_search_for_movie

      api_more_info

      all('#new_listing option')[0].select_option
      VCR.use_cassette('tmdb_add_movie') do
        click_button("add movie to list")
      end
      expect(Movie.last.actors).to include("Steve Buscemi")

    end

  end

end #final