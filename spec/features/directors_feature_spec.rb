require 'rails_helper'

RSpec.feature "Directors feature spec", :type => :feature do

  feature "Directors are displayed and link to director search" do

    let(:user) { FactoryGirl.create(:user) }
    let(:email) { FFaker::Internet.email }
    let(:username) { FFaker::Internet.user_name }

    context "with signed in user" do

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

    end #signed in user context

  end

end #final