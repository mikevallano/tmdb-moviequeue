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


    context 'from the list show page' do

      scenario 'users can create a new screening' do
        skip "need to update controller"

        listing
        list
        movie

        sign_in_user(user)
        visit(user_list_path(user, list))
        click_link "add_screening_link_movies_partial"
        fill_in "screening_notes", with: "epic notes"
        expect { click_link_or_button "screening_submit_button_screening_form" }.to change(Screening.by_user(user), :count).by(1)
        expect(page).to have_content("epic notes")

      end

      scenario 'users can view existing screenings for a movie' do

        screening
        listing
        list
        movie

        sign_in_user(user)
        visit(user_list_path(user, list))
        click_link "view_screenings_link_movies_partial"
        expect(page).to have_content("it was great")

      end

    end

  end #feature

end #final