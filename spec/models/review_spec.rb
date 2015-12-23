require 'rails_helper'

RSpec.describe Review, type: :model do
  let(:user) { FactoryGirl.create(:user) }
  let(:movie) { FactoryGirl.create(:movie) }
  let(:review) { FactoryGirl.build(:review) }
  let(:review2) { FactoryGirl.create(:review, user_id: user.id, movie_id: movie.id) }
  let(:review3) { FactoryGirl.build(:review, user_id: user.id, movie_id: movie.id) }
  let(:invalid_review) { FactoryGirl.build(:invalid_review) }

  it { is_expected.to validate_presence_of(:body) }

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