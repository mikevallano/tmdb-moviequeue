module FeatureHelpers

  def sign_up_with(email, username, password)
    visit root_path

    click_link "sign_up_nav_link"

    fill_in "user_email", with: email
    fill_in "user_username", with: username
    fill_in "user_password", with: password
    fill_in "user_password_confirmation", with: password
    click_button "sign_up_button_new_registration"
    visit user_confirmation_path(:confirmation_token => User.last.confirmation_token)
    visit new_user_session_path
    fill_in "user_login", with: email
    fill_in "user_password", with: password
    click_button "log_in_button_new_session"
    @email = email
    @current_user = User.find_by_email(email)
  end

  def sign_in_user(user)
    visit root_path
    click_link "sign_in_nav_link"
    sleep 0.25
    fill_in "user_login", with: user.email
    find("#user_password")
    fill_in "user_password", with: user.password
    click_button "log_in_button_new_session"
    sleep 0.25
    @current_user = User.find_by_email(user.email)
  end

  def api_search_for_movie
    VCR.use_cassette('fill_in_title_search') do
      fill_in "movie_title", with: 'Fargo'
    end
     VCR.use_cassette('tmdb_search') do
      click_button "search_by_title_button"
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
    click_link "my_lists_nav_link"
    click_link "new_list_link_list_index"
    fill_in "list_name_field", with: "test list one"
    click_button "submit_list_button"
  end

  def api_actor_search
    VCR.use_cassette('tmdb_actor_search') do
      fill_in "actor_name_actor_search", with: 'William H. Macy'
      click_button "submit_button_actor_search"
    end
  end

  def api_actor_search_buscemi
    VCR.use_cassette('tmdb_actor_search_buschemi') do
      fill_in "actor_name_actor_search", with: 'steve buscemi'
      click_button "submit_button_actor_search"
    end
  end

  def bad_api_actor_search
    VCR.use_cassette('tmdb_bad_actor_search') do
      fill_in "actor_name_actor_search", with: 'sjhskjhdf*s7'
      click_button "submit_button_actor_search"
    end
  end

  def api_two_actor_search
    VCR.use_cassette('tmdb_two_actor_search') do
      fill_in "actor1_field_two_actor_search", with: 'Steve Buscemi'
      fill_in "actor2_field_two_actor_search", with: 'John Goodman'
      click_button "search_button_two_actor_search"
    end
  end

  def bad_api_two_actor_search(actor1, actor2)
    VCR.use_cassette('tmdb_bad_two_actor_search') do
      fill_in "actor1_field_two_actor_search", with: actor1
      fill_in "actor2_field_two_actor_search", with: actor2
      click_button "search_button_two_actor_search"
    end
  end

  def bad_api_search_for_movie
    VCR.use_cassette('tmdb_bad_movie_search') do
      fill_in "movie_title", with: 'zasdlkjfasdlkjf'
      click_button "search_by_title_button"
    end
  end

end
