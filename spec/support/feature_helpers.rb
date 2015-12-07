module FeatureHelpers
  def sign_up_with(email, password)
    visit root_path

    click_link 'Sign Up'

    fill_in "Email", with: email
    fill_in "Password", with: password
    fill_in "Password confirmation", with: password
    click_link_or_button 'Sign up'
    @email = email
    @current_user = User.find_by_email(email)
  end

  def sign_in_user(user)
    visit root_path
    click_link 'Sign In'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'
    @current_user = User.find_by_email(user.email)
  end

  def api_search_for_movie
    VCR.use_cassette('tmdb_search') do
      fill_in "Enter Title", with: 'fargo'
      click_button 'Search'
    end
  end

  def api_more_info
    VCR.use_cassette('tmdb_more') do
      click_link('More info', match: :first)
    end

  end

end