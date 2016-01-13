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

      scenario "users can create a rating" do

        listing
        sign_in_user(user)
        click_link "my_movies_nav_link"
          VCR.use_cassette('movie_show_page') do
            click_link "movie_show_page"
          end
        click_link "new_rating_link_movie_show"
        fill_in 'Value', with: "9"

        expect { click_button "Create Rating" }.to change(Rating.by_user(user), :count).by(1)
        expect(page).to have_content("successfully")
        expect(page).to have_content("9")

      end #end create rating scenario

      scenario "users can only rate a movie once" do

        listing
        sign_in_user(user)
        click_link "my_movies_nav_link"
        click_link "movie_show_page"
        click_link "new_rating_link_movie_show"
        fill_in 'Value', with: "9"

        expect { click_button "Create Rating" }.to change(Rating.by_user(user), :count).by(1)
        expect(page).to have_content("successfully")
        expect(page).to have_content("9")

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
        click_link "new_rating_link_movie_show"
        fill_in 'Value', with: "9"
        click_button "Create Rating"
        click_link "sign_out_nav_link"

        listing2
        sign_in_user(user2)
        click_link "my_movies_nav_link"
        click_link "movie_show_page"
        expect(page).not_to have_content("9")
        click_link "sign_out_nav_link"

        sign_in_user(user)
        click_link "my_movies_nav_link"
        click_link "movie_show_page"
        expect(page).to have_content("9")


      end #only current user's rating

    end # movies show page context

    context 'from the list show page' do

      scenario "users can create a rating" do

        list
        listing
        movie

        sign_in_user(user)
        visit(user_list_path(user, list))
        click_link "Rate this movie"
        fill_in 'Value', with: "9"

        expect { click_button "Create Rating" }.to change(Rating.by_user(user), :count).by(1)
        expect(page).to have_content("successfully")
        expect(page).to have_content("9")

      end #end create rating scenario

      scenario "users can see their existing rating" do

        list
        movie
        listing
        rating

        sign_in_user(user)
        visit(user_list_path(user, list))

        expect(page).to_not have_content("new_rating_link_list_show")
        expect(page).to have_content("My Rating")
        expect(page).to have_content("2")

      end #end see existing rating


    end #list show page context

  end #feature

end #final