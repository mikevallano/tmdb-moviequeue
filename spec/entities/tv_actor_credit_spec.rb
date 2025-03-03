# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TVActorCredit, type: :model do
  let(:actor_id) { 1234 }

  describe "in_main_cast?" do
    context "when there is a character but there are no episodes" do
      let(:tv_actor_credit) { build(:tv_actor_credit, episodes: [], actor_id: actor_id, character: "foo") }
      
      it "returns true" do
        expect(tv_actor_credit.in_main_cast?).to eq(true)
      end
    end

    context "when there is a character and there are episodes" do
      let(:tv_actor_credit) { build(:tv_actor_credit, :with_episodes, actor_id: actor_id, character: "foo") }
      
      context "and the person appears in the series cast credits" do
        before { allow(TVSeriesDataService).to receive(:get_tv_series_data).and_return(series_data) }
        
        let(:series_data) { OpenStruct.new( actors: [OpenStruct.new(actor_id: actor_id)]) }
       
        it "returns true" do
          expect(tv_actor_credit.in_main_cast?).to eq(true)
        end
      end

      context "and the person does not appear in the series cast credits" do
        before { allow(TVSeriesDataService).to receive(:get_tv_series_data).and_return(series_data) }
        
        let(:series_data) { OpenStruct.new( actors: [OpenStruct.new(actor_id: other_actor_id)]) }
        let(:other_actor_id) { 5678 }
       
        it "returns false" do
          expect(tv_actor_credit.in_main_cast?).to eq(false)
        end
      end
    end

    context "when there is no character" do
      let(:tv_actor_credit) { build(:tv_actor_credit, :with_episodes, actor_id: actor_id, character: "") }
      
      it "returns false" do
        expect(tv_actor_credit.in_main_cast?).to eq(false)
      end
    end
  end
end
