require 'rails_helper'

RSpec.feature "Users feature spec", :type => :feature do

  feature "Users can sign up, sign in, log out, have a list, and visit profile" do
    let(:email) { FFaker::Internet.email }
    let(:username) { FFaker::Internet.user_name }
    let(:existing_user) { FactoryGirl.create(:user) }

    scenario "user can successfully sign up" do
      sign_up_with(email, username, "password")
      expect(page).to have_content("Signed in as: #{@email}")
    end

    scenario 'user is sent a confirmation email after signing up' do
      visit root_path

      click_link 'Sign Up'

      fill_in "Email", with: email
      fill_in "Username", with: username
      fill_in "Password", with: "password"
      fill_in "Password confirmation", with: "password"
      click_link_or_button 'Sign up'

      expect(last_email).to have_content("To: #{email}")
    end

    scenario "user can't log in until confirmed" do
      visit root_path

      click_link 'Sign Up'

      fill_in "Email", with: email
      fill_in "Username", with: username
      fill_in "Password", with: "password"
      fill_in "Password confirmation", with: "password"
      click_link_or_button 'Sign up'

      visit user_lists_path(User.last)
      expect(page).to have_content("Sign in with email or username")
      url = URI.parse(current_url)
      expect("#{url}").to include("sign_in")
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

    scenario "user can request a password reset" do
      sign_in_user(existing_user)
      click_link "Sign Out"
      click_link "Sign In"
      click_link "Forgot your password?"
      fill_in "Email", with: existing_user.email
      click_link_or_button "Send me reset password instructions"
      expect(last_email).to have_content("To: #{existing_user.email}")
      expect(last_email.body.encoded).to have_content "Change my password"
      # visit edit_user_password_url(reset_password_token: existing_user.reset_password_token)
      # save_and_open_page
      # fill_in "New password", with: "password1"
      # fill_in "Confirm new password", with: "password1"
      # click_link_or_button "Change my password"
      # expect(page).to have_content("Your password has been changed successfully.")
    end

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

    scenario 'user can visit their profile page' do
      sign_in_user(existing_user)
      visit(user_path(existing_user))
      expect(page).to have_content(existing_user.email)
    end

    scenario 'user profile page has slugged url' do
      sign_in_user(existing_user)
      visit(user_path(existing_user))
      url = URI.parse(current_url)
      expect("#{url}").to include("#{existing_user.slug}")
    end

  end

end #final