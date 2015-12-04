require 'rails_helper'

feature "Can sign up a new user" do
  let(:email) { FFaker::Internet.email }
  let(:user) { FactoryGirl.create(:user) }

  scenario "user can successfully sign up" do
    sign_up_with(email, "password")

    expect(page).to have_content("Signed in as: #{@email}")
  end

  scenario "existing users can sign in" do
    sign_in_user(user)

    expect(page).to have_content("Signed in as: #{@email}")
  end

 scenario "user can sign out" do
    sign_in_user(user)
    click_link "Sign Out"
    expect(page).to have_content("Signed out successfully")
  end

end