require 'rails_helper'

RSpec.feature "Actors feature spec", :type => :feature do

  feature "Actors are displayed and link to actor search" do

    let(:user) { FactoryGirl.create(:user) }
    let(:email) { FFaker::Internet.email }
    let(:username) { FFaker::Internet.user_name }

    context "with signed in user" do

      scenario "movies have actors on the more info page" do

        sign_up_with(email, username, "password")
        visit(api_search_path)
        api_search_for_movie
        api_more_info
        expect(page).to have_content("Steve Buscemi")

      end #movies have actors

      scenario "movie show page shows actors, which links to actor search" do

        sign_up_with(email, username, "password")
        visit(api_search_path)
        api_search_for_movie
        api_more_info
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

    end #signed in user context

  end

end #final