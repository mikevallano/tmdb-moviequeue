require 'rails_helper'

RSpec.feature "Memberships feature spec", :type => :feature do

  feature "User can access lists and movies they're members of" do

    let(:user1) { FactoryGirl.create(:user) }
    let(:user2) { FactoryGirl.create(:user) }
    let(:user3) { FactoryGirl.create(:user) }
    let(:movie1) { FactoryGirl.create(:movie) }
    let(:list) { FactoryGirl.create(:list, name: "awesome 90s", owner_id: user1.id) }
    let(:listing1) { FactoryGirl.create(:listing, list_id: list.id, movie_id: movie1.id) }
    let(:membership1) { FactoryGirl.create(:membership, list_id: list.id, member_id: user1.id) }
    let(:membership2) { FactoryGirl.create(:membership, list_id: list.id, member_id: user2.id) }
    let(:tag1) { FactoryGirl.create(:tag) }
    let(:tag2) { FactoryGirl.create(:tag, name: FFaker::Color.name) }
    let(:tagging1) { FactoryGirl.create(:tagging, tag_id: tag1.id, movie_id: movie1.id, user_id: user1.id) }
    let(:tagging2) { FactoryGirl.create(:tagging, tag_id: tag2.id, movie_id: movie1.id, user_id: user3.id) }


    before(:each) do
      user1
      user2
      movie1
      list
      listing1
      membership1
      membership2
      tagging1
      tagging2
    end


    scenario "users can see their own lists that have members" do

      sign_in_user(user1)
      click_link("Lists")
      expect(page).to have_content("awesome 90s")
      visit(user_list_path(user1, list))
      expect(page).to have_content("awesome 90s")

    end

    scenario "users can see others' lists they're a member of" do

      sign_in_user(user2)
      click_link("Lists")
      expect(page).to have_content("awesome 90s")
      visit(user_list_path(user1, list))
      expect(page).to have_content("awesome 90s")

    end


    scenario "users can see other members' tags but not other users' tags" do

      sign_in_user(user2)
      visit(user_list_path(user1, list))
      expect(page).to have_content(tag1.name)
      expect(page).not_to have_content(tag2.name)

    end

    scenario "users can click other member's tags and see tagged movies" do

      sign_in_user(user2)
      visit(user_list_path(user1, list))
      click_link(tag1.name)
      expect(page).to have_content(movie1.title)

    end

  end

end #final