require 'rails_helper'

RSpec.feature "Memberships feature spec", type: :feature, feature: :true do

  feature "User can access lists and movies they're members of" do

    let(:user1) { FactoryBot.create(:user) }
    let(:user2) { FactoryBot.create(:user) }
    let(:user3) { FactoryBot.create(:user) }
    let(:movie1) { FactoryBot.create(:movie) }
    let(:list) { FactoryBot.create(:list, owner_id: user1.id) }
    let(:listing1) { FactoryBot.create(:listing, list_id: list.id, movie_id: movie1.id) }
    let(:membership1) { FactoryBot.create(:membership, list_id: list.id, member_id: user1.id) }
    let(:membership2) { FactoryBot.create(:membership, list_id: list.id, member_id: user2.id) }
    let(:tag1) { FactoryBot.create(:tag) }
    let(:tag2) { FactoryBot.create(:tag, name: SecureRandom.urlsafe_base64(5)) }
    let(:tagging1) { FactoryBot.create(:tagging, tag_id: tag1.id, movie_id: movie1.id, user_id: user1.id) }
    let(:tagging2) { FactoryBot.create(:tagging, tag_id: tag2.id, movie_id: movie1.id, user_id: user3.id) }


    context "without JS" do
      before(:each) do
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
        visit user_lists_path(user1)
        expect(page).to have_content("#{list.name.titlecase}")
        # visit(user_list_path(user1, list))
        click_link list.name.titlecase, match: :first
        expect(page).to have_content("#{list.name}")
      end

      scenario "users can see others' lists they're a member of" do
        sign_in_user(user2)
        visit user_lists_path(user1)
        expect(page).to have_content("#{list.name.titlecase}")
        visit(user_list_path(user1, list))
        expect(page).to have_content("#{list.name}")
      end

      scenario "members can't edit a list unless they are the owner" do
        sign_in_user(user2)
        visit(edit_user_list_path(user1, list))
        expect(current_url).to eq(user_list_url(user1, list))
        expect(page).to have_content("Only list owners can edit lists")
      end

      scenario "members can't delete a list unless they are the owner" do
        sign_in_user(user2)
        visit(user_lists_path(user2))
        expect(page).not_to have_selector("#destroy_list_link_list_index")
      end

    end #without JS

  end
end #final
