require 'rails_helper'

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
      click_link "movies"
      click_link "Show"

      expect { click_link_or_button "Mark as watched" }.to change(Screening.by_user(user), :count).by(1)
      expect(page).to have_content("successfully")
      expect(page).to have_content("been watched")

    end #end mark movie as watched scenario

    scenario "users can create a screening" do

      listing
      sign_in_user(user)
      click_link "movies"
      click_link "Show"
      click_link "add a screening"
      fill_in "Notes", with: "epic notes"
      expect { click_link_or_button "Create Screening" }.to change(Screening.by_user(user), :count).by(1)

    end #create screening scenario

    scenario "users can view a screening from the movie show page" do

      listing
      sign_in_user(user)
      click_link "movies"
      click_link "Show"
      click_link "add a screening"
      fill_in "Notes", with: "epic notes"
      expect { click_link_or_button "Create Screening" }.to change(Screening.by_user(user), :count).by(1)
      click_link "view my screenings"
      expect(page).to have_content("epic notes")

    end #view screening scenario

  end #movie show page

  context 'from the list show page' do

    scenario 'users can mark a movie as watched' do

      listing
      list
      movie

      sign_in_user(user)
      visit(list_path(list))
      expect { click_link_or_button "Mark as watched" }.to change(Screening.by_user(user), :count).by(1)

    end

    scenario 'users can see movies that have been marked as watched' do

      screening
      listing
      list
      movie

      sign_in_user(user)
      visit(list_path(list))
      expect(page).to have_content("Been watched.")
      expect(page).not_to have_content("Mark as watched")

    end

    scenario 'users can create a new screening' do

      listing
      list
      movie

      sign_in_user(user)
      visit(list_path(list))
      click_link("Add a screening")
      fill_in "Notes", with: "epic notes"
      expect { click_link_or_button "Create Screening" }.to change(Screening.by_user(user), :count).by(1)
      click_link "view my screenings"
      expect(page).to have_content("epic notes")

    end

    scenario 'users can view existing screenings for a movie' do

      screening
      listing
      list
      movie

      sign_in_user(user)
      visit(list_path(list))
      click_link("View my screenings")
      expect(page).to have_content("it was great")

    end

  end


end #feature

