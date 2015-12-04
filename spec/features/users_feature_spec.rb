require 'rails_helper'
# include FeatureHelpers

feature "Can sign up a new user and account" do
  let(:email) { FFaker::Internet.email }
  let(:user) { FactoryGirl.create(:user) }

  scenario "user can successfully sign up" do
    sign_up_with(email, "password")

    # visit root_path

    # click_link 'Sign Up'

    # fill_in "Email", with: email
    # fill_in "Password", with: 'password'
    # fill_in "Password confirmation", with: 'password'
    # click_link_or_button 'Sign up'
    # @email = email
    expect(page).to have_content("Signed in as: #{@email}")
  end

  scenario "existing users can sign in" do
    # sign_in_user

    visit root_path
    click_link 'Sign In'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'
    @current_user = user

    expect(page).to have_content("Signed in as: #{@email}")
  end

end