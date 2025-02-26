# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TVActorCredit, type: :model do
  describe "in_main_cast?" do
    context "when there is no character and there are episodes" do
      let(:tv_actor_credit) { build(:tv_actor_credit, :with_episodes, character: "") }
      
      it "returns false" do
        expect(tv_actor_credit.in_main_cast?).to eq(false)
      end
    end

    context "when there is no character and there are no episodes" do
      let(:tv_actor_credit) { build(:tv_actor_credit, episodes: [], character: "") }
      
      it "returns false" do
        expect(tv_actor_credit.in_main_cast?).to eq(false)
      end
    end

    context "when there is a character and there are episodes" do
      let(:tv_actor_credit) { build(:tv_actor_credit, :with_episodes, character: "foo") }
      
      it "returns false" do
        expect(tv_actor_credit.in_main_cast?).to eq(false)
      end
    end

    context "when there is a character but there are no episodes" do
      let(:tv_actor_credit) { build(:tv_actor_credit, episodes: [], character: "foo") }
      
      it "returns true" do
        expect(tv_actor_credit.in_main_cast?).to eq(true)
      end
    end
  end
end
