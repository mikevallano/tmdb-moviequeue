require 'rails_helper'

feature "User can create a new list" do

  scenario "existing user can sign in and create lists" do

    sign_in_user

    click_link "Lists"
    click_link "New List"
    fill_in 'Name', with: 'test list one'
    expect { click_button 'Create List' }.to change(List.by_user(current_user), :count).by(1)
    expect(page).to have_content("List was successfully created")

  end
end