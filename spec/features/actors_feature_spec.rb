require 'rails_helper'

RSpec.feature "Actors feature spec", :type => :feature do

  feature "Actors are displayed and link to actor search" do

    let(:user) { FactoryGirl.create(:user) }
    let(:email) { FFaker::Internet.email }
    let(:username) { FFaker::Internet.user_name }


    scenario "movies have actors on the more info page" do

      sign_up_with(email, username, "password")
      visit(api_search_path)
      api_search_for_movie
      api_movie_more_info
      expect(page).to have_content("Steve Buscemi")

    end #movies have actors

    scenario "movie show page shows actors, which links to actor search" do

      sign_up_with(email, username, "password")
      visit(api_search_path)
      api_search_for_movie
      api_movie_more_info
      all('#new_listing option')[0].select_option
      VCR.use_cassette('tmdb_add_movie') do
        click_button("add movie to list")
      end
      visit(movie_path(Movie.last))
      VCR.use_cassette('tmdb_actor_search') do
        click_link("Steve Buscemi")
      end
      expect(page).to have_content("Fargo")

    end #actors are links

    scenario 'actor search page links to actor more info search' do
      sign_up_with(email, username, "password")
      visit(api_search_path)
      api_search_for_movie
      api_movie_more_info
      VCR.use_cassette('tmdb_actor_search') do
        click_link("Steve Buscemi")
      end
      VCR.use_cassette('tmdb_actor_more') do
        click_link("Get a full list of credits and bio")
      end
      expect(page).to have_content("Steve Buscemi")
      expect(page).to have_content("Birthday")

    end #actor more info search

    scenario 'actor more info page links movies to movie_more_info path' do
      sign_up_with(email, username, "password")
      visit(api_search_path)
      api_search_for_movie
      api_movie_more_info
      VCR.use_cassette('tmdb_actor_search') do
        click_link("Steve Buscemi")
      end
      VCR.use_cassette('tmdb_actor_more') do
        click_link("Get a full list of credits and bio")
      end
      VCR.use_cassette('actor_more_movie_link') do
        click_link("Fargo")
      end
      expect(current_url).to eq(movie_more_url(movie_id: 275))

    end #actor movie more

    scenario 'actor more info page links tv shows to the tv show page' do
      sign_up_with(email, username, "password")
      visit(api_search_path)
      api_search_for_movie
      api_movie_more_info
      VCR.use_cassette('tmdb_actor_search') do
        click_link("Steve Buscemi")
      end
      VCR.use_cassette('tmdb_actor_more') do
        click_link("Get a full list of credits and bio")
      end
      VCR.use_cassette('actor_tv_more') do
        click_link("The Simpsons")
      end
      expect(current_url).to eq(tv_more_url(actor_id: 884, show_id: 456))
      expect(page).to have_content("The Simpsons")

    end #actor tv more

    scenario 'actor more info page links tv credits to credit url' do
      sign_up_with(email, username, "password")
      visit(api_search_path)
      api_search_for_movie
      api_movie_more_info
      VCR.use_cassette('tmdb_actor_search') do
        click_link("Steve Buscemi")
      end
      VCR.use_cassette('tmdb_actor_more') do
        click_link("Get a full list of credits and bio")
      end
      VCR.use_cassette('actor_tv_credit') do
        click_link("more info", match: :first)
      end
      expect(current_url).to eq(actor_credit_url(actor_id: 884, credit_id: "5256c32c19c2956ff601d1f7", show_name: "The Simpsons"))
      expect(page).to have_content("Episode overview")
      expect(page).to have_content("The Simpsons")

    end #actor tv credit

    scenario 'tv credit page links to main show page' do
      sign_up_with(email, username, "password")
      visit(api_search_path)
      api_search_for_movie
      api_movie_more_info
      VCR.use_cassette('tmdb_actor_search') do
        click_link("Steve Buscemi")
      end
      VCR.use_cassette('tmdb_actor_more') do
        click_link("Get a full list of credits and bio")
      end
      VCR.use_cassette('actor_tv_credit') do
        click_link("more info", match: :first)
      end
      VCR.use_cassette('tv_main_page') do
        click_link("The Simpsons")
      end
      expect(page).to have_content("The Simpsons")
      expect(current_url).to eq(tv_more_url(show_id: 456))

    end #actor tv main page

  end

end #final