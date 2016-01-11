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

    scenario "actor results are paginated" do

      sign_up_with(email, username, "password")
      visit(actor_search_path)
      api_actor_search

      expect(page).to have_content("Page 1 of 6")
      expect(page).not_to have_content("Previous page")
      VCR.use_cassette('tmdb_actor_next_page') do
        click_link("Next page")
      end
      expect(page).to have_content("Page 2 of 6")
      expect(page).to have_content("Previous page")

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

    scenario "two movies search returns common actors in both movies" do

      sign_up_with(email, username, "password")
      visit(two_movie_search_path)
      VCR.use_cassette('tmdb_two_movie_search') do
        fill_in "Enter Movie Title", with: 'Fargo'
        fill_in "Enter Other Movie Title", with: 'The Big Lebowski'
        click_button 'Search'
      end
      expect(page).to have_content("Steve Buscemi")

    end

    scenario "two movies search indicates first movie not found if search is bad" do

      sign_up_with(email, username, "password")
      visit(two_movie_search_path)
      VCR.use_cassette('tmdb_two_movie_search_bad_first') do
        fill_in "Enter Movie Title", with: '*sdlfkjsdflkjsdf'
        fill_in "Enter Other Movie Title", with: 'The Big Lebowski'
        click_button 'Search'
      end
      expect(page).to have_content("No results for the first movie")

    end

    scenario "two movies search indicates second movie not found if search is bad" do

      sign_up_with(email, username, "password")
      visit(two_movie_search_path)
      VCR.use_cassette('tmdb_two_movie_search_bad_second') do
        fill_in "Enter Movie Title", with: 'Fargo'
        fill_in "Enter Other Movie Title", with: '*sdlfkjsdflkjsdf'
        click_button 'Search'
      end
      expect(page).to have_content("No results for the second movie")

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

      api_movie_more_info
      expect(page).to have_content("you betcha")

    end

    scenario "users clicks 'more info' and the page shows similar movies" do

      sign_up_with(email, username, "password")
      visit(api_search_path)
      api_search_for_movie
      api_movie_more_info

      expect(page).to have_content("Similar Movies")
      expect(page).to have_content("The Revenant")

    end

    scenario "users clicks 'more info' on a similar movie and is taken to that movie's more info page" do

      sign_up_with(email, username, "password")
      visit(api_search_path)
      api_search_for_movie
      api_movie_more_info

      VCR.use_cassette("similar_movies_more_info") do
        click_link("More info", match: :first)
      end
      expect(page).to have_content("The Revenant")

    end

    scenario 'movie more info page shows production companies and links to a discover search' do

      sign_up_with(email, username, "password")
      visit(api_search_path)
      api_search_for_movie
      api_movie_more_info

      expect(page).to have_content("PolyGram Filmed Entertainment")
      VCR.use_cassette("tmdb_production_company_search") do
        click_link("PolyGram Filmed Entertainment")
      end
      expect(page).to have_content("Where the Money is")

    end

    scenario "movie is added to the database if a user adds it to their list" do

      sign_up_with(email, username, "password")
      visit(api_search_path)
      api_search_for_movie

      api_movie_more_info

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

      api_movie_more_info

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

      api_movie_more_info

      all('#new_listing option')[0].select_option
      VCR.use_cassette('tmdb_add_movie') do
        click_button("add movie to list")
      end
      expect(Movie.last.actors).to include("Steve Buscemi")

    end

    scenario "movie has director and director_id after being added to the database" do

      sign_up_with(email, username, "password")
      visit(api_search_path)
      api_search_for_movie

      api_movie_more_info

      all('#new_listing option')[0].select_option
      VCR.use_cassette('tmdb_add_movie') do
        click_button("add movie to list")
      end
      expect(Movie.last.director).to eq("Joel Coen")
      expect(Movie.last.director_id).to eq(1223)

    end

    scenario "movie has mpaa_rating after being added to the database" do

      sign_up_with(email, username, "password")
      visit(api_search_path)
      api_search_for_movie

      api_movie_more_info

      all('#new_listing option')[0].select_option
      VCR.use_cassette('tmdb_add_movie') do
        click_button("add movie to list")
      end
      expect(Movie.last.mpaa_rating).to eq("R")

    end

  end

end #final