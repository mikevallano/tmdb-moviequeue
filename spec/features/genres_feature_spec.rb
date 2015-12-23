require 'rails_helper'

RSpec.feature "Genres feature spec", :type => :feature do

  feature "Genres are displayed and link to users' movies with that genre" do

    let(:user) { FactoryGirl.create(:user) }
    let(:email) { FFaker::Internet.email }
    let(:username) { FFaker::Internet.user_name }

    context "with signed in user" do

      scenario "movies have genres on the more info page" do

        sign_up_with(email, username, "password")
        visit(api_search_path)
        api_search_for_movie
        api_more_info
        expect(page).to have_content("Crime")

      end #movies have genres

      scenario "genres are links that filter movies" do

        sign_up_with(email, username, "password")
        visit(api_search_path)
        api_search_for_movie
        api_more_info
        all('#new_listing option')[0].select_option
        VCR.use_cassette('tmdb_add_movie') do
          click_button("add movie to list")
        end
        visit(movie_path(Movie.last))
        click_link("Crime")
        expect(page).to have_content("Fargo")

      end #genres are links

    end #signed in user context

  end

end #final