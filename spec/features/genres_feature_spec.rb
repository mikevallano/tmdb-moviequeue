require 'rails_helper'

RSpec.feature "Genres feature spec", :type => :feature do

  feature "Genres are displayed and link to users' movies with that genre" do

    let(:user) { FactoryGirl.create(:user) }
    let(:email) { FFaker::Internet.email }
    let(:username) { FFaker::Internet.user_name }
    let(:list) { FactoryGirl.create(:list, owner_id: user.id) }

    context "with signed in user" do

      scenario "movies have genres on the more info page" do

        sign_up_with(email, username, "password")
        visit(api_search_path)
        api_search_for_movie
        api_movie_more_info
        expect(page).to have_content("Crime")

      end #movies have genres

      scenario "genres are links that filter movies" do

        sign_up_with(email, username, "password")
        visit(api_search_path)
        api_search_for_movie
        api_movie_more_info
        all('#new_listing option')[0].select_option
        VCR.use_cassette('tmdb_add_movie') do
          click_button("add movie to list")
        end
        visit(movie_path(Movie.last))
        click_link("Crime")
        expect(page).to have_content("Fargo")

      end #genres are links

      describe "pagination" do
        it "should paginate the movies by tag" do
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
          click_link("Crime", match: :first)
          expect(page).to have_content("Next")
          click_link("Next")
          expect(page).to have_content("Previous")
          expect(page).not_to have_link("Next")
        end
      end

    end #signed in user context

  end

end #final