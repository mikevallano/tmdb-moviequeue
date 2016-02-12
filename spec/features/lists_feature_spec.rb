require 'rails_helper'

RSpec.feature "Lists feature spec", :type => :feature do

  feature "List views" do

    let(:user) { FactoryGirl.create(:user) }
    let(:email) { FFaker::Internet.email }
    let(:username) { FFaker::Internet.user_name }
    let(:user2) { FactoryGirl.create(:user) }
    let(:movie) { FactoryGirl.create(:movie) }
    let(:movie2) { FactoryGirl.create(:movie) }
    let(:fargo) { FactoryGirl.create(:movie, title: "Fargo", runtime: 90,
      vote_average: 8, release_date: Date.today - 8000) }
    let(:no_country) { FactoryGirl.create(:movie, title: "No Country for Old Men", runtime: 100,
      vote_average: 9, release_date: Date.today - 6000) }
    let(:fargo_listing) { FactoryGirl.create(:listing, list_id: list.id, movie_id: fargo.id) }
    let(:no_country_listing) { FactoryGirl.create(:listing, list_id: list.id, movie_id: no_country.id) }
    let(:list) { FactoryGirl.create(:list, owner_id: user.id) }
    let(:list1) { FactoryGirl.create(:list, name: "my queue", owner_id: user.id) }
    let(:list2) { FactoryGirl.create(:list, owner_id: user2.id) }
    let(:list3) { FactoryGirl.create(:list, owner_id: user.id) }
    let(:public_list) { FactoryGirl.create(:list, :owner => user, :is_public => true) }
    let(:listing) { FactoryGirl.create(:listing, list_id: list.id, movie_id: movie.id) }
    let(:listing2) { FactoryGirl.create(:listing, list_id: list2.id, movie_id: movie.id) }
    let(:listing3) { FactoryGirl.create(:listing, list_id: list3.id, movie_id: movie.id) }
    let(:public_listing) { FactoryGirl.create(:listing, list_id: public_list.id, movie_id: movie2.id) }
    let(:list_name) { FFaker::HipsterIpsum.words(3).join(' ') }
    let(:list_description) { FFaker::HipsterIpsum.phrase }


    describe "crud actions for lists" do

      scenario "users can create lists" do
        sign_in_user(user)
        click_link "my_lists_nav_link"
        click_link "new_list_link_list_index"
        fill_in "list_name_field", with: list_name
        expect { click_button "submit_list_button" }.to change(List, :count).by(1)
        expect(page).to have_content("#{list_name.titlecase}")
      end

      scenario "users can view lists page" do
        sign_in_and_create_list
        click_link "my_lists_nav_link"
        click_link "show_list_link_list_index", match: :first
        expect(page).to have_content(List.last.name)
      end

      scenario "user can edit their own list" do
        sign_in_and_create_list
        @list = List.last
        visit(edit_user_list_path(user, @list))
        fill_in "list_name_field", with: list_name
        click_button "submit_list_button"
        expect(page).to have_content("#{list_name.titlecase}")
      end

      scenario "user can delete their own list" do
        sign_in_and_create_list
        click_link "my_lists_nav_link"
        expect { click_link "destroy_list_link_list_index" }.to change(List, :count).by(-1)
      end

      scenario "listings are destroyed when list is deleted" do
        sign_in_user(user)
        list
        FactoryGirl.create(:listing, list_id: list.id, movie_id: movie.id)
        expect(user.movies).to include(movie)
        click_link "my_lists_nav_link"
        click_link "destroy_list_link_list_index"
        expect(user.movies).not_to include(movie)
      end

      scenario "memberships are destroyed when list is deleted" do
        sign_in_user(user)
        list
        FactoryGirl.create(:membership, list_id: list.id, member_id: user2.id)
        expect(user2.member_lists).to include(list)
        click_link "my_lists_nav_link"
        click_link "destroy_list_link_list_index"
        expect(user2.member_lists).not_to include(list)
      end

      scenario "user can mark a list as public" do
        sign_in_user(user)
        click_link "my_lists_nav_link"
        click_link "new_list_link_list_index"
        fill_in "list_name_field", with: list_name
        check "list_is_public"
        click_button "submit_list_button"
        expect(List.last.is_public).to be true
      end

      scenario "lists can have descriptions" do
        sign_in_user(user)
        click_link "my_lists_nav_link"
        click_link "new_list_link_list_index"
        fill_in "list_name_field", with: list_name
        fill_in "list_description_field", with: list_description
        click_button "submit_list_button"
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

      scenario "dealing with favicon issue", js: true do
        #TODO: resolve favicon issue
        visit(root_path)
        wait_for_ajax
        expect{visit(root_path)}.to raise_error( ActionController::RoutingError)
      end

      scenario "users can add a movie to their list and mark it as watched", js: true do
        list1
        sign_in_user(user)
        page.driver.browser.manage.window.resize_to(1280,800)
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
        click_link("show_list_link_on_list_movies_partial")
        find("#modal_link_275")
        find("#modal_link_275").click
        find("#mark_watched_link_movies_partial").click
        expect(page).to have_content("seen")
      end

      scenario "users can remove a movie from their list from the list show page", js: true do
        listing
        listing3
        page.driver.browser.manage.window.resize_to(1280,800)
        sign_in_user(user)
        visit(user_list_path(user, list))
        find("#modal_link_#{movie.tmdb_id}")
        find("#modal_link_#{movie.tmdb_id}").click
        find("#remove_movie_link_movies_partial").click
        page.driver.browser.switch_to.alert.accept
        expect(page).to have_content("Movie was removed from list.")
      end

      scenario "user can update a listing's priority", js: true do
        listing
        page.driver.browser.manage.window.resize_to(1280,800)
        sign_in_user(user)
        visit(user_list_path(user, list))
        find("#modal_link_#{movie.tmdb_id}")
        find("#modal_link_#{movie.tmdb_id}").click
        select "High", :from => "priority"
        click_button "add_priority_button_movies_partial"
        wait_for_ajax
        expect(page).to have_content("High")
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
          click_button "list_sort_button"
          expect(page.body.index("modal_link_#{fargo.tmdb_id}")).to be < page.body.index("modal_link_#{no_country.tmdb_id}")
        end

        scenario "sort by shortest runtime" do
          select "shortest runtime", :from => "sort_by"
          click_button "list_sort_button"
          expect(page.body.index("modal_link_#{fargo.tmdb_id}")).to be < page.body.index("modal_link_#{no_country.tmdb_id}")
        end

        scenario "sort by longest runtime" do
          select "longest runtime", :from => "sort_by"
          click_button "list_sort_button"
          expect(page.body.index("modal_link_#{no_country.tmdb_id}")).to be < page.body.index("modal_link_#{fargo.tmdb_id}")
        end

        scenario "sort by highest priority" do
          @listing = Listing.find_by(list_id: list.id, movie_id: no_country.id)
          @listing.priority = 5
          @listing.save
          select "highest priority", :from => "sort_by"
          click_button "list_sort_button"
          expect(page.body.index("modal_link_#{no_country.tmdb_id}")).to be < page.body.index("modal_link_#{fargo.tmdb_id}")
        end

        scenario "sort by newest release" do
          select "newest release", :from => "sort_by"
          click_button "list_sort_button"
          expect(page.body.index("modal_link_#{no_country.tmdb_id}")).to be < page.body.index("modal_link_#{fargo.tmdb_id}")
        end

        scenario "sort by vote average" do
          select "vote average", :from => "sort_by"
          click_button "list_sort_button"
          expect(page.body.index("modal_link_#{no_country.tmdb_id}")).to be < page.body.index("modal_link_#{fargo.tmdb_id}")
        end

        scenario "sort by watched movies" do
          user.watched_movies << no_country
          select "watched movies", :from => "sort_by"
          click_button "list_sort_button"
          expect(page.body.index("modal_link_#{no_country.tmdb_id}")).to be < page.body.index("modal_link_#{fargo.tmdb_id}")
        end

        scenario "sort by unwatched movies" do
          user.watched_movies << no_country
          select "unwatched movies", :from => "sort_by"
          click_button "list_sort_button"
          expect(page.body.index("modal_link_#{fargo.tmdb_id}")).to be < page.body.index("modal_link_#{no_country.tmdb_id}")
        end

        scenario "sort by only show unwatched" do
          user.watched_movies << no_country
          select "only show unwatched", :from => "sort_by"
          click_button "list_sort_button"
          expect(page).not_to have_selector("#modal_link_#{no_country.tmdb_id}")
          expect(page).to have_selector("#modal_link_#{fargo.tmdb_id}")
        end

        scenario "sort by only show watched" do
          user.watched_movies << no_country
          select "only show watched", :from => "sort_by"
          click_button "list_sort_button"
          expect(page).to have_selector("#modal_link_#{no_country.tmdb_id}")
          expect(page).not_to have_selector("#modal_link_#{fargo.tmdb_id}")
        end

        scenario "sort by recently watched" do
          user.watched_movies << no_country
          select "recently watched", :from => "sort_by"
          click_button "list_sort_button"
          expect(page).to have_selector("#modal_link_#{no_country.tmdb_id}")
          expect(page).not_to have_selector("#modal_link_#{fargo.tmdb_id}")
        end

        context "sub-sort by member" do
          before(:each) do
            Membership.create(list_id: List.last.id, member_id: user.id)
            Membership.create(list_id: List.last.id, member_id: user2.id)
            user.watched_movies << no_country
            user2.watched_movies << fargo
          end

          scenario "sub-sort by list member for watched movies" do
            select "watched movies", :from => "sort_by"
            click_button "list_sort_button"
            select "#{user.username}", :from => "member"
            click_button "list_sort_watched_by_button"
            expect(page.body.index("modal_link_#{no_country.tmdb_id}")).to be < page.body.index("modal_link_#{fargo.tmdb_id}")
            select "#{user2.username}", :from => "member"
            click_button "list_sort_watched_by_button"
            expect(page.body.index("modal_link_#{fargo.tmdb_id}")).to be < page.body.index("modal_link_#{no_country.tmdb_id}")
          end

          scenario "sort by unwatched movies" do
            select "unwatched movies", :from => "sort_by"
            click_button "list_sort_button"
            select "#{user.username}", :from => "member"
            click_button "list_sort_watched_by_button"
            expect(page.body.index("modal_link_#{fargo.tmdb_id}")).to be < page.body.index("modal_link_#{no_country.tmdb_id}")
            select "#{user2.username}", :from => "member"
            click_button "list_sort_watched_by_button"
            expect(page.body.index("modal_link_#{no_country.tmdb_id}")).to be < page.body.index("modal_link_#{fargo.tmdb_id}")
          end

          scenario "sort by only show unwatched" do
            select "only show unwatched", :from => "sort_by"
            click_button "list_sort_button"
            select "#{@current_user.username}", :from => "member"
            click_button "list_sort_watched_by_button"
            select "#{user2.username}", :from => "member"
            click_button "list_sort_watched_by_button"
            expect(page).to have_selector("#modal_link_#{no_country.tmdb_id}")
            expect(page).not_to have_selector("#modal_link_#{fargo.tmdb_id}")
          end

          scenario "sort by only show watched" do
            select "only show watched", :from => "sort_by"
            click_button "list_sort_button"
            select "#{@current_user.username}", :from => "member"
            expect(page).to have_selector("#modal_link_#{no_country.tmdb_id}")
            expect(page).not_to have_selector("#modal_link_#{fargo.tmdb_id}")
            select "#{user2.username}", :from => "member"
            click_button "list_sort_watched_by_button"
            expect(page).not_to have_selector("#modal_link_#{no_country.tmdb_id}")
            expect(page).to have_selector("#modal_link_#{fargo.tmdb_id}")
          end

          scenario "sort by recently watched" do
            select "recently watched", :from => "sort_by"
            click_button "list_sort_button"
            select "#{@current_user.username}", :from => "member"
            click_button "list_sort_watched_by_button"
            expect(page).to have_selector("#modal_link_#{no_country.tmdb_id}")
            expect(page).not_to have_selector("#modal_link_#{fargo.tmdb_id}")
          end

        end #sub-sort by member


      end #sorting context

    end #list show page sorting


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
        expect(page).to have_content(public_list.name.titlecase)
      end

      scenario "user sees public_show page if user's all_lists doesn't include list" do
        skip "now using partial. should rewrite"
        sign_in_user(user2)
        click_link "public_lists_nav_link"
        click_link "#{public_list.name.titlecase}"
        expect(page).to have_selector("#add_to_list_button_movies_partial")
        expect(page).not_to have_selector("#add_priority_button_movies_partial")
      end

      scenario "user sees standard list show page if user's all_lists does include list" do
        skip "now using partial. should rewrite"
        sign_in_user(public_list.owner)
        click_link "public_lists_nav_link"
        click_link "#{public_list.name.titlecase}"
        expect(page).not_to have_selector("#add_to_list_button_movies_partial")
        expect(page).to have_selector("#add_priority_button_movies_partial")
        expect(page).to have_selector("#rating_submit_button_rating_form")
      end

      describe "public show page pagination" do
        it "should paginate the movies on a public list" do
          sign_in_user(user)
          30.times { FactoryGirl.create(:movie) }
          counter = (Movie.first.id + 1)
          30.times do
            FactoryGirl.create(:listing, list_id: public_list.id, movie_id: Movie.find(counter).id, user_id: user.id)
            counter += 1
          end
          click_link "sign_out_nav_link"
          sign_in_user(user2)
          click_link "public_lists_nav_link"
          click_link "#{public_list.name.titlecase}"
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