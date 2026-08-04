module FeatureHelpers

  def sign_up_with(email, username, password)
    # Navigate directly to registration page (no navigation click needed)
    visit new_user_registration_path

    fill_in "Email", with: email
    fill_in "Username", with: username
    fill_in "Password", with: password
    fill_in "Password confirmation", with: password
    click_button "Sign up"

    # Confirm user (bypasses email confirmation for tests)
    visit user_confirmation_path(:confirmation_token => User.last.confirmation_token)

    # Sign in the newly registered user
    visit new_user_session_path
    fill_in "Sign in with Email or Username", with: email
    fill_in "Password", with: password
    click_button "Sign In"

    # Wait for successful sign-in
    expect(page).to have_current_path(root_path)

    @email = email
    @current_user = User.find_by_email(email)
  end

  def sign_in_user(user)
    # Navigate directly to sign-in page (no navigation click needed)
    visit new_user_session_path

    fill_in "Sign in with Email or Username", with: user.email
    fill_in "Password", with: user.password
    click_button "Sign In"

    # Wait for successful sign-in (replaces sleep)
    expect(page).to have_current_path(root_path)

    @current_user = User.find_by_email(user.email)
  end

  def api_search_for_movie
    VCR.use_cassette('fill_in_title_search') do
      fill_in "movie_title", with: 'Fargo'
    end
     VCR.use_cassette('tmdb_search') do
      click_button "Search"
    end
  end

  def sign_up_api_search_then_add_movie_to_list
    sign_up_with(email, username, "password")
    visit(api_search_path)
    api_search_for_movie

    select "my queue", :from => "listing[list_id]", match: :first
    VCR.use_cassette('tmdb_add_movie') do
      click_button "add_to_list_button_movies_partial", match: :first
    end
  end

  def api_movie_more_info
    VCR.use_cassette('tmdb_movie_more') do
      click_link "movie_more_link_movie_partial", match: :first
    end
  end

  def api_search_for_movie_then_movie_more
    sign_up_with(email, username, "password")
    visit(api_search_path)
    api_search_for_movie

    api_movie_more_info
  end

  def sign_in_and_create_list
    sign_in_user(user)
    # Navigate directly to new list page (no navigation click needed)
    visit new_user_list_path(user)
    fill_in "list_name_field", with: "test list one"
    click_button "Save"
    # Wait for list creation (case-insensitive to handle title case display)
    expect(page).to have_text(/test list one/i)
  end

  def api_actor_search
    VCR.use_cassette('tmdb_actor_search') do
      fill_in "actor", with: 'William H. Macy'
      click_button "Search"
    end
  end

  def api_actor_search_buscemi
    VCR.use_cassette('tmdb_actor_search_buschemi') do
      fill_in "actor", with: 'steve buscemi'
      click_button "Search"
    end
  end

  def bad_api_actor_search
    VCR.use_cassette('tmdb_bad_actor_search') do
      fill_in "actor", with: 'sjhskjhdf*s7'
      click_button "Search"
    end
  end

  def api_two_actor_search
    VCR.use_cassette('tmdb_two_actor_search') do
      fill_in "actor", with: 'Steve Buscemi'
      fill_in "actor2", with: 'John Goodman'
      click_button "Search"
    end
  end

  def bad_api_two_actor_search(actor1, actor2)
    VCR.use_cassette('tmdb_bad_two_actor_search') do
      fill_in "actor", with: actor1
      fill_in "actor2", with: actor2
      click_button "Search"
    end
  end

  def bad_api_search_for_movie
    VCR.use_cassette('tmdb_bad_movie_search') do
      fill_in "movie_title", with: 'zasdlkjfasdlkjf'
      click_button "Search"
    end
  end

end
