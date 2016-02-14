require "rails_helper"

RSpec.feature "TMDB feature spec", :type => :feature do

  feature "User can perform various searches using the TMDB api" do

    let(:user) { FactoryGirl.create(:user) }
    let(:email) { FFaker::Internet.email }
    let(:username) { FFaker::Internet.user_name }
    let(:list) { FactoryGirl.create(:list, name: "my queue", owner_id: user.id) }

    describe "search by title" do

      before(:each) do
        sign_in_user(user)
        visit(api_search_path)
      end

      scenario "users searches for a movie by title and the API returns results" do
        api_search_for_movie
        expect(page).to have_selector("#modal_link_275")
      end

      scenario "users searches a movie not found and the page indicates movie not found" do
        bad_api_search_for_movie
        expect(page).to have_content("No results")
      end

    end #search by title

    describe "search by actor" do

      before(:each) do
        sign_in_user(user)
        visit(actor_search_path)
      end

      scenario "users searches for an actor and the API returns results" do
        api_actor_search
        expect(page).to have_selector("#modal_link_275")
      end

      scenario "actor results are paginated" do
        api_actor_search
        expect(page).to have_content("Page 1 of 6")
        expect(page).not_to have_content("Previous page")
        VCR.use_cassette("tmdb_actor_next_page") do
          click_link "Next page"
        end
        expect(page).to have_content("Page 2 of 6")
        expect(page).to have_content("Previous page")
      end

      scenario "users searches for an actor not found and the page indicates results not found" do
        bad_api_actor_search
        expect(page).to have_content("No results")
      end

    end #search by actor

    describe "search by two actors" do

      before(:each) do
        sign_in_user(user)
        visit(two_actor_search_path)
      end

      scenario "users searches for two actors and the API returns results" do
        skip "this actually isn't working"
        api_two_actor_search
        binding.pry
        expect(page).to have_selector("#modal_link_115")
      end

      scenario "users searches for an two actors not found and the page indicates results not found" do
        bad_api_two_actor_search
        expect(page).to have_content("No results")
      end

    end #search by two actors

    describe "search by two movies" do

      before(:each) do
        sign_in_user(user)
      end

      scenario "two movies search returns common actors in both movies" do
        visit(two_movie_search_path)
        VCR.use_cassette("tmdb_two_movie_search") do
          fill_in "movie1_field_two_movie_search", with: "Fargo"
          fill_in "movie2_field_two_movie_search", with: "The Big Lebowski"
          click_button "search_button_two_movie_search"
        end
        expect(page).to have_content("Steve Buscemi")
      end

      scenario "two movies search indicates first movie not found if search is bad" do
        visit(two_movie_search_path)
        @movie_query1 = "*sdlfkjsdflkjsdf"
        @movie_query2 = "The Big Lebowski"
        VCR.use_cassette("tmdb_two_movie_search_bad_first") do
          fill_in "movie1_field_two_movie_search", with: @movie_query1
          fill_in "movie2_field_two_movie_search", with: @movie_query2
          click_button "search_button_two_movie_search"
        end
        expect(page).to have_content("No results for '#{@movie_query1.titlecase}'.")
      end

      scenario "two movies search indicates second movie not found if search is bad" do
        visit(two_movie_search_path)
        @movie_query1 = "Fargo"
        @movie_query2 = "*sdlfkjsdflkjsdf"
        VCR.use_cassette("tmdb_two_movie_search_bad_second") do
          fill_in "movie1_field_two_movie_search", with: @movie_query1
          fill_in "movie2_field_two_movie_search", with: @movie_query2
          click_button "Search"
        end
        expect(page).to have_content("No results for '#{@movie_query2.titlecase}'.")
      end

    end #search by two movies

    describe "discover searches" do

      before(:each) do
        page.driver.browser.manage.window.resize_to(1280,800)
        sign_in_user(user)
      end

      scenario "search by actor returns results", js: true do
        visit(discover_search_path)
        VCR.use_cassette("discover_actor_search") do
          fill_in "actor_field_discover_search", with: "Frances McDormand"
          click_button "search_button_discover_search"
        end
        wait_for_ajax
        expect(page).to have_selector("#modal_link_275")
      end

      scenario "search by actor and year", js: true do
        visit(discover_search_path)
        VCR.use_cassette("discover_actor_and_year") do
          fill_in "actor_field_discover_search", with: "Steve Buscemi"
          select "1996", :from => "date[year]"
          click_button "search_button_discover_search"
        end
        wait_for_ajax
        expect(page).to have_selector("#modal_link_275")
      end

      scenario "search by actor and specific year", js: true do
        visit(discover_search_path)
        VCR.use_cassette("discover_actor_and_specific_year") do
          fill_in "actor_field_discover_search", with: "Steve Buscemi"
          select "1996", :from => "date[year]"
          select "Exact Year", :from => "year_select"
          click_button "search_button_discover_search"
        end
        wait_for_ajax
        expect(page).to have_selector("#modal_link_275")
      end

      # scenario "search by actor and after year", js: true do
      #   skip "weird API call issues. breaking at line 179 in tmdb_handler"
      #   visit(discover_search_path)
      #   fill_in "actor_field_discover_search", with: "ben affleck"
      #   select "2005", :from => "date[year]"
      #   select "After This Year", :from => "year_select"
      #   click_button "search_button_discover_search"
      #   # expect(page).to have_content("Argo")
      #   wait_for_ajax
      #   expect(page).to have_selector("#modal_link_68734")
      # end

      scenario "search by actor and before year", js: true do
        visit(discover_search_path)
        VCR.use_cassette("discover_actor_and_before_year") do
          fill_in "actor_field_discover_search", with: "Steve Buscemi"
          select "1997", :from => "date[year]"
          select "Before This Year", :from => "year_select"
          click_button "search_button_discover_search"
        end
        wait_for_ajax
        expect(page).to have_selector("#modal_link_275")
      end

      scenario "search by actor year and mpaa rating", js: true do
        visit(discover_search_path)
        VCR.use_cassette("discover_actor_mpaa_rating_and_year") do
          fill_in "actor_field_discover_search", with: "Steve Buscemi"
          select "1997", :from => "date[year]"
          select "Before This Year", :from => "year_select"
          select "R", :from => "mpaa_rating"
          click_button "search_button_discover_search"
        end
        wait_for_ajax
        expect(page).to have_selector("#modal_link_275")
      end

      scenario "search by actor year and sort by popularity", js: true do
        visit(discover_search_path)
        VCR.use_cassette("discover_actor_year_and_sort") do
          fill_in "actor_field_discover_search", with: "Steve Buscemi"
          select "1996", :from => "date[year]"
          select "Popularity", :from => "sort_by"
          click_button "search_button_discover_search"
        end
        wait_for_ajax
        expect(page).to have_selector("#modal_link_275")
      end

      scenario "search by genre year and sort", js: true do
        visit(discover_search_path)
        VCR.use_cassette("discover_genre_year_sort") do
          select "1996", :from => "date[year]"
          select "Crime", :from => "genre"
          select "Popularity", :from => "sort_by"
          click_button "search_button_discover_search"
        end
        wait_for_ajax
        expect(page).to have_selector("#modal_link_275")
      end

    end #discover searches

    describe "movie more info results" do

      before(:each) do
        page.driver.browser.manage.window.resize_to(1280,800)
        sign_in_user(user)
        visit(api_search_path)
        api_search_for_movie
        find("#modal_link_275").click
        wait_for_ajax
        find("#movie_more_link_movie_partial")
      end

      scenario "more info page shows more info", js: true do
        find("#movie_more_link_movie_partial").click
        #description
        expect(page).to have_content("you betcha")
        #genres
        expect(page).to have_content("Crime")
        #actors
        expect(page).to have_content("Steve Buscemi")
        #director
        expect(page).to have_content("Joel Coen")
      end

      scenario "more info page shows link to similar movies that go to their more info page", js: true do
        find("#movie_more_link_movie_partial").click
        VCR.use_cassette("tmdb_similar_movies_more_info") do
          find("#similar_movies_link_movie_more").click
        end
        # expect(page).to have_content("The Revenant")
        expect(page).to have_selector("#modal_link_281957")
      end

      scenario "similar movies are paginated", js: true do
        find("#movie_more_link_movie_partial").click
        VCR.use_cassette("tmdb_similar_movies_more_info") do
          find("#similar_movies_link_movie_more").click
        end
        # expect(page).to have_content("The Revenant")
        expect(page).to have_selector("#modal_link_281957")
        expect(page).not_to have_content("Previous page")
        VCR.use_cassette("tmdb_similar_movies_paginate") do
          click_link "Next page"
        end
        expect(page).to have_content("Previous page")
      end

      scenario "more info page shows production companies and links to a discover search", js: true do
        skip "update once show page is in better order"
        expect(page).to have_content("PolyGram Filmed Entertainment")
        VCR.use_cassette("tmdb_production_company_search") do
          click_link "PolyGram Filmed Entertainment"
        end
        # expect(page).to have_content("Where the Money is")
        expect(page).to have_selector("#modal_link_31776")
      end

      scenario "movies have a link to view full cast", js: true do
        skip "weird issue of going to the homepage"
        find("#movie_more_link_movie_partial").click
        VCR.use_cassette("full_cast") do
          find("#full_cast_link_movie_show").click
        end
        expect(page).to have_content("Steve Buscemi")
      end

    end #movie more info results

    describe "movie added to the database" do

      before(:each) do
        list
        page.driver.browser.manage.window.resize_to(1280,800)
        sign_in_user(user)
        visit(api_search_path)
        api_search_for_movie
        find("#modal_link_275").click
        wait_for_ajax
        select "my queue", :from => "listing[list_id]", match: :first
        VCR.use_cassette('tmdb_add_movie') do
          click_button "add_to_list_button_movies_partial", match: :first
        end
        wait_for_ajax
        find("#show_list_link_on_list_movies_partial")
      end

      scenario "movie is added to the database if a user adds it to their list", js: true do
        expect(Movie.last.title).to eq("Fargo")
        #has genres
        expect(Movie.last.genres).to include("Crime")
        #has actors
        expect(Movie.last.actors).to include("Steve Buscemi")
        #has director info
        expect(Movie.last.director).to eq("Joel Coen")
        expect(Movie.last.director_id).to eq(1223)
        #has mpaa rating
        expect(Movie.last.mpaa_rating).to eq("R")
      end

    end #movie added to the database

    describe "actor searches that drill down to tv" do

      before(:each) do
        sign_in_user(user)
        visit(actor_search_path)
        api_actor_search
      end

      scenario "users searches for an actor and the API returns results" do
        expect(page).to have_selector("#modal_link_275")
      end

      scenario "actor search page links to actor more info search" do
        VCR.use_cassette("tmdb_actor_more") do
          click_link "Get a full list of credits and bio"
        end
        expect(page).to have_content("Steve Buscemi")
        expect(page).to have_content("Born")
      end #actor more info search

      scenario "actor more info page links movies to movie_more_info path" do
        VCR.use_cassette("tmdb_actor_more") do
          click_link "Get a full list of credits and bio"
        end
        VCR.use_cassette("actor_more_movie_link") do
          click_link "Fargo"
        end
        expect(current_url).to eq(movie_more_url(tmdb_id: 275))
      end #actor movie more

      scenario "actor more info page links tv shows to the tv show page" do
        VCR.use_cassette("tmdb_actor_more") do
          click_link "Get a full list of credits and bio"
        end
        VCR.use_cassette("actor_tv_more") do
          click_link "The Simpsons"
        end
        expect(current_url).to eq(tv_more_url(actor_id: 884, show_id: 456))
        expect(page).to have_content("The Simpsons")
      end #actor tv more

      scenario "actor more info page links tv credits to credit url" do
        VCR.use_cassette("tmdb_actor_more") do
          click_link "Get a full list of credits and bio"
        end
        VCR.use_cassette("actor_tv_credit") do
          click_link "Appearance Details", match: :first
        end
        expect(current_url).to eq(actor_credit_url(actor_id: 884, credit_id: "5256c32c19c2956ff601d1f7", show_name: "The Simpsons"))
        expect(page).to have_content("Episode overview")
        expect(page).to have_content("The Simpsons")
      end #actor tv credit

      scenario "tv credit page links to main show page" do
        VCR.use_cassette("tmdb_actor_more") do
          click_link "Get a full list of credits and bio"
        end
        VCR.use_cassette("actor_tv_credit") do
          click_link "Appearance Details", match: :first
        end
        VCR.use_cassette("tv_main_page") do
          click_link "The Simpsons"
        end
        expect(page).to have_content("The Simpsons")
        expect(current_url).to eq(tv_more_url(show_id: 456))
      end #actor tv main page

    end #actor searches


  end

end #final