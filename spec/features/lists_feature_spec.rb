require 'rails_helper'

RSpec.feature "Lists feature spec", :type => :feature do

  feature "User can create a new list" do

    let(:user) { FactoryGirl.create(:user) }
    let(:user2) { FactoryGirl.create(:user) }
    let(:movie) { FactoryGirl.create(:movie) }
    let(:movie2) { FactoryGirl.create(:movie) }
    let(:list) { FactoryGirl.create(:list, owner_id: user.id) }
    let(:list2) { FactoryGirl.create(:list, owner_id: user2.id) }
    let(:public_list) { FactoryGirl.create(:list, :owner => user, :is_public => true) }
    let(:listing) { FactoryGirl.create(:listing, list_id: list.id, movie_id: movie.id) }
    let(:listing2) { FactoryGirl.create(:listing, list_id: list2.id, movie_id: movie.id) }
    let(:public_listing) { FactoryGirl.create(:listing, list_id: public_list.id, movie_id: movie2.id) }

    context "with signed in user" do

      scenario "users can create lists" do

        sign_in_user(user)
        click_link "my_lists_nav_link"
        click_link "New List"
        fill_in 'Name', with: 'test list one'
        expect { click_button "Create List" }.to change(List, :count).by(1)
        expect(page).to have_content("List was successfully created")
        click_link "sign_out_nav_link"

      end

      scenario "user can edit their own list" do
        sign_in_user(user)
        click_link "my_lists_nav_link"
        click_link "New List"
        fill_in 'Name', with: 'test list one'
        click_button "Create List"
        @list = List.last
        visit(edit_user_list_path(user, @list))
        expect(page).to have_content("Editing List")
        fill_in 'Name', with: 'test list update'
        click_button "Update"
        expect(page).to have_content("updated")
      end

       scenario "user can delete their own list" do
        sign_in_user(user)
        click_link "my_lists_nav_link"
        click_link "New List"
        fill_in 'Name', with: 'test list one'
        click_button "Create List"
        click_link "my_lists_nav_link"
        click_link "Destroy"
        expect(page).to have_content("destroyed")
      end

      scenario 'user can mark a list as public' do
        sign_in_user(user)
        click_link "my_lists_nav_link"
        click_link "New List"
        fill_in 'Name', with: 'test list one'
        check 'list_is_public'
        click_button "Create List"
        expect(List.last.is_public).to be true

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
          visit user_list_path(user, list)
          save_and_open_page
          expect(page).to have_content("Next")
          click_link "Next"
          expect(page).to have_content("Previous")
          expect(page).not_to have_link("Next")
        end
      end

    end #signed in user context

    context "user trying to access other users' lists" do

      scenario  "user's can't view or edit another user's list (without being a member)" do

        sign_in_user(user)
        click_link "my_lists_nav_link"
        click_link "New List"
        fill_in 'Name', with: 'test list one'
        click_button "Create List"
        @list = List.last
        click_link "sign_out_nav_link"
        sign_in_user(user2)

        visit(user_list_path(user, @list))
        expect(page).to have_content("That's not your list")

        visit(edit_user_list_path(user, @list))
        expect(page).to have_content("That's not your list")

      end

    end #trying to access other users' lists

    context 'public lists' do

      before(:each) do
        public_list
        public_listing
      end

      scenario 'user can view public lists' do

        sign_in_user(user2)
        click_link "public_lists_nav_link"
        expect(page).to have_content(public_list.name)

      end

      scenario "user sees public_show page if user's all_lists doesn't include list" do

        sign_in_user(user2)
        click_link "public_lists_nav_link"
        click_link "#{public_list.name}"
        expect(page).to have_content("Add this movie to a list")
        expect(page).not_to have_content("Priority")

      end

      scenario "user sees standard list show page if user's all_lists does include list" do

        sign_in_user(public_list.owner)
        click_link "public_lists_nav_link"
        click_link "#{public_list.name}"
        expect(page).not_to have_content("Add this movie to a list")
        expect(page).to have_content("Priority")

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