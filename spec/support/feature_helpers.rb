module FeatureHelpers
  def sign_up_with(email, password)
    visit root_path

    click_link 'Sign Up'

    fill_in "Email", with: email
    fill_in "Password", with: password
    fill_in "Password confirmation", with: password
    click_link_or_button 'Sign up'
    @email = email
    current_user = user
  end

  def sign_in_user(user)
    visit root_path
    click_link 'Sign In'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'
    current_user = user
  end

  # def login_user(user)
  #   @request.env["devise.mapping"] = Devise.mappings[:user]
  #   @user = user
  #   sign_in @user
  # end

  # def login_user
  #   Warden.test_mode!
  #   user = FactoryGirl.create(:user)
  #   login_as user, :scope => :user
  # end
end