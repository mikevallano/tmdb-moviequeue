require "rails_helper"

RSpec.describe ListsController, type: :request do
  let(:user) { create(:user, admin: admin) }
  let(:admin) { true }
  let(:list) { create(:list, owner: user) }
  let(:available_movie) { create(:movie, title: "Barbie") }
  let(:unavailable_movie) { create(:movie, title: "Oppenheimer") }
  let(:netflix_provider) { StreamingServiceProvider.find("5a871334-7e1c-4e3a-9d3c-ba4bf9a3bc7c") }
  let(:streaming_option) { MovieDataService::STREAMING_SORT_OPTION }

  before do
    allow_any_instance_of(ListsController).to receive(:authenticate_user!).and_return(true)
    allow_any_instance_of(ListsController).to receive(:current_user).and_return(user)
    user.user_streaming_service_providers.create(streaming_service_provider_id: netflix_provider.id)
    [available_movie, unavailable_movie].each { |movie| create(:listing, list: list, movie: movie, user: user) }
    allow(UserStreamingServiceProviderDataService).to receive(:check_availability_for_movies)
      .and_return(OpenStruct.new(available_ids: [available_movie.id], failed_ids: []))
  end

  describe "GET #show sorted by streaming availability" do
    it "only shows movies available on the user's streaming services" do
      get user_list_path(user, list, sort_by: streaming_option)
      expect(response.body).to include(available_movie.title)
      expect(response.body).not_to include(unavailable_movie.title)
    end

    it "shows an alert naming movies whose availability couldn't be checked" do
      allow(UserStreamingServiceProviderDataService).to receive(:check_availability_for_movies)
        .and_return(OpenStruct.new(available_ids: [available_movie.id], failed_ids: [unavailable_movie.id]))
      get user_list_path(user, list, sort_by: streaming_option)
      expect(response.body).to include("Couldn&#39;t check streaming availability for: Oppenheimer")
    end

    it "includes the streaming option in the sort dropdown" do
      get user_list_path(user, list)
      expect(response.body).to include(streaming_option)
    end

    context "when the user is not an admin" do
      let(:admin) { false }

      it "does not offer or apply the streaming filter" do
        expect(UserStreamingServiceProviderDataService).not_to receive(:check_availability_for_movies)
        get user_list_path(user, list, sort_by: streaming_option)
        expect(response.body).not_to include(%(value="#{streaming_option}"))
        expect(response.body).to include(unavailable_movie.title)
      end
    end

    context "when the user has no streaming providers" do
      before { user.user_streaming_service_providers.destroy_all }

      it "does not offer or apply the streaming filter" do
        expect(UserStreamingServiceProviderDataService).not_to receive(:check_availability_for_movies)
        get user_list_path(user, list, sort_by: streaming_option)
        expect(response.body).not_to include(%(value="#{streaming_option}"))
      end
    end

    context "when the list has more movies than the streaming filter allows" do
      before { stub_const("MovieDataService::STREAMING_FILTER_MAX_MOVIES", 1) }

      it "does not offer or apply the streaming filter" do
        expect(UserStreamingServiceProviderDataService).not_to receive(:check_availability_for_movies)
        get user_list_path(user, list, sort_by: streaming_option)
        expect(response.body).not_to include(%(value="#{streaming_option}"))
        expect(response.body).to include(unavailable_movie.title)
      end
    end
  end
end
