require 'rails_helper'

feature "Can sign up a new user" do
  let(:email) { FFaker::Internet.email }
  let(:username) { FFaker::Internet.user_name }
  let(:existing_user) { FactoryGirl.create(:user) }

  scenario "user can successfully sign up" do
    sign_up_with(email, username, "password")
    expect(page).to have_content("Signed in as: #{@email}")
  end

  scenario "existing users can sign in with email" do
    visit root_path
    click_link 'Sign In'
    fill_in 'Sign in with email or username', with: existing_user.email
    fill_in 'Password', with: existing_user.password
    click_button 'Log in'
    @current_user = User.find_by_email(existing_user.email)
    expect(page).to have_content("Signed in as: #{@email}")
  end

  scenario "existing user can sign in with username" do
    visit root_path
    click_link 'Sign In'
    fill_in 'Sign in with email or username', with: existing_user.username
    fill_in 'Password', with: existing_user.password
    click_button 'Log in'
    @current_user = User.find_by_email(existing_user.email)
    expect(page).to have_content("Signed in as: #{@email}")
  end

  scenario "user can sign out" do
    sign_in_user(existing_user)
    click_link "Sign Out"
    expect(page).to have_content("Signed out successfully")
  end

  scenario "user has a default list after signing up" do
    sign_up_with(email, username, "password")
    expect(@current_user.lists.count).to eq(1)
  end

  scenario "user has a default list with is_main=true after signing up" do
    sign_up_with(email, username, "password")
    expect(@current_user.lists.first.is_main).to eq(true)
  end

  scenario "user's default list has a default false value for is_public after signing up" do
    sign_up_with(email, username, "password")
    expect(@current_user.lists.first.is_public).to eq(false)
  end

end