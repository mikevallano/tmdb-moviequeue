require 'rails_helper'

RSpec.feature "Reviews feature spec", :type => :feature do

  feature "User can create a new review" do

    let(:user) { FactoryGirl.create(:user) }
    let(:user2) { FactoryGirl.create(:user) }
    let(:movie) { FactoryGirl.create(:movie) }
    let(:list) { FactoryGirl.create(:list, owner_id: user.id) }
    let(:list2) { FactoryGirl.create(:list, owner_id: user2.id) }
    let(:listing) { FactoryGirl.create(:listing, list_id: list.id, movie_id: movie.id) }
    let(:listing2) { FactoryGirl.create(:listing, list_id: list2.id, movie_id: movie.id) }
    let(:review) { FactoryGirl.create(:review, user_id: user.id, movie_id: movie.id, body: "an epic win") }

    context "from the movie show page" do

      scenario "users can create a review" do

        listing
        sign_in_user(user)
        click_link "movies"
        click_link "Movie show page"
        click_link "Review this movie"
        fill_in 'Body', with: "OMG. best. movie. eva."

        expect { click_button 'Create Review' }.to change(Review.by_user(user), :count).by(1)
        expect(page).to have_content("successfully")
        expect(page).to have_content("OMG. best. movie. eva.")

      end #end create review scenario

      scenario "users can only review a movie once" do

        listing
        sign_in_user(user)
        click_link "movies"
        click_link "Movie show page"
        click_link "Review this movie"
        fill_in 'Body', with: "OMG. best. movie. eva."

        expect { click_button 'Create Review' }.to change(Review.by_user(user), :count).by(1)
        visit(new_movie_review_path(movie))
        expect(page).to have_content("You've already reviewed this movie")
        url = URI.parse(current_url)
        expect("#{url}").to include("#{movie.slug}/reviews/#{movie.reviews.by_user(user).first.id}")

      end #end can only review a movie once

      scenario "movie show page shows only the current user's review" do

        listing
        sign_in_user(user)
        click_link "movies"
        click_link "Movie show page"
        click_link "Review this movie"
        fill_in 'Body', with: "OMG. best. movie. eva."
        click_button 'Create Review'
        click_link "Sign Out"

        listing2
        sign_in_user(user2)
        click_link "movies"
        click_link "Movie show page"
        expect(page).not_to have_content("OMG")
        click_link "Sign Out"

        sign_in_user(user)
        click_link "movies"
        click_link "Movie show page"
        expect(page).to have_content("OMG")


      end #only current user's review

    end #end from movie show page

    context 'from the list show page' do

      scenario 'can add a review from the list show page' do

        listing
        list
        movie

        sign_in_user(user)
        visit(user_list_path(user, list))
        click_link "Review this movie"
        fill_in 'Body', with: "Epic win!"
        click_button "Create Review"
        expect(page).to have_content("success")

      end

      scenario 'user sees existing review on the list show page' do

        listing
        list
        movie
        review

        sign_in_user(user)
        visit(user_list_path(user, list))
        expect(page).not_to have_content("Review this movie")
        expect(page).to have_content("My Review")
        expect(page).to have_content("an epic win")


      end

    end #from list show page

  end # feature end

end #final