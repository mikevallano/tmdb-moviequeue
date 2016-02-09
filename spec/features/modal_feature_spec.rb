require 'rails_helper'

RSpec.feature "Modal feature spec", :type => :feature do

  feature "the specs can fucking pass" do

    let(:email) { FFaker::Internet.email }
    let(:username) { FFaker::Internet.user_name }
    let(:user1) { FactoryGirl.create(:user) }
    let(:user2) { FactoryGirl.create(:user) }
    let(:user3) { FactoryGirl.create(:user) }
    let(:movie1) { FactoryGirl.create(:movie) }
    let(:list1) { FactoryGirl.create(:list, name: "my queue", owner_id: user1.id) }
    let(:list) { FactoryGirl.create(:list, name: "awesome 90s", owner_id: user1.id) }
    let(:listing1) { FactoryGirl.create(:listing, list_id: list.id, movie_id: movie1.id) }
    let(:membership1) { FactoryGirl.create(:membership, list_id: list.id, member_id: user1.id) }
    let(:membership2) { FactoryGirl.create(:membership, list_id: list.id, member_id: user2.id) }
    let(:tag1) { FactoryGirl.create(:tag) }
    let(:tag2) { FactoryGirl.create(:tag, name: FFaker::DizzleIpsum.words(2).join(' ')) }
    let(:tagging1) { FactoryGirl.create(:tagging, tag_id: tag1.id, movie_id: movie1.id, user_id: user1.id) }
    let(:tagging2) { FactoryGirl.create(:tagging, tag_id: tag2.id, movie_id: movie1.id, user_id: user3.id) }

    scenario "user can click a fucking modal and mark a mofo as watched", js: true do
      skip "for now"
      movie1
      listing1
      sign_in_user(user1)
      visit(user_list_path(user1, list))
      click_link("modal_link_#{movie1.tmdb_id}")
      click_link("mark_watched_link_movies_partial")
      expect(page).to have_content("Times you've seen this movie")
      # select "High", :from => "priority"
      # click_button "add_priority_button_movies_partial"
      # expect(page).to have_content("High")
      # click_button("Close")
    end #scenario

    scenario "users can add a movie to their list", js: true do
      # sign_up_with(email, username, "password")
      list1
      sign_in_user(user1)
      visit(api_search_path)
      VCR.use_cassette('tmdb_search', :match_requests_on => [:body]) do
        fill_in "movie_title", with: 'fargo'
        click_button "search_by_title_button"
      end
      click_link("modal_link_275")
      expect(page).not_to have_content("my queue")
      select "my queue", :from => "listing[list_id]", match: :first
      VCR.use_cassette('tmdb_add_movie', :match_requests_on => [:body]) do
        click_button "add_to_list_button_movies_partial", match: :first
      end
      expect(page).to have_content("my queue")
    end

  end #feature
end #final