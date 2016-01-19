require 'rails_helper'

RSpec.feature "Lists feature spec", :type => :feature do

  feature "List views" do

    let(:user) { FactoryGirl.create(:user) }
    let(:email) { FFaker::Internet.email }
    let(:username) { FFaker::Internet.user_name }
    let(:user2) { FactoryGirl.create(:user) }
    let(:movie) { FactoryGirl.create(:movie) }
    let(:movie2) { FactoryGirl.create(:movie) }
    let(:list) { FactoryGirl.create(:list, owner_id: user.id) }
    let(:list2) { FactoryGirl.create(:list, owner_id: user2.id) }
    let(:public_list) { FactoryGirl.create(:list, :owner => user, :is_public => true) }
    let(:listing) { FactoryGirl.create(:listing, list_id: list.id, movie_id: movie.id) }
    let(:listing2) { FactoryGirl.create(:listing, list_id: list2.id, movie_id: movie.id) }
    let(:public_listing) { FactoryGirl.create(:listing, list_id: public_list.id, movie_id: movie2.id) }


    describe "crud actions for lists" do

      scenario "users can create lists" do
        sign_in_user(user)
        click_link "my_lists_nav_link"
        click_link "new_list_link_list_index"
        fill_in "list_name", with: "test list one"
        expect { click_button "submit_list_button" }.to change(List, :count).by(1)
        expect(page).to have_content("test list one")
      end

      scenario "users can view lists page" do
        sign_in_and_create_list
        click_link "my_lists_nav_link"
        click_link "show_list_link_list_index"
        expect(page).to have_content(List.last.name)
      end

      scenario "user can edit their own list" do
        sign_in_and_create_list
        @list = List.last
        visit(edit_user_list_path(user, @list))
        fill_in "list_name", with: "test list update"
        click_button "submit_list_button"
        expect(page).to have_content("test list update")
      end

      scenario "user can delete their own list" do
        sign_in_and_create_list
        click_link "my_lists_nav_link"
        expect { click_link "destroy_list_link_list_index" }.to change(List, :count).by(-1)
      end

      scenario "user can mark a list as public" do
        sign_in_user(user)
        click_link "my_lists_nav_link"
        click_link "new_list_link_list_index"
        fill_in "list_name", with: "test list one"
        check "list_is_public"
        click_button "submit_list_button"
        expect(List.last.is_public).to be true
      end

    end #crud action

    describe "user has a list after signing up" do

      scenario "user has a default list after signing up" do
        sign_up_with(email, username, "password")
        expect(@current_user.lists.count).to eq(1)
      end

      scenario "user has a default list with is_main=true after signing up" do
        sign_up_with(email, username, "password")
        expect(@current_user.lists.first.is_main).to eq(true)
      end

      scenario "user's default list with is_public=false after signing up" do
        sign_up_with(email, username, "password")
        expect(@current_user.lists.first.is_public).to eq(false)
      end

    end #list after signing up

    describe "list show page paginates movies" do
      scenario "list show page paginates movies" do
        sign_in_user(user)
        30.times { FactoryGirl.create(:movie) }
        counter = Movie.first.id
        30.times do
          FactoryGirl.create(:listing, list_id: list.id, movie_id: Movie.find(counter).id)
          counter += 1
        end
        visit user_list_path(user, list)
        expect(page).to have_content("Next")
        click_link "Next" #this will show movies 20-30
        expect(page).to have_content("Previous")
        expect(page).not_to have_link("Next")
      end
    end

    describe "movie management" do

      scenario "users can add a movie to their list" do
        sign_up_api_search_then_add_movie_to_list
        expect(page).to have_content("added to your list")
      end

      scenario "users can remove a movie from their list from the list show page" do
        sign_up_api_search_then_add_movie_to_list

        click_link "my_lists_nav_link"
        click_link "show_list_link_list_index"
        click_link "remove_movie_link_movies_partial"
        expect(page).to have_content("Movie was removed from list.")
      end

    end #movie management

    describe "list show page functionality" do

      before(:each) do
        sign_up_api_search_then_add_movie_to_list
        click_link "my_lists_nav_link"
      end

      scenario "users can add tags to a movie from the list show page and are returned to the page" do
        click_link "show_list_link_list_index"
        fill_in "tag_list", with: "dark comedy, spooky"
        click_button "add_tags_button_movies_partial", match: :first
        expect(current_url).to eq(user_list_url(@current_user, List.last))
        expect(page).to have_content("dark-comedy")
        expect(page).to have_content("spooky")
      end #user can tag movie

      scenario "user can click a tag to see movies with that tag" do
        click_link "show_list_link_list_index"
        fill_in "tag_list", with: "dark comedy, spooky"
        click_button "add_tags_button_movies_partial", match: :first
        click_link "spooky", match: :first
        expect(page).to have_content("Fargo")
      end

      scenario "user can remove tags and be returned to the list page" do
        click_link "show_list_link_list_index"
        fill_in "tag_list", with: "dark comedy, spooky"
        click_button "add_tags_button_movies_partial", match: :first
        expect { click_link "remove_tag_link_movies_partial_on_list", match: :first }.to change(Tagging.by_user(@current_user), :count).by(-1)
        click_link "remove_tag_link_movies_partial_on_list"
        expect(current_url).to eq(user_list_url(@current_user, List.last))
      end

      scenario "user can update a listing's priority" do
        click_link "show_list_link_list_index"
        fill_in "priority_number_field_movies_partial", with: '9'
        click_button "add_priority_button_movies_partial"
        expect(page).to have_content("Priority added.")
        expect(page).to have_content('9')
      end

      scenario "movie not yet rated shows field to submit new rating, which returns to the list page" do
        click_link "show_list_link_list_index"
        expect(page).not_to have_selector("#show_rating_link_movies_partial")
        expect(page).to have_selector("#rating_submit_button_rating_form")
        fill_in "rating_value_field", with: '5'
        click_button "rating_submit_button_rating_form"
        expect(page).to have_content('5')
        expect(current_url).to eq(user_list_url(@current_user, List.last))
      end

      scenario "movie rated by user shows link to the rating show path" do
        FactoryGirl.create(:rating, user_id: @current_user.id, movie_id: @current_user.movies.last.id, value: 5)
        click_link "show_list_link_list_index"
        expect(page).to have_selector("#show_rating_link_movies_partial")
        expect(page).not_to have_selector("#new_rating_link_movies_partial")
      end

      scenario "movie not yet reviewed shows link to review the movie" do
        click_link "show_list_link_list_index"
        expect(page).not_to have_selector("#show_review_link_movies_partial")
        expect(page).to have_selector("#new_review_link_movies_partial")
      end

      scenario "movie reviewed by user shows link to the rating show path" do
        FactoryGirl.create(:review, user_id: @current_user.id, movie_id: @current_user.movies.last.id)
        click_link "show_list_link_list_index"
        expect(page).to have_selector("#show_review_link_movies_partial")
        expect(page).not_to have_selector("#new_review_link_movies_partial")
      end

      scenario "if user has not watched the movie, there is a link to mark as watched" do
        click_link "show_list_link_list_index"
        expect(page).to have_selector("#mark_watched_link_movies_partial")
        expect(page).not_to have_selector("#view_screenings_link_movies_partial")
      end

      scenario "if the movie has been watched, there is no link to mark as watched" do
        FactoryGirl.create(:screening, user_id: @current_user.id, movie_id: @current_user.movies.last.id)
        click_link "show_list_link_list_index"
        expect(page).not_to have_selector("#mark_watched_link_movies_partial")
        expect(page).to have_selector("#view_screenings_link_movies_partial")
      end

    end #list show page functionality


    describe "user trying to access other users' lists" do

      scenario  "user's can't view or edit another user's list (without being a member)" do
        sign_in_and_create_list
        @list = List.last
        click_link "sign_out_nav_link"
        sign_in_user(user2)

        visit(user_list_path(user, @list))
        expect(page).to have_content("That's not your list")

        visit(edit_user_list_path(user, @list))
        expect(page).to have_content("That's not your list")
      end

    end #trying to access other users' lists

    describe "public lists" do

      before(:each) do
        public_list
        public_listing
      end

      scenario "user can view public lists" do
        sign_in_user(user2)
        click_link "public_lists_nav_link"
        expect(page).to have_content(public_list.name)
      end

      scenario "user sees public_show page if user's all_lists doesn't include list" do
        skip "now using partial. should rewrite"
        sign_in_user(user2)
        click_link "public_lists_nav_link"
        click_link "#{public_list.name}"
        expect(page).to have_selector("#add_to_list_button_movies_partial")
        expect(page).not_to have_selector("#add_priority_button_movies_partial")
      end

      scenario "user sees standard list show page if user's all_lists does include list" do
        skip "now using partial. should rewrite"
        sign_in_user(public_list.owner)
        click_link "public_lists_nav_link"
        click_link "#{public_list.name}"
        expect(page).not_to have_selector("#add_to_list_button_movies_partial")
        expect(page).to have_selector("#add_priority_button_movies_partial")
        expect(page).to have_selector("#rating_submit_button_rating_form")
      end

      describe "public show page pagination" do
        it "should paginate the movies on a public list" do
          sign_in_user(user)
          30.times { FactoryGirl.create(:movie) }
          counter = Movie.first.id
          30.times do
            FactoryGirl.create(:listing, list_id: public_list.id, movie_id: Movie.find(counter).id)
            counter += 1
          end
          click_link "sign_out_nav_link"
          sign_in_user(user2)
          click_link "public_lists_nav_link"
          click_link "#{public_list.name}"
          expect(page).to have_content("Next")
          click_link "Next"
          expect(page).to have_content("Previous")
          expect(page).not_to have_link("Next")
        end
      end

      describe "public list page pagination" do
        it "should paginate the lists on the all lists page" do
          sign_in_user(user)
          30.times { FactoryGirl.create(:list, is_public: true, owner: user) }
          click_link "sign_out_nav_link"
          sign_in_user(user2)
          click_link "public_lists_nav_link"
          expect(page).to have_content("Next")
          click_link "Next"
          expect(page).to have_content("Previous")
          expect(page).not_to have_link("Next")
        end
      end

    end #public lists

  end

end #final