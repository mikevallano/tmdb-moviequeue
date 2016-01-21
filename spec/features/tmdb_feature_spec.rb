require "rails_helper"

RSpec.feature "TMDB feature spec", :type => :feature do

  feature "User can perform various searches using the TMDB api" do

    let(:email) { FFaker::Internet.email }
    let(:username) { FFaker::Internet.user_name }

    describe "search by title" do

      scenario "users searches for a movie by title and the API returns results" do
        sign_up_with(email, username, "password")
        visit(api_search_path)
        api_search_for_movie
        expect(page).to have_content("1996-04-05")
        expect(page).to have_content("Fargo")
      end

      scenario "users searches a movie not found and the page indicates movie not found" do
        sign_up_with(email, username, "password")
        visit(api_search_path)
        bad_api_search_for_movie
        expect(page).to have_content("No movie found for that search")
      end

    end #search by title

    describe "search by actor" do

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
        VCR.use_cassette("tmdb_actor_next_page") do
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

    end #search by actor

    describe "search by two actors" do

      scenario "users searches for two actors and the API returns results" do
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

    end #search by two actors

    describe "search by two movies" do

      before(:each) do
        sign_up_with(email, username, "password")
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
        VCR.use_cassette("tmdb_two_movie_search_bad_first") do
          fill_in "movie1_field_two_movie_search", with: "*sdlfkjsdflkjsdf"
          fill_in "movie2_field_two_movie_search", with: "The Big Lebowski"
          click_button "search_button_two_movie_search"
        end
        expect(page).to have_content("No results for the first movie")
      end

      scenario "two movies search indicates second movie not found if search is bad" do
        visit(two_movie_search_path)
        VCR.use_cassette("tmdb_two_movie_search_bad_second") do
          fill_in "movie1_field_two_movie_search", with: "Fargo"
          fill_in "movie2_field_two_movie_search", with: "*sdlfkjsdflkjsdf"
          click_button "Search"
        end
        expect(page).to have_content("No results for the second movie")
      end

    end #search by two movies

    describe "discover searches" do

      before(:each) do
        sign_up_with(email, username, "password")
      end

      scenario "search by actor returns results" do
        visit(discover_search_path)
        VCR.use_cassette("discover_actor_search") do
          fill_in "actor_field_discover_search", with: "Frances McDormand"
          click_button "search_button_discover_search"
        end
        expect(page).to have_content("Fargo")
      end

      scenario "search by actor and year" do
        visit(discover_search_path)
        VCR.use_cassette("discover_actor_and_year") do
          fill_in "actor_field_discover_search", with: "Steve Buscemi"
          fill_in "year_field_discover_search", with: "1996"
          click_button "search_button_discover_search"
        end
        expect(page).to have_content("Fargo")
      end

      scenario "search by actor and specific year" do
        visit(discover_search_path)
        VCR.use_cassette("discover_actor_and_specific_year") do
          fill_in "actor_field_discover_search", with: "Steve Buscemi"
          fill_in "year_field_discover_search", with: "1996"
          select "Exact Year", :from => "year_select"
          click_button "search_button_discover_search"
        end
        expect(page).to have_content("Fargo")
      end

      scenario "search by actor and after year" do
        visit(discover_search_path)
        VCR.use_cassette("discover_actor_and_after_year") do
          fill_in "actor_field_discover_search", with: "Steve Buscemi"
          fill_in "year_field_discover_search", with: "1995"
          select "After This Year", :from => "year_select"
          click_button "search_button_discover_search"
        end
        expect(page).to have_content("Armageddon")
      end

      scenario "search by actor and before year" do
        visit(discover_search_path)
        VCR.use_cassette("discover_actor_and_before_year") do
          fill_in "actor_field_discover_search", with: "Steve Buscemi"
          fill_in "year_field_discover_search", with: "1997"
          select "Before This Year", :from => "year_select"
          click_button "search_button_discover_search"
        end
        expect(page).to have_content("Fargo")
      end

      scenario "search by actor year and mpaa rating" do
        visit(discover_search_path)
        VCR.use_cassette("discover_actor_mpaa_rating_and_year") do
          fill_in "actor_field_discover_search", with: "Steve Buscemi"
          fill_in "year_field_discover_search", with: "1997"
          select "Before This Year", :from => "year_select"
          select "R", :from => "mpaa_rating"
          click_button "search_button_discover_search"
        end
        expect(page).to have_content("Fargo")
      end

      scenario "search by actor year and sort by popularity" do
        visit(discover_search_path)
        VCR.use_cassette("discover_actor_year_and_sort") do
          fill_in "actor_field_discover_search", with: "Steve Buscemi"
          fill_in "year_field_discover_search", with: "1996"
          select "Popularity", :from => "sort_by"
          click_button "search_button_discover_search"
        end
        expect(page).to have_content("Fargo")
      end

      scenario "search by genre year and sort" do
        visit(discover_search_path)
        VCR.use_cassette("discover_genre_year_sort") do
          fill_in "year_field_discover_search", with: "1996"
          select "Crime", :from => "genre"
          select "Popularity", :from => "sort_by"
          click_button "search_button_discover_search"
        end
        expect(page).to have_content("Fargo")
      end

    end #discover searches

    describe "movie more info results" do

      scenario "more info page shows more info" do
        api_search_for_movie_then_movie_more
        expect(page).to have_content("you betcha")
      end

      scenario "more info page shows link to similar movies that go to their more info page" do
        api_search_for_movie_then_movie_more
        VCR.use_cassette("tmdb_similar_movies_more_info") do
          click_link "similar_movies_link_movie_more"
        end
        expect(page).to have_content("The Revenant")
      end

      scenario "similar movies are paginated" do
        api_search_for_movie_then_movie_more
        VCR.use_cassette("tmdb_similar_movies_more_info") do
          click_link "similar_movies_link_movie_more"
        end
        expect(page).to have_content("The Revenant")
        # TODO: VCR cassette to cick next page and expect to have_content 'previous page'
      end

      scenario "more info page shows production companies and links to a discover search" do
        api_search_for_movie_then_movie_more
        expect(page).to have_content("PolyGram Filmed Entertainment")
        VCR.use_cassette("tmdb_production_company_search") do
          click_link "PolyGram Filmed Entertainment"
        end
        expect(page).to have_content("Where the Money is")
      end

      scenario "more info page shows genres" do
        sign_up_with(email, username, "password")
        visit(api_search_path)
        api_search_for_movie
        api_movie_more_info
        expect(page).to have_content("Crime")
      end

      scenario "movies have actors on the more info page" do
        sign_up_with(email, username, "password")
        visit(api_search_path)
        api_search_for_movie
        api_movie_more_info
        expect(page).to have_content("Steve Buscemi")
      end

      scenario "movies have directors on the more info page" do
        sign_up_with(email, username, "password")
        visit(api_search_path)
        api_search_for_movie
        api_movie_more_info
        expect(page).to have_content("Joel Coen")
      end

      scenario "movie show page shows director, which links to director search" do
        sign_up_api_search_then_add_movie_to_list
        visit(movie_path(Movie.last))
        VCR.use_cassette("tmdb_director_search") do
          click_link "Joel Coen"
        end
        expect(page).to have_content("Fargo")
      end

    end #movie more info results

    describe "movie added to the database" do

      scenario "movie is added to the database if a user adds it to their list" do
        sign_up_api_search_then_add_movie_to_list

        expect(Movie.last.title).to eq("Fargo")
      end

      scenario "movie has genres after being added to the database" do
        sign_up_api_search_then_add_movie_to_list
        expect(Movie.last.genres).to include("Crime")
      end

      scenario "movie has actors after being added to the database" do
        sign_up_api_search_then_add_movie_to_list
        expect(Movie.last.actors).to include("Steve Buscemi")
      end

      scenario "movie has director and director_id after being added to the database" do
        sign_up_api_search_then_add_movie_to_list
        expect(Movie.last.director).to eq("Joel Coen")
        expect(Movie.last.director_id).to eq(1223)
      end

      scenario "movie has mpaa_rating after being added to the database" do
        sign_up_api_search_then_add_movie_to_list
        expect(Movie.last.mpaa_rating).to eq("R")
      end

    end #movie added to the database

    describe "actor searches that drill down to tv" do

      scenario "movie show page shows actors, which links to actor search" do
        sign_up_api_search_then_add_movie_to_list
        visit(movie_path(Movie.last))
        VCR.use_cassette("tmdb_actor_search") do
          click_link "Steve Buscemi"
        end
        expect(page).to have_content("Fargo")
      end #actors are links

      scenario "actor search page links to actor more info search" do
        api_search_for_movie_then_movie_more
        VCR.use_cassette("tmdb_actor_search") do
          click_link "Steve Buscemi"
        end
        VCR.use_cassette("tmdb_actor_more") do
          click_link "Get a full list of credits and bio"
        end
        expect(page).to have_content("Steve Buscemi")
        expect(page).to have_content("Birthday")
      end #actor more info search

      scenario "actor more info page links movies to movie_more_info path" do
        api_search_for_movie_then_movie_more
        VCR.use_cassette("tmdb_actor_search") do
          click_link "Steve Buscemi"
        end
        VCR.use_cassette("tmdb_actor_more") do
          click_link "Get a full list of credits and bio"
        end
        VCR.use_cassette("actor_more_movie_link") do
          click_link "Fargo"
        end
        expect(current_url).to eq(movie_more_url(tmdb_id: 275))
      end #actor movie more

      scenario "actor more info page links tv shows to the tv show page" do
        api_search_for_movie_then_movie_more
        VCR.use_cassette("tmdb_actor_search") do
          click_link "Steve Buscemi"
        end
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
        api_search_for_movie_then_movie_more
        VCR.use_cassette("tmdb_actor_search") do
          click_link "Steve Buscemi"
        end
        VCR.use_cassette("tmdb_actor_more") do
          click_link "Get a full list of credits and bio"
        end
        VCR.use_cassette("actor_tv_credit") do
          click_link "more info", match: :first
        end
        expect(current_url).to eq(actor_credit_url(actor_id: 884, credit_id: "5256c32c19c2956ff601d1f7", show_name: "The Simpsons"))
        expect(page).to have_content("Episode overview")
        expect(page).to have_content("The Simpsons")
      end #actor tv credit

      scenario "tv credit page links to main show page" do
        api_search_for_movie_then_movie_more
        VCR.use_cassette("tmdb_actor_search") do
          click_link "Steve Buscemi"
        end
        VCR.use_cassette("tmdb_actor_more") do
          click_link "Get a full list of credits and bio"
        end
        VCR.use_cassette("actor_tv_credit") do
          click_link "more info", match: :first
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