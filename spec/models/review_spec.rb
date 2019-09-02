require 'rails_helper'

RSpec.describe Review, type: :model do
  let(:user) { FactoryBot.create(:user) }
  let(:movie) { FactoryBot.create(:movie) }
  let(:review) { FactoryBot.build(:review, user: user, movie: movie) }
  let(:review2) { FactoryBot.create(:review, user_id: user.id, movie_id: movie.id) }
  let(:review3) { FactoryBot.build(:review, user_id: user.id, movie_id: movie.id) }
  let(:invalid_review) { FactoryBot.build(:invalid_review) }

  it { is_expected.to validate_presence_of(:body) }
  it { is_expected.to validate_presence_of(:movie) }

  context "with a valid factory" do
    it "has a valid factory" do
      expect(review).to be_valid
    end

    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:movie) }

  end #valid factory context

  it "is invalid without a name" do
    expect(invalid_review).not_to be_valid
  end

  it "does not allow a user to review a movie more than once" do
    review2
    expect(review3).not_to be_valid
  end
end
