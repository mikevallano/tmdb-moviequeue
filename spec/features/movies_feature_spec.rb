require 'rails_helper'

RSpec.feature "Movies feature spec", :type => :feature do

  feature "Movies views" do

    let(:email) { FFaker::Internet.email }
    let(:username) { FFaker::Internet.user_name }
    let(:user) { FactoryGirl.create(:user) }
    let(:list) { FactoryGirl.create(:list, owner_id: user.id) }
    let(:tag) { FactoryGirl.create(:tag, name: "hilarious") }

    scenario "users can add a movie to their list" do
      sign_up_api_search_then_add_movie_to_list
      expect(page).to have_content(Movie.last.title)
    end

    describe "movies index page paginates movies" do
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
      end #pagination
    end #pagination

    scenario "users can visit the movie show page, which has a slugged url" do
      sign_up_api_search_then_add_movie_to_list
      visit(movie_path(Movie.last))
      url = URI.parse(current_url)
      expect("#{url}").to include("#{Movie.last.slug}")
    end

    scenario "movie show page shows link to similar movies" do
      sign_up_api_search_then_add_movie_to_list
      visit(movie_path(Movie.last))
      expect(page).to have_selector("#similar_movies_link_movie_show")
      VCR.use_cassette('tmdb_movie_more') do
        click_link "similar_movies_link_movie_show"
      end
      VCR.use_cassette("similar_movies_more_info") do
        click_link "movie_more_link_movie_more_similar_movies", match: :first
      end
      expect(page).to have_content("The Revenant")
    end

    describe "tagging" do
      scenario "users can tag a movie from movies index page" do
        sign_up_api_search_then_add_movie_to_list
        click_link "my_movies_nav_link"
        fill_in "tag_list", with: "dark comedy, spooky"
        click_button "add_tags_button_movies_index", match: :first
        expect(page).to have_content("dark-comedy")
        expect(page).to have_content("spooky")
      end #user can tag movie

      scenario "users can click a tag (from movies index) to see movies with that tag" do
        sign_up_api_search_then_add_movie_to_list
        click_link "my_movies_nav_link"
        fill_in "tag_list", with: "dark comedy, spooky"
        click_button "add_tags_button_movies_index", match: :first
        click_link "spooky", match: :first
        expect(page).to have_content("Fargo")
      end #user can tag movie

      describe "paginate by tag" do
        it "should paginate the movies by tag" do
          sign_in_user(user)
          30.times { FactoryGirl.create(:movie) }
          counter = Movie.first.id
          30.times do
            FactoryGirl.create(:listing, list_id: list.id, movie_id: Movie.find(counter).id)
            counter += 1
          end
          counter = Movie.first.id
          30.times do
            FactoryGirl.create(:tagging, movie_id: Movie.find(counter).id, user_id: user.id, tag_id: tag.id)
            counter += 1
          end
          visit movies_path
          click_link "hilarious", match: :first
          expect(page).to have_content("Next")
          click_link "Next"
          expect(page).to have_content("Previous")
          expect(page).not_to have_link("Next")
        end
      end
    end #paginate by tag

    describe "genres" do
      scenario "genres are links that filter movies" do
        sign_up_api_search_then_add_movie_to_list
        visit(movie_path(Movie.last))
        click_link "Crime"
        expect(page).to have_content("Fargo")
      end #genres are links

      describe "movies index page paginates by genre" do
        it "should paginate the movies by genre" do
          sign_in_user(user)
          30.times do
            @movie = FactoryGirl.create(:movie)
            @movie.genres = ["Crime"]
            @movie.save
          end
          counter = Movie.first.id
          30.times do
            FactoryGirl.create(:listing, list_id: list.id, movie_id: Movie.find(counter).id)
            counter += 1
          end
          visit(movie_path(Movie.last))
          click_link "Crime", match: :first
          expect(page).to have_content("Next")
          click_link "Next"
          expect(page).to have_content("Previous")
          expect(page).not_to have_link("Next")
        end #paginate by genre
      end #pagination
    end #genres

  end #feature do

end #final