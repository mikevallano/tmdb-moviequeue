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
      fill_in "invite_email", with: receiver_email
      expect { click_button "send_invite_button_list_show" }.to change(Invite, :count).by(1)
      expect(page).to have_content("sent")

    end

    context "sending invites to non-existing users" do

      scenario "invite mailer sends correct info and link" do

        sign_in_and_send_invite

        open_email(receiver_email)
        expect(current_email).to have_content("Sign up")

      end

      scenario "user can receive an invite, then sign up and be a member of that list" do

        sign_in_and_send_invite

        open_email(receiver_email)
        current_email.click_link "sign_up_link_invite_mailer"

        #email field is already populated with reciever_email
        fill_in "user_username", with: username
        fill_in "user_password", with: "password"
        fill_in "user_password_confirmation", with: "password"
        click_button "sign_up_button_new_registration"
        open_email(receiver_email)
        current_email.click_link "Confirm my account"
        # visit user_confirmation_path(:confirmation_token => User.last.confirmation_token)
        # visit new_user_session_path
        fill_in "user_login", with: username
        fill_in "user_password", with: "password"
        click_button "log_in_button_new_session"

        expect(page).to have_content("success")

        click_link "my_lists_nav_link"
        expect(page).to (have_content(list.name.titlecase))
        expect(User.last.all_lists).to include list

      end

    end #non-existing users context

    context "sending invites to existing users" do

      scenario "invite mailer sends correct info and link" do

        sign_in_user(user1)
        visit(user_list_path(user1, list))
        fill_in "invite_email", with: user2.email
        click_button "send_invite_button_list_show"

        open_email(user2.email)
        expect(current_email).to have_content("Check out the list")
        expect(last_email.body.encoded).to include user_list_path(user1, Invite.last.list)

      end

      scenario "user can receive an invite, then sign up and be a member of that list" do

        sign_in_user(user1)
        visit(user_list_path(user1, list))
        fill_in "invite_email", with: user2.email
        click_button "send_invite_button_list_show"
        click_link "sign_out_nav_link"

        sign_in_user(user2)
        visit(user_list_path(user1, Invite.last.list))

        click_link "my_lists_nav_link"
        expect(page).to (have_content(list.name.titlecase))
        expect(user2.all_lists).to include list

      end

    end #existing user context

  end

end