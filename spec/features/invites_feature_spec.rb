require 'rails_helper'

RSpec.feature "Invites feature spec", :type => :feature do

  feature "User can send an invite to another user" do

    let(:user1) { FactoryGirl.create(:user) }
    let(:user2) { FactoryGirl.create(:user) }
    let(:username) { FFaker::Internet.user_name }
    let(:receiver_email) { FFaker::Internet.email }
    let(:list) { FactoryGirl.create(:list, owner_id: user1.id) }


    scenario "users can send invite" do

      sign_in_user(user1)
      visit(user_list_path(user1, list))
      fill_in "Email", with: receiver_email
      expect { click_button 'Send invite' }.to change(Invite, :count).by(1)
      expect(page).to have_content("sent")

    end

    context "sending invites to non-existing users" do

      scenario "invite mailer sends correct info and link" do

        sign_in_user(user1)
        visit(user_list_path(user1, list))
        fill_in "Email", with: receiver_email
        click_button "Send invite"

        expect(last_email).to have_content("To: #{receiver_email}")
        expect(last_email.to).to eq([receiver_email])
        expect(last_email.from).to eq([user1.email])
        expect(last_email.body.encoded).to include new_user_registration_path(:token =>
            Invite.last.token)

      end

      scenario "user can receive an invite, then sign up and be a member of that list" do

        sign_in_user(user1)
        visit(user_list_path(user1, list))
        fill_in "Email", with: receiver_email
        click_button "Send invite"
        click_link "Sign Out"

        visit new_user_registration_path(:token => Invite.last.token)

        fill_in "Username", with: username
        fill_in "Password", with: "password"
        fill_in "Password confirmation", with: "password"
        click_link_or_button 'Sign up'
        visit user_confirmation_path(:confirmation_token => User.last.confirmation_token)
        visit new_user_session_path
        fill_in 'Sign in with email or username', with: username
        fill_in 'Password', with: "password"
        click_button 'Log in'

        expect(page).to have_content("success")

        click_link "Lists"
        expect(page).to (have_content(list.name))
        expect(User.last.all_lists).to include list

      end

    end #non-existing users context

    context "sending invites to existing users" do

      scenario "invite mailer sends correct info and link" do

        sign_in_user(user1)
        visit(user_list_path(user1, list))
        fill_in "Email", with: user2.email
        click_button "Send invite"

        expect(last_email).to have_content("To: #{user2.email}")
        expect(last_email.to).to eq([user2.email])
        expect(last_email.from).to eq([user1.email])
        expect(last_email.body.encoded).to include user_list_path(user1, Invite.last.list)

      end

      scenario "user can receive an invite, then sign up and be a member of that list" do

        sign_in_user(user1)
        visit(user_list_path(user1, list))
        fill_in "Email", with: user2.email
        click_button "Send invite"
        click_link "Sign Out"

        sign_in_user(user2)
        visit(user_list_path(user1, Invite.last.list))

        click_link "Lists"
        expect(page).to (have_content(list.name))
        expect(user2.all_lists).to include list

      end

    end #existing user context

  end

end