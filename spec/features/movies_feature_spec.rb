require 'rails_helper'

RSpec.feature "Movies feature spec", :type => :feature do

  feature "User can add a movie to their list and visit the movie show page" do

    let(:email) { FFaker::Internet.email }
    let(:username) { FFaker::Internet.user_name }
    let(:user) { FactoryGirl.create(:user) }
    let(:list) { FactoryGirl.create(:list, owner_id: user.id) }

    scenario "users can add a movie to their list" do

      sign_up_with(email, username, "password")
      visit(api_search_path)
      api_search_for_movie

      api_movie_more_info

      all('#new_listing option')[0].select_option
      VCR.use_cassette('tmdb_add_movie') do
        click_button "add movie to list"
      end
      expect(page).to have_content("added to your list")

    end

    describe "pagination" do
      it "should paginate the movies" do
        sign_in_user(user)
        30.times { FactoryGirl.create(:movie) }
        counter = Movie.first.id
        30.times do
          FactoryGirl.create(:listing, list_id: list.id, movie_id: Movie.find(counter).id)
          counter += 1
        end
        visit movies_path
        expect(page).to have_content("Next")
        click_link "Next"
        expect(page).to have_content("Previous")
        expect(page).not_to have_link("Next")
      end
      Movie.destroy_all
    end

    scenario "users can visit the movie show page, which has a slugged url" do

      sign_up_with(email, username, "password")
      visit(api_search_path)
      api_search_for_movie

      api_movie_more_info

      all('#new_listing option')[0].select_option
      VCR.use_cassette('tmdb_add_movie') do
        click_button "add movie to list"
      end
      VCR.use_cassette('movie_show_page') do
        visit(movie_path(Movie.last))
      end
      url = URI.parse(current_url)
      expect("#{url}").to include("#{Movie.last.slug}")

    end

    scenario "movie show page shows link to similar movies" do

      sign_up_with(email, username, "password")
      visit(api_search_path)
      api_search_for_movie

      api_movie_more_info

      all('#new_listing option')[0].select_option
      VCR.use_cassette('tmdb_add_movie') do
        click_button "add movie to list"
      end
      VCR.use_cassette('movie_show_page') do
        visit(movie_path(Movie.last))
      end
      expect(page).to have_content("Similar movies")
      VCR.use_cassette('tmdb_movie_more') do
        click_link "Similar movies"
      end
      VCR.use_cassette("similar_movies_more_info") do
        click_link "More info", match: :first
      end
      expect(page).to have_content("The Revenant")

    end

  end

end