require "rails_helper"

RSpec.describe SuggestionsController, type: :request do
  let(:user) { create(:user, admin: admin) }

  before do
    allow_any_instance_of(SuggestionsController).to receive(:authenticate_user!).and_return(true)
    allow_any_instance_of(SuggestionsController).to receive(:current_user).and_return(user)
  end

  context "when the user is not an admin" do
    let(:admin) { false }

    it "redirects with an alert" do
      get movie_suggestions_path
      expect(response).to redirect_to root_path
      expect(flash[:alert]).to eq("Must be an admin to access that feature")
    end
  end

  context "when the user is an admin" do
    let(:admin) { true }

    it "shows the form without asking for suggestions" do
      expect(MovieSuggestionService).not_to receive(:get_suggestions)
      get movie_suggestions_path
      expect(response).to be_successful
    end

    it "asks for suggestions for the selected list and query" do
      list = create(:list, owner: user)
      results = OpenStruct.new(movies: [], not_found_message: "nothing")
      expect(MovieSuggestionService).to receive(:get_suggestions)
        .with(user: user, list: list, query: "lighter")
        .and_return(results)

      get movie_suggestions_path(list_id: list.id, query: " lighter ")
      expect(response).to be_successful
      expect(response.body).to include("nothing")
    end

    it "caps the query length" do
      results = OpenStruct.new(movies: [], not_found_message: "nothing")
      expect(MovieSuggestionService).to receive(:get_suggestions)
        .with(user: user, list: nil, query: "a" * SuggestionsController::MAX_QUERY_LENGTH)
        .and_return(results)

      get movie_suggestions_path(query: "a" * 2000)
    end
  end
end
