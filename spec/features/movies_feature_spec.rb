require 'rails_helper'

RSpec.feature "Movies feature spec", type: :feature, feature: :true do
  feature "Movies views" do
    let(:email) { FFaker::Internet.email }
    let(:username) { FFaker::Internet.user_name }
    let(:user) { create(:user) }
    let(:user2) { create(:user) }
    let(:admin_user) { create(:user, admin: true) }
    let(:list) { create(:list, owner_id: user.id) }
    let(:movie) { create(:movie, title: "Fargo", genres: ["Crime"]) }
    let(:movie2) { create(:movie) }
    let(:fargo) { create(:movie, title: "Fargo", runtime: 90,
      vote_average: 8, release_date: Date.today - 8000, tmdb_id: 275) }
    let(:no_country) { create(:movie, title: "No Country for Old Men", runtime: 100,
      vote_average: 9, release_date: Date.today - 6000) }
    let(:fargo_listing) { create(:listing, list_id: list.id, movie_id: fargo.id) }
    let(:listing) { create(:listing, list_id: list.id, movie_id: movie.id) }
    let(:list2) { create(:list, owner_id: user2.id) }
    let(:tag) { create(:tag, name: "hilarious") }
    let(:screening) { create(:screening, user_id: @current_user.id, movie_id: Movie.last.id) }
    let(:review) { create(:review, user_id: user.id, movie_id: movie.id, body: "it were awesome") }
    let(:fake_provider) {
      provider = OpenStruct.new(display_name: "FakeFlix")
      provider.define_singleton_method(:title_search_url) { |title| "http://www.fakeflix.com/search/#{title}" }
      provider
    }
    let(:streaming_service_providers) {
      OpenStruct.new(
        free: [fake_provider],
        rent: [],
        buy: [],
        not_found: []
      )
    }

    describe 'move show page' do
      before do
        allow(UserStreamingServiceProviderDataService)
          .to receive(:check_availability_for_title)
          .and_return(streaming_service_providers)
      end

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
          expect(page).to have_selector(:xpath, "//*[@id='#{movie.tmdb_id}']")
        end

        scenario "clicking director name goes to director results" do
          sign_in_user(user)
          movie = create(:movie_in_tmdb)
          visit(movie_path(movie))
          click_link "#{movie.director} (director)"
          expect(page).to have_content(movie.director)
        end

        scenario "movie show page has the movie's poster image" do
          sign_in_user(user)
          listing
          visit(movie_path(movie))
          expect(page).to have_css("img[src*='https://image.tmdb.org/t/p/w185#{movie.poster_path}']")
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

        scenario 'update the movie trailer', js: true do
          youtube_id = '73829hsuhf'
          sign_in_user(admin_user)
          movie.update(trailer: nil) # Clear existing trailer
          visit(movie_path(movie))
          trailer_field = find_field('trailer')
          trailer_field.fill_in(with: "https://www.youtube.com/watch?v=#{youtube_id}")
          trailer_field.send_keys(:return)
          expect(page).to have_css("iframe[src*='#{youtube_id}']")
          expect(movie.reload.trailer).to eq(youtube_id)
        end

        scenario 'non-admin should not see trailer field' do
          sign_in_user(user)
          visit(movie_path(movie))
          expect(page).not_to have_field('trailer')
        end

        context "the movie on the show page is on one of the user's lists" do
          before(:each) do
            page.driver.browser.manage.window.resize_to(1280,800)
            sign_in_user(user)
            listing
          end

          scenario "users can add tags to a movie from the movie show page", js: true do
            visit(movie_path(movie))
            tag_field = find_field("tag_list")
            tag_field.fill_in(with: "dark comedy, spooky")
            tag_field.send_keys(:return)
            # Wait for Turbo to add the tags by finding the first one
            find("a", text: /dark-comedy/i)
            expect(page).to have_content("dark-comedy")
            expect(page).to have_content("spooky")
          end #user can tag movie

          scenario "user can remove tags from the movie show page", js: true do
            visit(movie_path(movie))
            tag_field = find_field("tag_list")
            tag_field.fill_in(with: "dark comedy")
            tag_field.send_keys(:return)
            # Wait for Turbo to add the tag
            find("a", text: /dark-comedy/i, wait: 5)
            expect(page).to have_content("dark-comedy")
            first("button.fa-times-circle").click
            # Wait for Turbo to remove the tag - input field should be empty or tag gone
            expect(page).not_to have_content("dark-comedy")
          end

          scenario "movie seen but not yet rated shows field to rate movie then shows rating after created", js: true do
            screening
            visit(movie_path(movie))
            expect(page).to have_selector("#rating_value")
            select "5", :from => "rating[value]"
            # Wait for Turbo to replace the rating div with the unique ID
            find("#movie_rating_#{movie.tmdb_id}")
            expect(page).to have_content(/your enjoyment:/i)
            expect(page).to have_content("5/10")
          end

          scenario "unwatched movie has a button to mark as watched", js: true do
            visit(movie_path(movie))
            expect(page).to have_button("mark_watched_link_movies_partial")
            click_button "mark_watched_link_movies_partial", match: :first
            # Wait for Turbo to update the DOM by finding the new element
            find("#add_screening_link_movies_partial")
            expect(page).not_to have_button("mark_watched_link_movies_partial")
          end

        end #movie is on a list

        scenario "the user can see streaming service options" do
          sign_in_user(user)
          visit(movie_path(movie))
          expect(page).to have_content("FakeFlix")
        end
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
          30.times { create(:movie) }
          counter = Movie.first.id
          30.times do
            create(:listing, list_id: list.id, movie_id: Movie.find(counter).id)
            counter += 1
          end
          visit movies_path
          expect(page).to have_content("Next")
          click_link "Next"
          expect(page).to have_content("Previous")
          expect(page).not_to have_link("Next")
        end #pagination

        context "pagination" do
          scenario "movies index paginates the movies by tag" do
            sign_in_user(user)
            movie
            30.times { create(:movie) }
            counter = (Movie.first.id + 1)
            30.times do
              create(:listing, list_id: list.id, movie_id: counter)
              counter += 1
            end
            counter = Movie.first.id
            30.times do
              create(:tagging, movie_id: counter, user_id: user.id, tag_id: tag.id)
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
              @movie = create(:movie)
              @movie.genres = ["Crime"]
              @movie.save
            end
            counter = Movie.first.id
            30.times do
              create(:listing, list_id: list.id, movie_id: Movie.find(counter).id)
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
          end

          scenario "movie not yet watched doesn't show field to rate movie", js: true do
            open_movie_modal(movie)
            expect(page).not_to have_selector("#rating_value")
          end

          scenario "movie that has been watched shows field to rate movie", js: true do
            create(:screening, user_id: @current_user.id, movie_id: @current_user.movies.last.id)
            open_movie_modal(movie)
            expect(page).to have_selector("#rating_value")
            select "5", from: "rating[value]"
            expect(page).to have_content(/your enjoyment:\s*5\/10/i)
            expect(Rating.last.value).to eq(5)
          end

          scenario "movie rated by user shows their rating", js: true do
            create(:screening, user_id: @current_user.id, movie_id: @current_user.movies.last.id)
            create(:rating, user_id: @current_user.id, movie_id: @current_user.movies.last.id, value: 5)
            open_movie_modal(movie)
            expect(page).to have_content(/your enjoyment:\s*5\/10/i)
            expect(page).to have_link("Edit")
          end

          scenario "movie watched but not yet reviewed shows link to review on show page", js: true do
            create(:screening, user_id: @current_user.id, movie_id: @current_user.movies.last.id)
            # Reviews are only accessible from movie show page, not modal
            visit(movie_path(movie))
            expect(page).to have_selector("#new_review_link_movies_partial")
          end

          scenario "movie reviewed by user shows review on show page", js: true do
            create(:screening, user_id: @current_user.id, movie_id: @current_user.movies.last.id)
            create(:review, user_id: @current_user.id, movie_id: @current_user.movies.last.id)
            # Reviews are only accessible from movie show page, not modal
            visit(movie_path(movie))
            expect(page).to have_content(movie.reviews.first.body)
          end

          scenario "if the movie has been watched, there is no link to mark as watched", js: true do
            create(:screening, user_id: @current_user.id, movie_id: @current_user.movies.last.id)
            open_movie_modal(movie)
            expect(page).not_to have_button("mark_watched_link_movies_partial")
          end
        end #rating, reviews, marking watched

        # Sorting feature was removed from movies index page
      end # movies index page
    end
  end
end
