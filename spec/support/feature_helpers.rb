module FeatureHelpers
  def sign_up_with(email, username, password)
    visit root_path

    click_link 'Sign Up'

    fill_in "Email", with: email
    fill_in "Username", with: username
    fill_in "Password", with: password
    fill_in "Password confirmation", with: password
    click_link_or_button 'Sign up'
    @email = email
    @current_user = User.find_by_email(email)
  end

  def sign_in_user(user)
    visit root_path
    click_link 'Sign In'
    fill_in 'Sign in with email or username', with: user.email
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


  def bad_api_search_for_movie
    VCR.use_cassette('tmdb_bad_movie_search') do
      fill_in "Enter Title", with: 'zasdlkjfasdlkjf'
      click_button 'Search'
    end
  end

  def api_more_info
    VCR.use_cassette('tmdb_more') do
      click_link('More info', match: :first)
    end
  end

  def api_actor_search
    VCR.use_cassette('tmdb_actor_search') do
      fill_in "Enter Actor Name", with: 'Steve Buscemi'
      click_button 'Search'
    end
  end

  def bad_api_actor_search
    VCR.use_cassette('tmdb_bad_actor_search') do
      fill_in "Enter Actor Name", with: '&sjhskjhdf*s7'
      click_button 'Search'
    end
  end

  def api_two_actor_search
    VCR.use_cassette('tmdb_two_actor_search') do
      fill_in "Enter Actor Name", with: 'Steve Buscemi'
      fill_in "Enter Other Actor Name", with: 'John Goodman'
      click_button 'Search'
    end
  end

  def bad_api_two_actor_search
    VCR.use_cassette('tmdb_bad_two_actor_search') do
      fill_in "Enter Actor Name", with: '&*&*&^'
      fill_in "Enter Other Actor Name", with: 'skjsdf&*sfsd%'
      click_button 'Search'
    end
  end

end