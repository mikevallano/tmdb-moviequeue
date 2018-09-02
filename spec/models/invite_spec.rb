require 'rails_helper'

RSpec.describe Invite, type: :model do
  let(:invite) { FactoryBot.build(:invite) }
  let(:invalid_invite) { FactoryBot.build(:invalid_invite) }
  let(:invalid_email_invite) { FactoryBot.build(:invalid_email_invite) }

  context "with a valid factory" do

    it "has a valid factory" do
      expect(invite).to be_valid
    end
  end #valid factory context

  context 'with an invalid factory' do

    it { is_expected.to validate_presence_of(:email) }

    it "has an invalid factory" do
      expect(invalid_invite).not_to be_valid
    end

    it "validates format of email" do
      expect(invalid_email_invite).not_to be_valid
    end

  end


end #final
