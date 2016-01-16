require 'rails_helper'

RSpec.feature "Ratings feature spec", :type => :feature do

  feature "User can create a new rating" do

    let(:user) { FactoryGirl.create(:user) }
    let(:user2) { FactoryGirl.create(:user) }
    let(:movie) { FactoryGirl.create(:movie, tmdb_id: 275) }
    let(:list) { FactoryGirl.create(:list, owner_id: user.id) }
    let(:list2) { FactoryGirl.create(:list, owner_id: user2.id) }
    let(:listing) { FactoryGirl.create(:listing, list_id: list.id, movie_id: movie.id) }
    let(:listing2) { FactoryGirl.create(:listing, list_id: list2.id, movie_id: movie.id) }
    let(:rating) { FactoryGirl.create(:rating, user_id: user.id, movie_id: movie.id, value: 2) }

    context "From the movies show page" do

      scenario "users can only rate a movie once" do

        listing
        sign_in_user(user)
        click_link "my_movies_nav_link"
        click_link "movie_show_page"
        fill_in "rating_value_field", with: "5"
        click_button "rating_submit_button_rating_form"

        visit(new_movie_rating_path(movie))
        expect(page).to have_content("You've already rated this movie")
        url = URI.parse(current_url)
        expect("#{url}").to include("#{movie.slug}/ratings/#{movie.ratings.by_user(user).first.id}")

      end #end can only rate a movie once

      scenario "movie show page shows only the current user's rating" do

        listing
        sign_in_user(user)
        click_link "my_movies_nav_link"
        click_link "movie_show_page"
        fill_in "rating_value_field", with: "5"
        click_button "rating_submit_button_rating_form"
        click_link "sign_out_nav_link"

        listing2
        sign_in_user(user2)
        click_link "my_movies_nav_link"
        click_link "movie_show_page"
        expect(page).not_to have_selector("#existing_rating")
        click_link "sign_out_nav_link"

        sign_in_user(user)
        click_link "my_movies_nav_link"
        click_link "movie_show_page"
        expect(page).to have_selector("#existing_rating")


      end #only current user's rating

    end # movies show page context

  end #feature

end #final