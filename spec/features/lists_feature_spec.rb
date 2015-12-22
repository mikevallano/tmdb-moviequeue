require 'rails_helper'

RSpec.feature "Lists feature spec", :type => :feature do

  feature "User can create a new list" do

    let(:user) { FactoryGirl.create(:user) }
    let(:user2) { FactoryGirl.create(:user) }
    let(:movie) { FactoryGirl.create(:movie) }
    let(:list) { FactoryGirl.create(:list, owner_id: user.id) }
    let(:list2) { FactoryGirl.create(:list, owner_id: user2.id) }
    let(:listing) { FactoryGirl.create(:listing, list_id: list.id, movie_id: movie.id) }
    let(:listing2) { FactoryGirl.create(:listing, list_id: list2.id, movie_id: movie.id) }

    context "with signed in user" do

      scenario "users can create lists" do

        sign_in_user(user)
        click_link "Lists"
        click_link "New List"
        fill_in 'Name', with: 'test list one'
        expect { click_button 'Create List' }.to change(List, :count).by(1)
        expect(page).to have_content("List was successfully created")
        click_link "Sign Out"

      end

      scenario "user can edit their own list" do
        sign_in_user(user)
        click_link "Lists"
        click_link "New List"
        fill_in 'Name', with: 'test list one'
        click_button 'Create List'
        @list = List.last
        visit(edit_user_list_path(user, @list))
        expect(page).to have_content("Editing List")
        fill_in 'Name', with: 'test list update'
        click_button "Update"
        expect(page).to have_content("updated")
      end

       scenario "user can delete their own list" do
        sign_in_user(user)
        click_link "Lists"
        click_link "New List"
        fill_in 'Name', with: 'test list one'
        click_button 'Create List'
        click_link "Lists"
        click_link "Destroy"
        expect(page).to have_content("destroyed")
      end

      scenario 'user can mark a list as public' do
        sign_in_user(user)
        click_link "Lists"
        click_link "New List"
        fill_in 'Name', with: 'test list one'
        check 'list_is_public'
        click_button 'Create List'
        expect(List.last.is_public).to be true

      end

    end #signed in user context

    context "user trying to access other users' lists" do

      scenario  "user's can't view or edit another user's list (without being a member)" do

        sign_in_user(user)
        click_link "Lists"
        click_link "New List"
        fill_in 'Name', with: 'test list one'
        click_button 'Create List'
        @list = List.last
        click_link "Sign Out"
        sign_in_user(user2)

        visit(user_list_path(user, @list))
        expect(page).to have_content("That's not your list")

        visit(edit_user_list_path(user, @list))
        expect(page).to have_content("That's not your list")

      end

    end #trying to access other users' lists

  end

end #final