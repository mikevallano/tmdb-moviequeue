require 'rails_helper'

RSpec.feature "Movies feature spec", :type => :feature do

  feature "Movies views" do

    let(:email) { FFaker::Internet.email }
    let(:username) { FFaker::Internet.user_name }
    let(:user) { FactoryGirl.create(:user) }
    let(:user2) { FactoryGirl.create(:user) }
    let(:anne) { FactoryGirl.create(:user, username: "anne") }
    let(:list) { FactoryGirl.create(:list, owner_id: user.id) }
    let(:movie) { FactoryGirl.create(:movie, title: "Fargo", genres: ["Crime"]) }
    let(:movie2) { FactoryGirl.create(:movie) }
    let(:fargo) { FactoryGirl.create(:movie, title: "Fargo", runtime: 90,
      vote_average: 8, release_date: Date.today - 8000, tmdb_id: 275) }
    let(:no_country) { FactoryGirl.create(:movie, title: "No Country for Old Men", runtime: 100,
      vote_average: 9, release_date: Date.today - 6000) }
    let(:fargo_listing) { FactoryGirl.create(:listing, list_id: list.id, movie_id: fargo.id) }
    let(:listing) { FactoryGirl.create(:listing, list_id: list.id, movie_id: movie.id) }
    let(:list2) { FactoryGirl.create(:list, owner_id: user2.id) }
    let(:tag) { FactoryGirl.create(:tag, name: "hilarious") }
    let(:screening) { FactoryGirl.create(:screening, user_id: @current_user.id, movie_id: Movie.last.id) }
    let(:review) { FactoryGirl.create(:review, user_id: user.id, movie_id: movie.id, body: "it were awesome") }


    describe "movie show page functionality" do

      scenario "users can visit the movie show page, which has a slugged url" do
        sign_in_user(user)
        visit(movie_path(movie))
        url = URI.parse(current_url)
        expect("#{url}").to include("#{movie.slug}")
      end

      scenario "movie show page has genres that are links that filter movies" do
        sign_in_user(user)
        listing
        visit(movie_path(movie))
        click_link "Crime"
        expect(page).to have_selector("#modal_link_#{movie.tmdb_id}")
      end

      scenario "movie show page has the movie's poster image" do
        sign_in_user(user)
        listing
        visit(movie_path(movie))
        expect(page).to have_css("img[src*='http://image.tmdb.org/t/p/w185/aZeX4XNSqa08TdMHRB1gDLO6GOi.jpg']")
      end #genres are links

      scenario "movie show page does not have rating, reviews, or mark as watched unless it's on a list" do
        sign_in_user(user2)
        visit(movie_path(movie2))

        expect(page).not_to have_selector("#tag_link_movie_show")
        expect(page).not_to have_selector("#remove_tag_link_movie_show")
        expect(page).not_to have_selector("#add_tags_button_movie_show")
        expect(page).not_to have_selector("#list_show_link_on_list_movie_show")
        expect(page).not_to have_selector("#new_review_link_movie_show")
        expect(page).not_to have_selector("#rating_submit_button_rating_form")
        expect(page).not_to have_selector("#mark_watched_link_movie_show")
      end

      scenario "update movie button retrieves latest info from API" do
        sign_in_user(anne) #anne is an "admin"
        fargo
        visit(movie_path(fargo))
        expect(fargo.runtime).to eq(90)
        VCR.use_cassette('update_movie') do
          click_link("update_movie_link_movie_show")
        end
        expect(page).to have_content("98 min")
      end

      context "the movie on the show page is on one of the user's lists" do
        before(:each) do
          page.driver.browser.manage.window.resize_to(1280,800)
          sign_in_user(user)
          listing
        end

        scenario "users can add tags to a movie from the movie show page", js: true do
          visit(movie_path(movie))
          fill_in "tag_list", with: "dark comedy, spooky"
          click_button "add_tags_button_movies_partial"
          expect(page).to have_content("dark-comedy")
          expect(page).to have_content("spooky")
        end #user can tag movie

        scenario "user can remove tags from the movie show page", js: true do
          visit(movie_path(movie))
          fill_in "tag_list", with: "dark comedy"
          click_button "add_tags_button_movies_partial", match: :first
          expect(page).to have_content("dark-comedy")
          click_link "remove_tag_link_movies_partial"
          expect(page).not_to have_content("dark-comedy")
        end

        scenario "movie seen but not yet rated shows field to rate movie then link to rating after it's created", js: true do
          screening
          visit(movie_path(movie))
          expect(page).not_to have_selector("#show_rating_link_movies_partial")
          expect(page).to have_selector("#rating_submit_button_rating_form")
          select "5", :from => "rating[value]"
          click_button "rating_submit_button_rating_form"
          expect(page).to have_content("5")
          expect(page).to have_selector("#show_rating_link_movies_partial")
          expect(page).not_to have_selector("#new_rating_link_movie_show")
        end

        scenario "unwatched movie has a link to mark as watched", js: true do
          visit(movie_path(movie))
          expect(page).to have_selector("#mark_watched_link_movies_partial")
          expect(page).not_to have_selector("#add_screening_link_movies_partial")
          find "#mark_watched_link_movies_partial", match: :first
          click_link "mark_watched_link_movies_partial", match: :first #mark movie as watched
          wait_for_ajax
          expect(page).not_to have_selector("#mark_watched_link_movies_partial") #no link to mark as watched
          expect(page).to have_selector("#add_screening_link_movies_partial") #link to view screenings
        end

      end #movie is on a list

    end #movie show page

    describe "without js" do

      before(:each) do
        sign_in_user(user)
        listing
      end

      scenario "movie watched but not yet reviewed shows link to review the movie" do
        screening
        visit(movie_path(movie))
        expect(page).not_to have_selector("#show_review_link_movies_partial")
        expect(page).to have_selector("#new_review_link_movies_partial")
      end

      scenario "movie reviewed by user shows link to the review show path" do
        screening
        review
        visit(movie_path(movie))
        expect(page).to have_selector("#show_review_link_movies_partial")
        expect(page).not_to have_selector("#new_review_link_movies_partial")
      end
    end #without js

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
        before(:each) do
          listing
          page.driver.browser.manage.window.resize_to(1280,800)
          sign_in_user(user)
          visit(movies_path)
          find("#modal_link_#{movie.tmdb_id}")
        end

        scenario "users can tag a movie from movies index page", js: true do
          find("#modal_link_#{movie.tmdb_id}").click
          fill_in "tag_list", with: "dark comedy, spooky"
          click_button "add_tags_button_movies_partial"
          wait_for_ajax
          expect(page).to have_content("dark-comedy")
          expect(page).to have_content("spooky")
        end #user can tag movie

        scenario "user can click a tag to see movies with that tag", js: true do
          find("#modal_link_#{movie.tmdb_id}").click
          fill_in "tag_list", with: "dark comedy, spooky"
          click_button "add_tags_button_movies_partial"
          wait_for_ajax
          click_link "spooky"
          wait_for_ajax
          expect(page).to have_selector("#modal_link_#{movie.tmdb_id}")
        end

        scenario "user can remove tags", js: true do
          find("#modal_link_#{movie.tmdb_id}").click
          fill_in "tag_list", with: "dark comedy"
          click_button "add_tags_button_movies_partial", match: :first
          wait_for_ajax
          expect(page).to have_content("dark-comedy")
          find("#remove_tag_link_movies_partial").click
          wait_for_ajax
          expect(page).not_to have_content("dark-comedy")
        end

      end #tagging context

      context "pagingation" do

        scenario "movies index paginates the movies by tag" do
          sign_in_user(user)
          movie
          30.times { FactoryGirl.create(:movie) }
          counter = (Movie.first.id + 1)
          30.times do
            FactoryGirl.create(:listing, list_id: list.id, movie_id: counter)
            counter += 1
          end
          counter = Movie.first.id
          30.times do
            FactoryGirl.create(:tagging, movie_id: counter, user_id: user.id, tag_id: tag.id)
            counter += 1
          end
          # visit root_path
          # visit movies_path
          # @movie = Movie.first
          # find("#modal_link_#{@movie.tmdb_id}")
          # find("#modal_link_#{@movie.tmdb_id}").click
          # click_link "hilarious"
          visit('/tags/hilarious')
          find(".pagination", match: :first)
          click_link "Next"
          find(".pagination", match: :first)
          expect(page).to have_content("Previous")
          expect(page).not_to have_link("Next")
        end

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

      end #pagination context

      context "rating, reviews, marking watched" do
        before(:each) do
          listing
          page.driver.browser.manage.window.resize_to(1280,800)
          sign_in_user(user)
          visit(movies_path)
          find("#modal_link_#{movie.tmdb_id}")
        end

        scenario "movie not yet watched doesn't show field to rate movie", js: true do
          find("#modal_link_#{movie.tmdb_id}").click
          expect(page).not_to have_selector("#show_rating_link_movies_partial")
          expect(page).not_to have_selector("#rating_submit_button_rating_form")
        end

        scenario "movie that has been watched shows field to rate movie", js: true do
          FactoryGirl.create(:screening, user_id: @current_user.id, movie_id: @current_user.movies.last.id)
          find("#modal_link_#{movie.tmdb_id}").click
          expect(page).not_to have_selector("#show_rating_link_movies_partial")
          expect(page).to have_selector("#rating_submit_button_rating_form")
          select "5", :from => "rating[value]", match: :first
          click_button "rating_submit_button_rating_form", match: :first
          expect(page).to have_content("5")
        end

        scenario "movie rated by user shows link to the rating show path", js: true do
          FactoryGirl.create(:screening, user_id: @current_user.id, movie_id: @current_user.movies.last.id)
          FactoryGirl.create(:rating, user_id: @current_user.id, movie_id: @current_user.movies.last.id, value: 5)
          find("#modal_link_#{movie.tmdb_id}").click
          expect(page).to have_selector("#show_rating_link_movies_partial")
          expect(page).not_to have_selector("#new_rating_link_movies_partial")
        end

        scenario "movie watched but not yet reviewed shows link to review the movie", js: true do
          FactoryGirl.create(:screening, user_id: @current_user.id, movie_id: @current_user.movies.last.id)
          find("#modal_link_#{movie.tmdb_id}").click
          expect(page).not_to have_selector("#show_review_link_movies_partial")
          expect(page).to have_selector("#new_review_link_movies_partial")
        end

        scenario "movie reviewed by user shows link to the rating show path", js: true do
          FactoryGirl.create(:screening, user_id: @current_user.id, movie_id: @current_user.movies.last.id)
          FactoryGirl.create(:review, user_id: @current_user.id, movie_id: @current_user.movies.last.id)
          find("#modal_link_#{movie.tmdb_id}").click
          expect(page).to have_selector("#show_review_link_movies_partial")
          expect(page).not_to have_selector("#new_review_link_movies_partial")
        end

        scenario "link to mark as watched if not watched, link marks as watched", js: true do
          find("#modal_link_#{movie.tmdb_id}").click
          expect(page).not_to have_selector("#add_screening_link_movies_partial")
          click_link "mark_watched_link_movies_partial", match: :first
          expect(page).not_to have_selector("#show_review_link_movies_partial") #no link to mark as watched
          expect(page).to have_selector("#add_screening_link_movies_partial") #link to view screenings
        end

        scenario "if the movie has been watched, there is no link to mark as watched", js: true do
          FactoryGirl.create(:screening, user_id: @current_user.id, movie_id: @current_user.movies.last.id)
          find("#modal_link_#{movie.tmdb_id}").click
          expect(page).not_to have_selector("#mark_watched_link_movies_partial")
          expect(page).to have_selector("#add_screening_link_movies_partial")
        end

      end #rating, reviews, marking watched

      context "sorting" do
        before(:each) do
          sign_in_user(user)
          fargo_listing
          user.watched_movies << no_country
          visit(movies_path)
        end #before context

        scenario "sort by title" do
          select "title", :from => "sort_by"
          click_button "sort_button_movies_index"
          expect(page.body.index("modal_link_#{fargo.tmdb_id}")).to be < page.body.index("modal_link_#{no_country.tmdb_id}")
        end

        scenario "sort by shortest runtime" do
          select "shortest runtime", :from => "sort_by"
          click_button "sort_button_movies_index"
          expect(page.body.index("modal_link_#{fargo.tmdb_id}")).to be < page.body.index("modal_link_#{no_country.tmdb_id}")
        end

        scenario "sort by longest runtime" do
          select "longest runtime", :from => "sort_by"
          click_button "sort_button_movies_index"
          expect(page.body.index("modal_link_#{no_country.tmdb_id}")).to be < page.body.index("modal_link_#{fargo.tmdb_id}")
        end

        scenario "sort by newest release" do
          select "newest release", :from => "sort_by"
          click_button "sort_button_movies_index"
          expect(page.body.index("modal_link_#{no_country.tmdb_id}")).to be < page.body.index("modal_link_#{fargo.tmdb_id}")
        end

        scenario "sort by vote average" do
          select "vote average", :from => "sort_by"
          click_button "sort_button_movies_index"
          expect(page.body.index("modal_link_#{no_country.tmdb_id}")).to be < page.body.index("modal_link_#{fargo.tmdb_id}")
        end

        scenario "sort by watched movies" do
          select "watched movies", :from => "sort_by"
          click_button "sort_button_movies_index"
          expect(page.body.index("modal_link_#{no_country.tmdb_id}")).to be < page.body.index("modal_link_#{fargo.tmdb_id}")
        end

        scenario "sort by unwatched movies" do
          select "unwatched movies", :from => "sort_by"
          click_button "sort_button_movies_index"
          expect(page.body.index("modal_link_#{fargo.tmdb_id}")).to be < page.body.index("modal_link_#{no_country.tmdb_id}")
        end

        scenario "sort by only show unwatched" do
          select "only show unwatched", :from => "sort_by"
          click_button "sort_button_movies_index"
          expect(page).not_to have_selector("#modal_link_#{no_country.tmdb_id}")
          expect(page).to have_selector("#modal_link_#{fargo.tmdb_id}")
        end

        scenario "sort by only show watched" do
          select "only show watched", :from => "sort_by"
          click_button "sort_button_movies_index"
          expect(page).to have_selector("#modal_link_#{no_country.tmdb_id}")
          expect(page).not_to have_selector("#modal_link_#{fargo.tmdb_id}")
        end

        scenario "sort by not on a list" do
          select "movies not on a list", :from => "sort_by"
          click_button "sort_button_movies_index"
          expect(page).not_to have_selector("#modal_link_#{fargo.tmdb_id}")
          expect(page).to have_selector("#modal_link_#{no_country.tmdb_id}")
        end

        scenario "sort by recently watched" do
          select "recently watched", :from => "sort_by"
          click_button "sort_button_movies_index"
          expect(page).to have_selector("#modal_link_#{no_country.tmdb_id}")
          expect(page).not_to have_selector("#modal_link_#{fargo.tmdb_id}")
        end #sort by title


      end #sorting context

    end # index page functionality

  end #feature do

end #final
