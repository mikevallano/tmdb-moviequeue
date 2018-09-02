require 'rails_helper'

RSpec.describe Rating, type: :model do
  let(:user) { FactoryBot.create(:user) }
  let(:movie) { FactoryBot.create(:movie) }
  let(:rating) { FactoryBot.build(:rating) }
  let(:rating2) { FactoryBot.create(:rating, user_id: user.id, movie_id: movie.id ) }
  let(:rating3) { FactoryBot.build(:rating, user_id: user.id, movie_id: movie.id) }
  let(:invalid_rating) { FactoryBot.build(:invalid_rating) }

  it { is_expected.to validate_presence_of(:value) }
  it { is_expected.to validate_presence_of(:user_id) }
  it { is_expected.to validate_presence_of(:movie) }

  context "with a valid factory" do
    it "has a valid factory" do
      expect(rating).to be_valid
    end

    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:movie) }

  end #valid factory context

  context "with an invalid factory" do

    it "is invalid without a value" do
      expect(invalid_rating).not_to be_valid
    end

    it "is does not allow a user to rate a movie more than once" do
      rating2
      expect(rating3).not_to be_valid
    end

  end #invalid factory context
end