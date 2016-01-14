require 'rails_helper'

RSpec.feature "TMDB feature spec", :type => :feature do

  feature "User can visit the search page, search for movies and actors" do

    let(:email) { FFaker::Internet.email }
    let(:username) { FFaker::Internet.user_name }


    scenario "users visits search page successfully" do

      sign_up_with(email, username, "password")
      visit(api_search_path)
      expect(page).to have_selector("#search_by_title_header")

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
        click_link "Next page"
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
        click_button "Search"
      end
      expect(page).to have_content("Steve Buscemi")

    end

    scenario "two movies search indicates first movie not found if search is bad" do

      sign_up_with(email, username, "password")
      visit(two_movie_search_path)
      VCR.use_cassette('tmdb_two_movie_search_bad_first') do
        fill_in "Enter Movie Title", with: '*sdlfkjsdflkjsdf'
        fill_in "Enter Other Movie Title", with: 'The Big Lebowski'
        click_button "Search"
      end
      expect(page).to have_content("No results for the first movie")

    end

    scenario "two movies search indicates second movie not found if search is bad" do

      sign_up_with(email, username, "password")
      visit(two_movie_search_path)
      VCR.use_cassette('tmdb_two_movie_search_bad_second') do
        fill_in "Enter Movie Title", with: 'Fargo'
        fill_in "Enter Other Movie Title", with: '*sdlfkjsdflkjsdf'
        click_button "Search"
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

      api_search_for_movie_then_movie_more

      expect(page).to have_content("you betcha")

    end

    scenario "users clicks 'more info' and the page shows similar movies" do

      api_search_for_movie_then_movie_more

      expect(page).to have_content("Similar Movies")
      expect(page).to have_content("The Revenant")

    end

    scenario "users clicks 'more info' on a similar movie and is taken to that movie's more info page" do

      api_search_for_movie_then_movie_more

      VCR.use_cassette("similar_movies_more_info") do
        click_link "More info", match: :first
      end
      expect(page).to have_content("The Revenant")

    end

    scenario 'movie more info page shows production companies and links to a discover search' do

      api_search_for_movie_then_movie_more

      expect(page).to have_content("PolyGram Filmed Entertainment")
      VCR.use_cassette("tmdb_production_company_search") do
        click_link "PolyGram Filmed Entertainment"
      end
      expect(page).to have_content("Where the Money is")

    end

    scenario "movie is added to the database if a user adds it to their list" do

      api_search_then_add_movie_to_list

      expect(Movie.last.title).to eq("Fargo")

    end

    scenario "movie has genres after being added to the database" do

      api_search_then_add_movie_to_list

      expect(Movie.last.genres).to include("Crime")

    end

    scenario "movie has actors after being added to the database" do

      api_search_then_add_movie_to_list

      expect(Movie.last.actors).to include("Steve Buscemi")

    end

    scenario "movie has director and director_id after being added to the database" do

      api_search_then_add_movie_to_list

      expect(Movie.last.director).to eq("Joel Coen")
      expect(Movie.last.director_id).to eq(1223)

    end

    scenario "movie has mpaa_rating after being added to the database" do

      api_search_then_add_movie_to_list

      expect(Movie.last.mpaa_rating).to eq("R")

    end

    scenario "movies have genres on the more info page" do

      sign_up_with(email, username, "password")
      visit(api_search_path)
      api_search_for_movie
      api_movie_more_info
      expect(page).to have_content("Crime")

    end #movies have genres

    #actor searches
    scenario "movies have actors on the more info page" do

      sign_up_with(email, username, "password")
      visit(api_search_path)
      api_search_for_movie
      api_movie_more_info

      expect(page).to have_content("Steve Buscemi")

    end #movies have actors

    scenario "movie show page shows actors, which links to actor search" do

      api_search_then_add_movie_to_list

      visit(movie_path(Movie.last))
      VCR.use_cassette('tmdb_actor_search') do
        click_link "Steve Buscemi"
      end
      expect(page).to have_content("Fargo")

    end #actors are links

    scenario 'actor search page links to actor more info search' do

      api_search_for_movie_then_movie_more

      VCR.use_cassette('tmdb_actor_search') do
        click_link "Steve Buscemi"
      end
      VCR.use_cassette('tmdb_actor_more') do
        click_link "Get a full list of credits and bio"
      end
      expect(page).to have_content("Steve Buscemi")
      expect(page).to have_content("Birthday")

    end #actor more info search

    scenario 'actor more info page links movies to movie_more_info path' do

      api_search_for_movie_then_movie_more

      VCR.use_cassette('tmdb_actor_search') do
        click_link "Steve Buscemi"
      end
      VCR.use_cassette('tmdb_actor_more') do
        click_link "Get a full list of credits and bio"
      end
      VCR.use_cassette('actor_more_movie_link') do
        click_link "Fargo"
      end
      expect(current_url).to eq(movie_more_url(movie_id: 275))

    end #actor movie more

    scenario 'actor more info page links tv shows to the tv show page' do

      api_search_for_movie_then_movie_more

      VCR.use_cassette('tmdb_actor_search') do
        click_link "Steve Buscemi"
      end
      VCR.use_cassette('tmdb_actor_more') do
        click_link "Get a full list of credits and bio"
      end
      VCR.use_cassette('actor_tv_more') do
        click_link "The Simpsons"
      end
      expect(current_url).to eq(tv_more_url(actor_id: 884, show_id: 456))
      expect(page).to have_content("The Simpsons")

    end #actor tv more

    scenario 'actor more info page links tv credits to credit url' do

      api_search_for_movie_then_movie_more

      VCR.use_cassette('tmdb_actor_search') do
        click_link "Steve Buscemi"
      end
      VCR.use_cassette('tmdb_actor_more') do
        click_link "Get a full list of credits and bio"
      end
      VCR.use_cassette('actor_tv_credit') do
        click_link "more info", match: :first
      end
      expect(current_url).to eq(actor_credit_url(actor_id: 884, credit_id: "5256c32c19c2956ff601d1f7", show_name: "The Simpsons"))
      expect(page).to have_content("Episode overview")
      expect(page).to have_content("The Simpsons")

    end #actor tv credit

    scenario 'tv credit page links to main show page' do

      api_search_for_movie_then_movie_more

      VCR.use_cassette('tmdb_actor_search') do
        click_link "Steve Buscemi"
      end
      VCR.use_cassette('tmdb_actor_more') do
        click_link "Get a full list of credits and bio"
      end
      VCR.use_cassette('actor_tv_credit') do
        click_link "more info", match: :first
      end
      VCR.use_cassette('tv_main_page') do
        click_link "The Simpsons"
      end
      expect(page).to have_content("The Simpsons")
      expect(current_url).to eq(tv_more_url(show_id: 456))

    end #actor tv main page

    #directors

    scenario "movies have directors on the more info page" do

      sign_up_with(email, username, "password")
      visit(api_search_path)
      api_search_for_movie
      api_movie_more_info
      expect(page).to have_content("Joel Coen")

    end #movies have directors

    scenario "movie show page shows director, which links to director search" do

      api_search_then_add_movie_to_list

      visit(movie_path(Movie.last))
      VCR.use_cassette('tmdb_director_search') do
        click_link "Joel Coen"
      end
      expect(page).to have_content("Fargo")

    end #directors are links

  end

end #final