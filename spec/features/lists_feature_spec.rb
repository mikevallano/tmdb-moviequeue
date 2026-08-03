require 'rails_helper'

RSpec.feature "Lists feature spec", type: :feature, feature: :true do

  feature "List views" do

    let(:user) { FactoryBot.create(:user) }
    let(:email) { FFaker::Internet.email }
    let(:username) { FFaker::Internet.user_name }
    let(:user2) { FactoryBot.create(:user) }
    let(:movie) { FactoryBot.create(:movie) }
    let(:movie2) { FactoryBot.create(:movie) }
    let(:fargo) { FactoryBot.create(:movie, title: "Fargo", runtime: 90,
      vote_average: 8, release_date: Date.today - 8000) }
    let(:no_country) { FactoryBot.create(:movie, title: "No Country for Old Men", runtime: 100,
      vote_average: 9, release_date: Date.today - 6000) }
    let(:fargo_listing) { FactoryBot.create(:listing, list_id: list.id, movie_id: fargo.id) }
    let(:no_country_listing) { FactoryBot.create(:listing, list_id: list.id, movie_id: no_country.id) }
    let(:list) { FactoryBot.create(:list, owner_id: user.id) }
    let(:list1) { FactoryBot.create(:list, name: "my queue", owner_id: user.id) }
    let(:list2) { FactoryBot.create(:list, owner_id: user2.id) }
    let(:list3) { FactoryBot.create(:list, owner_id: user.id) }
    let(:public_list) { FactoryBot.create(:list, :owner => user, :is_public => true) }
    let(:listing) { FactoryBot.create(:listing, list_id: list.id, movie_id: movie.id) }
    let(:listing2) { FactoryBot.create(:listing, list_id: list2.id, movie_id: movie.id) }
    let(:listing3) { FactoryBot.create(:listing, list_id: list3.id, movie_id: movie.id) }
    let(:public_listing) { FactoryBot.create(:listing, list_id: public_list.id, movie_id: movie2.id) }
    let(:list_name) { FFaker::HipsterIpsum.words(1).join(' ') }
    let(:list_description) { FFaker::HipsterIpsum.phrase }
    let(:streaming_service_providers) {[
      { name: "FakeFlix", url: "http://www.fakeflix.com/search/Fake", pay_model: "try" },
      { name: "Foodoo", url: "https://www.foodoo.com/search?searchString=Fake", pay_model: "rent" }
    ]}


    describe "crud actions for lists" do

      scenario "users can create lists" do
        sign_in_user(user)
        visit user_lists_path(user)
        click_link "New List"
        fill_in "list_name_field", with: list_name
        expect { click_button "Save" }.to change(List, :count).by(1)
        expect(page).to have_content("#{list_name.titlecase}")
      end

      scenario "users can view lists page" do
        sign_in_and_create_list
        visit user_lists_path(user)
        click_link List.last.name.titlecase, match: :first
        expect(page).to have_content(List.last.name)
      end

      scenario "user can edit their own list" do
        sign_in_and_create_list
        @list = List.last
        visit(edit_user_list_path(user, @list))
        fill_in "list_name_field", with: list_name
        click_button "Save"
        expect(page).to have_content("#{list_name.titlecase}")
      end

      scenario "user can delete their own list" do
        sign_in_and_create_list
        visit edit_user_list_path(user, List.last)
        expect { click_button "Delete List" }.to change(List, :count).by(-1)
      end

      scenario "listings are destroyed when list is deleted" do
        sign_in_user(user)
        list
        FactoryBot.create(:listing, list_id: list.id, movie_id: movie.id)
        expect(user.movies).to include(movie)
        visit user_list_path(user, list)
        click_link "Edit"
        click_button "Delete List"
        expect(user.movies).not_to include(movie)
      end

      scenario "memberships are destroyed when list is deleted" do
        sign_in_user(user)
        list
        FactoryBot.create(:membership, list_id: list.id, member_id: user2.id)
        expect(user2.member_lists).to include(list)
        visit user_list_path(user, list)
        click_link "Edit"
        click_button "Delete List"
        expect(user2.member_lists).not_to include(list)
      end

      scenario "user can mark a list as public" do
        sign_in_user(user)
        visit user_lists_path(user)
        click_link "New List"
        fill_in "list_name_field", with: list_name
        check "list_is_public"
        click_button "Save"
        expect(List.last.is_public).to be true
      end

      scenario "lists can have descriptions" do
        sign_in_user(user)
        visit user_lists_path(user)
        click_link "New List"
        fill_in "list_name_field", with: list_name
        fill_in "list_description_field", with: list_description
        click_button "Save"
        visit(user_list_path(user, List.last))
        expect(page).to have_content("#{list_description}")
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
        30.times { FactoryBot.create(:movie) }
        counter = Movie.first.id
        30.times do
          FactoryBot.create(:listing, list_id: list.id, movie_id: Movie.find(counter).id)
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
      before do
        allow(MovieDataService)
          .to receive(:get_movie_streaming_service_providers)
          .and_return(streaming_service_providers)
      end

      xscenario "users can add a movie to their list", js: true do
        # TODO: failing due to list selection. See issue #247
        list1
        page.driver.browser.manage.window.resize_to(1280,800)
        sign_in_user(user)
        visit(api_search_path)
        VCR.use_cassette('tmdb_search', :match_requests_on => [:body]) do
          fill_in "movie_title", with: 'fargo'
          click_button "search_by_title_button"
        end
        click_link("modal_link_275")
        select "my queue", :from => "listing[list_id]", match: :first
        VCR.use_cassette('tmdb_add_movie', :match_requests_on => [:body]) do
          click_button "add_to_list_button_movies_partial", match: :first
        end
        wait_for_ajax
        click_link("show_list_link_on_list_movies_partial")
        wait_for_ajax
        expect(page).to have_selector("#275")
      end

      xscenario "users can remove a movie from their list from the list show page", js: true do
        # TODO: Need to investigate why confirm dialog is not found. See issue #247
        listing
        page.driver.browser.manage.window.resize_to(1280,800)
        sign_in_user(user)
        visit(user_list_path(user, list))
        find("##{movie.tmdb_id}")
        find("##{movie.tmdb_id}").click
        accept_confirm do
          find("#remove_movie_link_movies_partial").click
        end
        # find("#remove_movie_link_movies_partial").click
        # page.driver.browser.switch_to.alert.accept
        wait_for_ajax
        expect(page).not_to have_selector("##{movie.tmdb_id}")
      end
    end #movie management


    describe "list show sorting" do

      context "sorting" do
        before(:each) do
        sign_in_user(user)
        listing
        fargo_listing
        no_country_listing
        visit(user_list_path(user, list))
        end #before context

        scenario "sort by title" do
          select "title", :from => "sort_by"
          # Auto-submits and page updates - sorting logic tested in unit tests
          expect(page).to have_selector('.movies-container__poster')
          expect(page).to have_select('sort_by', selected: 'title')
        end

        scenario "sort by shortest runtime" do
          select "shortest runtime", :from => "sort_by"
          # Auto-submits and page updates - sorting logic tested in unit tests
          expect(page).to have_selector('.movies-container__poster')
          expect(page).to have_select('sort_by', selected: 'shortest runtime')
        end

        scenario "sort by longest runtime" do
          select "longest runtime", :from => "sort_by"
          # Auto-submits and page updates - sorting logic tested in unit tests
          expect(page).to have_selector('.movies-container__poster')
          expect(page).to have_select('sort_by', selected: 'longest runtime')
        end

        scenario "sort by highest priority" do
          @listing = Listing.find_by(list_id: list.id, movie_id: no_country.id)
          @listing.priority = 5
          @listing.save
          select "highest priority", :from => "sort_by"
          # Auto-submits on select, no button needed
          expect(page).to have_selector('.movies-container__poster')
        end

        scenario "sort by newest release" do
          select "newest release", :from => "sort_by"
          # Auto-submits on select, no button needed
          expect(page).to have_selector('.movies-container__poster')
        end

        scenario "sort by vote average" do
          select "vote average", :from => "sort_by"
          # Auto-submits on select, no button needed
          expect(page).to have_selector('.movies-container__poster')
        end

        scenario "sort by watched movies" do
          user.watched_movies << no_country
          select "watched movies", :from => "sort_by"
          # Auto-submits on select, no button needed
          expect(page).to have_selector('.movies-container__poster')
        end

        scenario "sort by unwatched movies" do
          user.watched_movies << no_country
          select "unwatched movies", :from => "sort_by"
          # Auto-submits on select, no button needed
          expect(page).to have_selector('.movies-container__poster')
        end

        scenario "sort by recently watched" do
          user.watched_movies << no_country
          select "recently watched", :from => "sort_by"
          # Auto-submits on select, no button needed
          expect(page).to have_selector('.movies-container__poster')
        end
      end #sorting context
    end #list show page sorting


    describe "user trying to access other users' lists" do

      scenario  "user's can't view or edit another user's list (without being a member)" do
        sign_in_and_create_list
        @list = List.last
        click_button "sign_out_nav_link"
        sign_in_user(user2)

        visit(user_list_path(user, @list))
        expect(page).to have_content("That's not your list")

        visit(edit_user_list_path(user, @list))
        expect(page).to have_content("That's not your list")
      end
    end #trying to access other users' lists
  end
end
