require 'rails_helper'

RSpec.describe InvitesController, type: :controller do

  let(:user1) { FactoryBot.create(:user) }
  let(:user2) { FactoryBot.create(:user) }
  let(:list) { FactoryBot.create(:list) }
  let(:receiver_email) { FFaker::Internet.email }
  let(:invite) { FactoryBot.build(:invite, list_id: list.id, email: receiver_email, sender_id: user1.id) }
  let(:invalid_invite) { FactoryBot.build(:invalid_invite, list_id: list.id, sender_id: user1.id) }
  let(:current_user) { login_with user1 }
  let(:invalid_user) { login_with nil }
  let(:valid_attributes) { invite.attributes }
  let(:invalid_attributes) { invalid_invite.attributes }


  context "with a logged in user" do
    before(:each) do
      current_user
    end

    describe "POST #create" do
      context "with valid params" do
        it "creates a new Invite" do
          expect {
            post :create, { :invite => valid_attributes }
          }.to change(Invite, :count).by(1)
        end

        it "assigns a newly created invite as @invite" do
          post :create, { :invite => valid_attributes }
          expect(assigns(:invite)).to be_a(Invite)
          expect(assigns(:invite)).to be_persisted
        end

        it "redirects to the created invite" do
          post :create, :invite => valid_attributes
          expect(response).to redirect_to(user_list_path(invite.sender, invite.list))
        end
      end #valid params context

      context "with invalid params" do
        it "redirects the user back to the list page" do
          post :create, { :invite => invalid_attributes }
          expect(response).to redirect_to(user_list_path(invite.sender, invite.list))
        end
      end #invalid params context
    end #create action
  end #logged in user context

  context "without a logged in user" do

    before(:each) do
      invalid_user
    end

    describe "POST #create" do
      context "with valid params" do
        before(:example) do
         post :create, :invite => valid_attributes
        end
        it { is_expected.to redirect_to new_user_session_path }
      end

      context "with invalid params" do
        before(:example) do
          post :create, :invite => invalid_attributes
        end
        it { is_expected.to redirect_to new_user_session_path }
      end
    end
  end #without logged in user context

end