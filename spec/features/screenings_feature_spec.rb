require 'rails_helper'

RSpec.feature "Screenings feature spec", :type => :feature do

  feature "User can create a new screening" do

    let(:user) { FactoryGirl.create(:user) }
    let(:user2) { FactoryGirl.create(:user) }
    let(:movie) { FactoryGirl.create(:movie) }
    let(:list) { FactoryGirl.create(:list, owner_id: user.id) }
    let(:list2) { FactoryGirl.create(:list, owner_id: user2.id) }
    let(:listing) { FactoryGirl.create(:listing, list_id: list.id, movie_id: movie.id) }
    let(:listing2) { FactoryGirl.create(:listing, list_id: list2.id, movie_id: movie.id) }
    let(:screening) { FactoryGirl.create(:screening, user_id: user.id, movie_id: movie.id, notes: "it was great") }

    context "from the movie show page" do

      scenario "users can mark a movie as watched" do

        listing
        sign_in_user(user)
        click_link "my_movies_nav_link"
        click_link "movie_show_page"

        expect { click_link "mark_watched_link_movie_show" }.to change(Screening.by_user(user), :count).by(1)
        expect(page).not_to have_selector("#mark_watched_link_movie_show")

      end #end mark movie as watched scenario

      scenario "users can create a screening" do

        listing
        sign_in_user(user)
        click_link "my_movies_nav_link"
        click_link "movie_show_page"
        click_link "add_screening_link_movie_show"
        fill_in "Notes", with: "epic notes"
        expect { click_link_or_button "screening_submit_button_screening_form" }.to change(Screening.by_user(user), :count).by(1)

      end #create screening scenario

      scenario "users can view a screening from the movie show page" do

        listing
        sign_in_user(user)
        click_link "my_movies_nav_link"
        click_link "movie_show_page"
        click_link "add_screening_link_movie_show"
        fill_in "screening_notes", with: "epic notes"
        expect { click_link_or_button "screening_submit_button_screening_form" }.to change(Screening.by_user(user), :count).by(1)
        click_link "view_screenings_link_movie_show"
        expect(page).to have_content("epic notes")

      end #view screening scenario

    end #movie show page

    context 'from the list show page' do

      scenario 'users can mark a movie as watched' do

        listing
        list
        movie

        sign_in_user(user)
        visit(user_list_path(user, list))
        expect { click_link "mark_watched_link_list_show" }.to change(Screening.by_user(user), :count).by(1)

      end

      scenario 'users can see movies that have been marked as watched' do

        screening
        listing
        list
        movie

        sign_in_user(user)
        visit(user_list_path(user, list))
        expect(page).to have_content("you've seen this movie")
        expect(page).not_to have_selector("#mark_watched_link_list_show")

      end

      scenario 'users can create a new screening' do

        listing
        list
        movie

        sign_in_user(user)
        visit(user_list_path(user, list))
        click_link "add_screening_link_list_show"
        fill_in "screening_notes", with: "epic notes"
        expect { click_link_or_button "screening_submit_button_screening_form" }.to change(Screening.by_user(user), :count).by(1)
        click_link "view_screenings_link_movie_show"
        expect(page).to have_content("epic notes")

      end

      scenario 'users can view existing screenings for a movie' do

        screening
        listing
        list
        movie

        sign_in_user(user)
        visit(user_list_path(user, list))
        click_link "view_screenings_link_list_show"
        expect(page).to have_content("it was great")

      end

    end

  end #feature

end #final