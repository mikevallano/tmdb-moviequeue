require "rails_helper"

RSpec.feature "TMDB feature spec", :type => :feature do

  feature "User can perform various searches using the TMDB api" do

    let(:user) { FactoryBot.create(:user) }
    let(:email) { FFaker::Internet.email }
    let(:username) { FFaker::Internet.user_name }
    let(:list) { FactoryBot.create(:list, name: "my queue", owner_id: user.id) }

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
        expect(page).to have_content("Page 1 of 5")
        expect(page).not_to have_content("Previous page")
        VCR.use_cassette("tmdb_actor_next_page", :record => :new_episodes) do
          click_link "Next page"
        end
        expect(page).to have_content("Page 2 of 5")
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
        VCR.use_cassette('tmdb_two_actor_search') do
          fill_in "actor1_field_two_actor_search", with: 'Steve Buscemi'
          fill_in "actor2_field_two_actor_search", with: 'John Goodman'
          click_button "search_button_two_actor_search"
        end
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
        VCR.use_cassette("fill_in_frances_mcdormand", :record => :new_episodes) do
          fill_in "actor_field_discover_search", with: "Frances McDormand"
        end
        VCR.use_cassette("discover_actor_search", :record => :new_episodes) do
          click_button "search_button_discover_search"
        end
        wait_for_ajax
        expect(page).to have_selector("#modal_link_275")
      end

      scenario "search by actor and year", js: true do
        visit(discover_search_path)
        VCR.use_cassette("fill_in_steve_buscemi", :record => :new_episodes) do
          fill_in "actor_field_discover_search", with: "Steve Buscemi"
        end
          select "1996", :from => "date[year]"
        VCR.use_cassette("discover_actor_and_year", :record => :new_episodes) do
          click_button "search_button_discover_search"
        end
        wait_for_ajax
        expect(page).to have_selector("#modal_link_275")
      end

      scenario "search by actor and specific year", js: true do
        visit(discover_search_path)
        VCR.use_cassette("fill_in_steve_buscemi", :record => :new_episodes) do
          fill_in "actor_field_discover_search", with: "Steve Buscemi"
        end
          select "1996", :from => "date[year]"
          select "Exact Year", :from => "year_select"
        VCR.use_cassette("discover_actor_and_specific_year", :record => :new_episodes) do
          click_button "search_button_discover_search"
        end
        wait_for_ajax
        expect(page).to have_selector("#modal_link_275")
      end

      scenario "search by actor and before year", js: true do
        visit(discover_search_path)
        VCR.use_cassette("fill_in_steve_buscemi", :record => :new_episodes) do
          fill_in "actor_field_discover_search", with: "Steve Buscemi"
        end
          select "1997", :from => "date[year]"
          select "Before This Year", :from => "year_select"
         VCR.use_cassette("discover_actor_and_before_year", :record => :new_episodes) do
          click_button "search_button_discover_search"
        end
        wait_for_ajax
        expect(page).to have_selector("#modal_link_275")
      end

      scenario "search by actor year and mpaa rating", js: true do
        visit(discover_search_path)
        VCR.use_cassette("fill_in_steve_buscemi", :record => :new_episodes) do
          fill_in "actor_field_discover_search", with: "Steve Buscemi"
        end
          select "1997", :from => "date[year]"
          select "Before This Year", :from => "year_select"
          select "R", :from => "mpaa_rating"
        VCR.use_cassette("discover_actor_mpaa_rating_and_year", :record => :new_episodes) do
          click_button "search_button_discover_search"
        end
        wait_for_ajax
        expect(page).to have_selector("#modal_link_275")
      end

      # scenario "search by actor year and sort by popularity", js: true do
      #   skip "vcr issues"
      #   visit(discover_search_path)
      #   VCR.use_cassette("fill_in_steve_buscemi") do
      #     fill_in "actor_field_discover_search", with: "Steve Buscemi"
      #   end
      #     select "1996", :from => "date[year]"
      #     select "Popularity", :from => "sort_by"
      #   VCR.use_cassette("discover_actor_year_and_sort") do
      #     click_button "search_button_discover_search"
      #   end
      #   wait_for_ajax
      #   expect(page).to have_selector("#modal_link_275")
      # end

      # scenario "search by genre year and sort", js: true do
      #   skip "vcr issues"
      #   visit(discover_search_path)
      #   VCR.use_cassette("discover_genre_year_sort") do
      #     select "1996", :from => "date[year]"
      #     select "Crime", :from => "genre"
      #     select "Popularity", :from => "sort_by"
      #     click_button "search_button_discover_search"
      #   end
      #   wait_for_ajax
      #   expect(page).to have_selector("#modal_link_275")
      # end

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
        wait_for_ajax
        #description
        expect(page).to have_content("Fargo")
        #genres
        expect(page).to have_content("Crime")
        #actors
        expect(page).to have_content("Steve Buscemi")
        #director
        expect(page).to have_content("Joel Coen")
      end

      scenario "more info page shows link to similar movies that go to their more info page", js: true do
        find("#movie_more_link_movie_partial").click
        VCR.use_cassette("tmdb_similar_movies_more_info", :record => :new_episodes) do
          find("#similar_movies_link_movie_more").click
        end
        wait_for_ajax
        # expect(page).to have_content("The Revenant")
        expect(page).to have_selector("#modal_link_281957")
      end

      scenario "similar movies are paginated", js: true do
        find("#movie_more_link_movie_partial").click
        VCR.use_cassette("tmdb_similar_movies_more_info", :record => :new_episodes) do
          find("#similar_movies_link_movie_more").click
        end
        # expect(page).to have_content("The Revenant")
        expect(page).to have_selector("#modal_link_281957")
        expect(page).not_to have_content("Previous page")
        VCR.use_cassette("tmdb_similar_movies_paginate", :record => :new_episodes) do
          click_link "Next page"
        end
        wait_for_ajax
        expect(page).to have_content("Previous page")
      end

      # scenario "more info page shows production companies and links to a discover search", js: true do
      #   find("#movie_more_link_movie_partial").click
      #   expect(page).to have_content("PolyGram Filmed Entertainment")
      #   VCR.use_cassette("tmdb_production_company_search", :record => :new_episodes) do
      #     click_link "PolyGram Filmed Entertainment"
      #   end
      #   wait_for_ajax
      #   expect(page).to have_selector("#modal_link_31776")
      # end

      scenario "movies have a link to view full cast", js: true do
        find("#movie_more_link_movie_partial").click
        VCR.use_cassette("full_cast") do
          find("#full_cast_link_movie_show").click
        end
        wait_for_ajax
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
        api_actor_search_buscemi
      end

      scenario "actor search page links to actor more info search" do
        VCR.use_cassette("tmdb_actor_more", :record => :new_episodes) do
          click_link_or_button "bio_and_credits_link_actor_search"
        end
        expect(page).to have_content("Steve Buscemi")
        expect(page).to have_content("Born")
      end #actor more info search

      scenario "actor more info page links movies to movie_more_info path" do
        VCR.use_cassette("tmdb_actor_more", :record => :new_episodes) do
          click_link_or_button "bio_and_credits_link_actor_search"
        end
        VCR.use_cassette("actor_more_movie_link", :record => :new_episodes) do
          click_link "Fargo"
        end
        expect(current_url).to eq(movie_more_url(tmdb_id: 275))
      end #actor movie more

      scenario "actor more info page links tv shows to the tv show page" do
        VCR.use_cassette("tmdb_actor_more", :record => :new_episodes) do
          click_link_or_button "bio_and_credits_link_actor_search"
        end
        VCR.use_cassette("actor_tv_more", :record => :new_episodes) do
          click_link "The Simpsons"
        end
        expect(page).to have_content("The Simpsons")
      end #actor tv more

      scenario "tv series page links to individual seasons" do
        VCR.use_cassette("tmdb_actor_more", :record => :new_episodes) do
          click_link_or_button "bio_and_credits_link_actor_search"
        end
        VCR.use_cassette("actor_tv_more", :record => :new_episodes) do
          click_link "The Simpsons"
        end
        click_link "5"
        expect(page).to have_content("Season 5")
      end #actor tv more

      scenario "actor more info page links tv credits to credit url" do
        VCR.use_cassette("tmdb_actor_more", :record => :new_episodes) do
          click_link_or_button "bio_and_credits_link_actor_search"
        end
        VCR.use_cassette("actor_tv_credit", :record => :new_episodes) do
          click_link "Appearance Details", match: :first
        end
        expect(current_url).to eq(actor_credit_url(actor_id: 884, credit_id: "56ad478dc3a3681c34006885", show_name: "Horace and Pete"))
        expect(page).to have_content("Horace")
      end #actor tv credit

      scenario "actor credit shows episodes the actor was in" do
        VCR.use_cassette("tmdb_actor_more", :record => :new_episodes) do
          click_link_or_button "bio_and_credits_link_actor_search"
        end
        VCR.use_cassette("actor_tv_credit2") do
          click_link "appearance_details_portlandia", match: :first
        end
        expect(page).to have_content("Portlandia")
      end #actor tv credit

      scenario "actor more page has actor's headshot" do
        VCR.use_cassette("tmdb_actor_more", :record => :new_episodes) do
          click_link_or_button "bio_and_credits_link_actor_search"
        end
        expect(page).to have_css("img[src*='http://image.tmdb.org/t/p/w185/e19GfOWzMNN1hi7B9Ci62hMvtXs.jpg']")
      end

    end #actor searches


  end

end #final
