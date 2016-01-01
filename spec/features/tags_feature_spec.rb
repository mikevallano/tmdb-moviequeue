require 'rails_helper'

RSpec.feature "Tags feature spec", :type => :feature do

  feature "User can create a new tag" do

    let(:user) { FactoryGirl.create(:user) }
    let(:email) { FFaker::Internet.email }
    let(:username) { FFaker::Internet.user_name }
    let(:list) { FactoryGirl.create(:list, owner_id: user.id) }
    let(:tag) { FactoryGirl.create(:tag, name: "hilarious") }

    context "with signed in user" do

      scenario "users can tag a movie" do

        sign_up_with(email, username, "password")
        visit(api_search_path)
        api_search_for_movie
        api_more_info
        all('#new_listing option')[0].select_option
        VCR.use_cassette('tmdb_add_movie') do
          click_button("add movie to list")
        end
        click_link("movies")
        fill_in "tag_list", with: "dark comedy, spooky"
        click_button("add tags", match: :first)
        expect(page).to have_content("added")
        expect(page).to have_content("dark-comedy")
        expect(page).to have_content("spooky")

      end #user can tag movie

    scenario "users can click a tag to see movies with that tag" do

      sign_up_with(email, username, "password")
      visit(api_search_path)
      api_search_for_movie
      api_more_info
      all('#new_listing option')[0].select_option
      VCR.use_cassette('tmdb_add_movie') do
        click_button("add movie to list")
      end
      click_link("movies")
      fill_in "tag_list", with: "dark comedy, spooky"
      click_button("add tags", match: :first)
      click_link("spooky", match: :first)
      expect(page).to have_content("Fargo")

    end #user can tag movie

    describe "pagination" do
      it "should paginate the movies by tag" do
        sign_in_user(user)
        30.times { FactoryGirl.create(:movie) }
        counter = Movie.first.id
        30.times do
          FactoryGirl.create(:listing, list_id: list.id, movie_id: Movie.find(counter).id)
          counter += 1
        end
        counter = Movie.first.id
        30.times do
          FactoryGirl.create(:tagging, movie_id: Movie.find(counter).id, user_id: user.id, tag_id: tag.id)
          counter += 1
        end
        visit movies_path
        click_link("hilarious", match: :first)
        expect(page).to have_content("Next")
        click_link("Next")
        expect(page).to have_content("Previous")
        expect(page).not_to have_link("Next")
      end
      Movie.destroy_all
      Tagging.destroy_all
      Listing.destroy_all
    end

    end #signed in user context

  end

end #final