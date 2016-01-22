require 'rails_helper'

RSpec.feature "Movies feature spec", :type => :feature do

  feature "Movies views" do

    let(:email) { FFaker::Internet.email }
    let(:username) { FFaker::Internet.user_name }
    let(:user) { FactoryGirl.create(:user) }
    let(:user2) { FactoryGirl.create(:user) }
    let(:list) { FactoryGirl.create(:list, owner_id: user.id) }
    let(:list2) { FactoryGirl.create(:list, owner_id: user2.id) }
    let(:tag) { FactoryGirl.create(:tag, name: "hilarious") }

    scenario "users can add a movie to their list" do
      sign_up_api_search_then_add_movie_to_list
      expect(page).to have_content(Movie.last.title)
    end

    describe "movie show page functionality" do

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
        VCR.use_cassette("tmdb_movie_more_info") do
          click_link "similar_movies_link_movie_show"
        end
        VCR.use_cassette("similar_movies_more_info") do
          click_link "movie_more_link_movie_partial", match: :first
        end
        expect(page).to have_content("The Revenant")
      end

      scenario "movie show page has genres that are links that filter movies" do
        sign_up_api_search_then_add_movie_to_list
        visit(movie_path(Movie.last))
        click_link "Crime"
        expect(page).to have_content("Fargo")
      end #genres are links

      scenario "movie show page does not have rating, reviews, or mark as watched unless it's on a list" do
        sign_up_api_search_then_add_movie_to_list
        click_link "sign_out_nav_link"

        sign_in_user(user2)
        list2
        visit(movie_path(Movie.last))

        expect(page).not_to have_selector("#tag_link_movie_show")
        expect(page).not_to have_selector("#remove_tag_link_movie_show")
        expect(page).not_to have_selector("#add_tags_button_movie_show")
        expect(page).not_to have_selector("#list_show_link_on_list_movie_show")
        expect(page).not_to have_selector("#new_review_link_movie_show")
        expect(page).not_to have_selector("#rating_submit_button_rating_form")
        expect(page).not_to have_selector("#mark_watched_link_movie_show")
      end #does not show links if not on a list

      context "the movie on the show page is one of the user's lists" do
        before(:each) do
          sign_up_api_search_then_add_movie_to_list
        end

        scenario "users can add tags to a movie from the movie show page and are returned to the movie show page" do
          visit(movie_path(Movie.last))
          fill_in "tag_list", with: "dark comedy, spooky"
          click_button "add_tags_button_movie_show", match: :first
          expect(current_url).to eq(movie_url(Movie.last))
          expect(page).to have_content("dark-comedy")
          expect(page).to have_content("spooky")
        end #user can tag movie

        scenario "user can click a tag to see movies with that tag" do
          visit(movie_path(Movie.last))
          fill_in "tag_list", with: "dark comedy, spooky"
          click_button "add_tags_button_movie_show", match: :first
          visit(movie_path(Movie.last))
          click_link "spooky", match: :first
          expect(page).to have_content("Fargo")
        end

        scenario "user can remove tags and are returned to the movie show page" do
          visit(movie_path(Movie.last))
          fill_in "tag_list", with: "dark comedy, spooky"
          click_button "add_tags_button_movie_show", match: :first
          expect(current_url).to eq(movie_url(Movie.last))
          expect { click_link "remove_tag_link_movie_show", match: :first }.to change(Tagging.by_user(@current_user), :count).by(-1)
          click_link "remove_tag_link_movie_show", match: :first
          expect(current_url).to eq(movie_url(Movie.last))
        end

        scenario "movie not yet rated shows field to rate movie, and returns user back after review is submitted" do
          visit(movie_path(Movie.last))
          expect(page).not_to have_selector("#show_rating_link_movie_show")
          expect(page).to have_selector("#rating_submit_button_rating_form")
          select "5", :from => "rating[value]"
          click_button "rating_submit_button_rating_form"
          expect(page).to have_content("5")
          expect(current_url).to eq(movie_url(Movie.last))
        end

        scenario "movie rated by user shows link to the rating show path" do
          FactoryGirl.create(:rating, user_id: @current_user.id, movie_id: @current_user.movies.last.id, value: 5)
          visit(movie_path(Movie.last))
          expect(page).to have_selector("#show_rating_link_movie_show")
          expect(page).not_to have_selector("#new_rating_link_movie_show")
        end

        scenario "movie not yet reviewed shows link to review the movie" do
          visit(movie_path(Movie.last))
          expect(page).not_to have_selector("#show_review_link_movie_show")
          expect(page).to have_selector("#new_review_link_movie_show")
        end

        scenario "movie reviewed by user shows link to the rating show path" do
          FactoryGirl.create(:review, user_id: @current_user.id, movie_id: @current_user.movies.last.id)
          visit(movie_path(Movie.last))
          expect(page).to have_selector("#show_review_link_movie_show")
          expect(page).not_to have_selector("#new_review_link_movie_show")
        end

        scenario "if user has not watched the movie, there is a link to mark as watched" do
          visit(movie_path(Movie.last))
          expect(page).to have_selector("#mark_watched_link_movie_show")
          expect(page).not_to have_selector("#view_screenings_link_movie_show")
          click_link("mark_watched_link_movie_show") #mark movie as watched
          expect(current_url).to eq(movie_url(Movie.last)) #return to movie show page
          expect(page).not_to have_selector("#mark_watched_link_movie_show") #no link to mark as watched
          expect(page).to have_selector("#view_screenings_link_movie_show") #link to view screenings
        end

        scenario "if the movie has been watched, there is no link to mark as watched" do
          FactoryGirl.create(:screening, user_id: @current_user.id, movie_id: @current_user.movies.last.id)
          visit(movie_path(Movie.last))
          expect(page).not_to have_selector("#mark_watched_link_movie_show")
          expect(page).to have_selector("#view_screenings_link_movie_show")
        end

      end #movie is on a list

    end #movie show page

    describe "movies index functionality" do

      scenario "movies are paginated on the movies index page" do
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

      context "tagging" do
        scenario "users can tag a movie from movies index page" do
          sign_up_api_search_then_add_movie_to_list
          click_link "my_movies_nav_link"
          fill_in "tag_list", with: "dark comedy, spooky"
          click_button "add_tags_button_movies_partial", match: :first
          expect(page).to have_content("dark-comedy")
          expect(page).to have_content("spooky")
        end #user can tag movie

        scenario "users are returned to the movies index after tag is added" do
          sign_up_api_search_then_add_movie_to_list
          click_link "my_movies_nav_link"
          fill_in "tag_list", with: "dark comedy, spooky"
          click_button "add_tags_button_movies_partial", match: :first
          expect(current_url).to eq(movies_url)
        end #user can tag movie

        scenario "users are returned to the paginated page after a tag is added" do
          sign_in_user(user)
          30.times { FactoryGirl.create(:movie) }
          counter = Movie.first.id
          30.times do
            FactoryGirl.create(:listing, list_id: list.id, movie_id: Movie.find(counter).id)
            counter += 1
          end
          click_link "my_movies_nav_link"
          click_link "Next"
          fill_in "tag_list", match: :first, with: "dark comedy, spooky"
          click_button "add_tags_button_movies_partial", match: :first
          expect(page).to have_content("dark-comedy")
          expect(page).to have_content("spooky")
        end

        scenario "users can click a tag (from movies index) to see movies with that tag" do
          sign_up_api_search_then_add_movie_to_list
          click_link "my_movies_nav_link"
          fill_in "tag_list", with: "dark comedy, spooky"
          click_button "add_tags_button_movies_partial", match: :first
          click_link "spooky", match: :first
          expect(page).to have_content("Fargo")
        end #user can tag movie

        scenario "user can remove tags and are returned to the movies index" do
          sign_up_api_search_then_add_movie_to_list
          click_link "my_movies_nav_link"
          fill_in "tag_list", with: "dark comedy, spooky"
          click_button "add_tags_button_movies_partial", match: :first
          click_link "my_movies_nav_link"
          expect { click_link "remove_tag_link_movies_partial", match: :first }.to change(Tagging.by_user(@current_user), :count).by(-1)
          click_link "remove_tag_link_movies_partial"
          expect(current_url).to eq(movies_url)
        end

        scenario "movies index paginates the movies by tag" do
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

      end #tagging context

      scenario "movies index paginates the movies by genre" do
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

      context "rating, reviews, marking watched" do
        before(:each) do
          sign_up_api_search_then_add_movie_to_list
        end

        scenario "movie not yet rated shows field to rate movie, and returns to movies index after submit" do
          click_link "my_movies_nav_link"
          expect(page).not_to have_selector("#show_rating_link_movies_partial")
          expect(page).to have_selector("#rating_submit_button_rating_form")
          select "5", :from => "rating[value]"
          click_button "rating_submit_button_rating_form"
          expect(page).to have_content("5")
          expect(current_url).to eq(movies_url)
        end

        scenario "movie rated by user shows link to the rating show path" do
          FactoryGirl.create(:rating, user_id: @current_user.id, movie_id: @current_user.movies.last.id, value: 5)
          click_link "my_movies_nav_link"
          expect(page).to have_selector("#show_rating_link_movies_partial")
          expect(page).not_to have_selector("#new_rating_link_movies_partial")
        end

        scenario "movie not yet reviewed shows link to review the movie" do
          click_link "my_movies_nav_link"
          expect(page).not_to have_selector("#show_review_link_movies_partial")
          expect(page).to have_selector("#new_review_link_movies_partial")
        end

        scenario "movie reviewed by user shows link to the rating show path" do
          FactoryGirl.create(:review, user_id: @current_user.id, movie_id: @current_user.movies.last.id)
          click_link "my_movies_nav_link"
          expect(page).to have_selector("#show_review_link_movies_partial")
          expect(page).not_to have_selector("#new_review_link_movies_partial")
        end

        scenario "link to mark as watched if not watched, link marks as watched and returns user" do
          click_link "my_movies_nav_link"
          expect(page).not_to have_selector("#view_screenings_link_movies_partial")
          click_link("mark_watched_link_movies_partial") #mark movie as watched
          expect(current_url).to eq(movies_url) #return to movies index page
          expect(page).not_to have_selector("#show_review_link_movies_partial") #no link to mark as watched
          expect(page).to have_selector("#view_screenings_link_movies_partial") #link to view screenings
        end

        scenario "if the movie has been watched, there is no link to mark as watched" do
          FactoryGirl.create(:screening, user_id: @current_user.id, movie_id: @current_user.movies.last.id)
          click_link "my_movies_nav_link"
          expect(page).not_to have_selector("#mark_watched_link_movies_partial")
          expect(page).to have_selector("#view_screenings_link_movies_partial")
        end

      end #rating, reviews, marking watched

    end # index page functionality

  end #feature do

end #final