require "rails_helper"

RSpec.describe ExistingInviteMailer, type: :mailer do
let(:user) { FactoryGirl.create(:user) }
let(:list) { FactoryGirl.create(:list, owner_id: user.id) }
let(:invite) { FactoryGirl.create(:invite, sender_id: user.id, list_id: list.id) }
let(:mail) { ExistingInviteMailer.existing_invite_mailer(invite) }

  describe "invite mailer" do

    it "sends user a invite" do
      expect(mail.subject).to eq "You've been added to a shared movie list."
      expect(mail.from).to eq [user.email]
      expect(mail.to).to eq [invite.email]
      expect(mail.body.encoded).to include user_list_path(user, list)
    end
  end
end
