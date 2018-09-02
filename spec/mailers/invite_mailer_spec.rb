require "rails_helper"

RSpec.describe InviteMailer, type: :mailer do

let(:user) { FactoryBot.create(:user) }
let(:invite) { FactoryBot.create(:invite, sender_id: user.id) }
let(:mail) { InviteMailer.new_invite_mailer(invite) }

  describe "invite mailer" do

    it "sends user a invite" do
      expect(mail.subject).to eq "Movies are better watched together."
      expect(mail.from).to eq [user.email]
      expect(mail.to).to eq [invite.email]
      expect(mail.body.encoded).to include new_user_registration_url(:token => invite.token)
    end
  end
end