require 'rails_helper'

feature "User can create a new list" do

  let(:user) { FactoryGirl.create(:user) }
  let(:user2) { FactoryGirl.create(:user) }

  context "with signed in user" do

    scenario "users can create lists" do

      sign_in_user(user)
      click_link "Lists"
      click_link "New List"
      fill_in 'Name', with: 'test list one'
      expect { click_button 'Create List' }.to change(List, :count).by(1)
      @list = List.last
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
      visit(edit_list_path(@list))
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
      @list = List.last
      click_link "Lists"
      click_link "Destroy"
      expect(page).to have_content("destroyed")
    end

  end #signed in user context

  context "user trying to access other users' lists" do

    scenario  "user's can't view or edit another user's list" do

      sign_in_user(user)
      click_link "Lists"
      click_link "New List"
      fill_in 'Name', with: 'test list one'
      @list = List.last
      click_link "Sign Out"
      sign_in_user(user2)

      visit(list_path(@list))
      expect(page).to have_content("That's not your list")

      visit(edit_list_path(@list))
      expect(page).to have_content("That's not your list")

    end

  end #trying to access other users' lists

end