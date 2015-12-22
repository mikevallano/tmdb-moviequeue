require 'rails_helper'

RSpec.feature "Movies feature spec", :type => :feature do

  feature "User can add a movie to their list and visit the movie show page" do

    let(:email) { FFaker::Internet.email }
    let(:username) { FFaker::Internet.user_name }
    let(:user) { FactoryGirl.create(:user) }

    scenario "users can add a movie to their list" do

      sign_up_with(email, username, "password")
      visit(api_search_path)
      api_search_for_movie

      api_more_info

      all('#new_listing option')[0].select_option
      VCR.use_cassette('tmdb_add_movie') do
        click_button("add movie to list")
      end
      expect(page).to have_content("added to your list")

    end

    scenario "users can visit the movie show page, which has a slugged url" do

      sign_up_with(email, username, "password")
      visit(api_search_path)
      api_search_for_movie

      api_more_info

      all('#new_listing option')[0].select_option
      VCR.use_cassette('tmdb_add_movie') do
        click_button("add movie to list")
      end
      visit(movie_path(Movie.last))
      url = URI.parse(current_url)
      expect("#{url}").to include("#{Movie.last.slug}")

    end

  end

end