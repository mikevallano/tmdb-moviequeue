require 'rails_helper'

feature "Can sign up a new user" do
  let(:email) { FFaker::Internet.email }
  let(:existing_user) { FactoryGirl.create(:user) }

  scenario "user can successfully sign up" do
    sign_up_with(email, "password")
    expect(page).to have_content("Signed in as: #{@email}")
  end

  scenario "existing users can sign in" do
    sign_in_user(existing_user)
    expect(page).to have_content("Signed in as: #{@email}")
  end

  scenario "user can sign out" do
    sign_in_user(existing_user)
    click_link "Sign Out"
    expect(page).to have_content("Signed out successfully")
  end

  scenario "user has a default list after signing up" do
    sign_up_with(email, "password")
    expect(@current_user.lists.count).to eq(1)
  end

  scenario "user has a default list with is_main=true after signing up" do
    sign_up_with(email, "password")
    expect(@current_user.lists.first.is_main).to eq(true)
  end

end