require 'rails_helper'

RSpec.describe Tagging, type: :model do
  let(:tagging) { FactoryBot.create(:tagging) }

  context "with a valid factory" do
    it "has a valid factory" do
      expect(tagging).to be_valid
    end

    it { is_expected.to belong_to(:movie) }
    it { is_expected.to belong_to(:tag) }
    it { is_expected.to belong_to(:user) }

  end #valid factory context

  describe '.create_taggings' do
    let(:user) { FactoryBot.create(:user) }
    let(:movie) { FactoryBot.create(:movie) }
    let(:tag_names) { user.taggings.where(movie: movie).map { |tagging| tagging.tag.name } }

    it 'truncates tag names longer than the max length' do
      described_class.create_taggings('a' * (Tag::MAX_NAME_LENGTH + 10), movie.id, user)

      expect(tag_names).to eq(['a' * Tag::MAX_NAME_LENGTH])
    end

    it 'skips blank tag names' do
      described_class.create_taggings('funny, ,scary,', movie.id, user)

      expect(tag_names).to contain_exactly('funny', 'scary')
    end
  end
end
