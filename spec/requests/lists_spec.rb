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

    context "when the list has more than one page of movies" do
      let(:page_two_movie) { create(:movie, title: "Page Two Movie") }
      let(:page_one_movies) { create_list(:movie, 20) }

      before do
        create(:listing, list: list, movie: page_two_movie, user: user, created_at: 1.year.ago)
        page_one_movies.each { |movie| create(:listing, list: list, movie: movie, user: user) }
        [available_movie, unavailable_movie].each { |movie| Listing.find_by(movie: movie).update!(created_at: 2.years.ago) }

        allow(UserStreamingServiceProviderDataService).to receive(:check_availability_for_movies) do |movies:, **|
          OpenStruct.new(available_ids: movies.map(&:id) & [available_movie.id, page_two_movie.id], failed_ids: [])
        end
      end

      it "only checks the movies on the current page" do
        get user_list_path(user, list, sort_by: streaming_option, page: 2)
        expect(UserStreamingServiceProviderDataService).to have_received(:check_availability_for_movies)
          .with(user: user, movies: match_array([page_two_movie, available_movie, unavailable_movie]))
        expect(response.body).to include("Page Two Movie", "Barbie")
        expect(response.body).not_to include("Oppenheimer")
      end

      it "uses from_page from the sort form when there's no page param" do
        get user_list_path(user, list, sort_by: streaming_option, from_page: 2)
        expect(response.body).to include("Page Two Movie")
      end

      it "keeps pagination links for the unfiltered pages, preserving the filter" do
        get user_list_path(user, list, sort_by: streaming_option, from_page: 2)
        page_one_link = Nokogiri::HTML(response.body).css(".pagination a").find { |link| link.text == "1" }
        query = Rack::Utils.parse_query(URI(page_one_link[:href]).query)
        expect(query).to include("sort_by" => streaming_option, "page" => "1")
      end

      it "sends the current page with the sort form" do
        get user_list_path(user, list, page: 2)
        expect(response.body).to include(%(name="from_page" id="from_page" value="2"))
      end

      it "sends the filtered page with the sort form" do
        get user_list_path(user, list, sort_by: streaming_option, from_page: 2)
        expect(response.body).to include(%(name="from_page" id="from_page" value="2"))
      end

      it "does not send the current page when sorted by something else" do
        get user_list_path(user, list, sort_by: "title", page: 2)
        expect(response.body).not_to include(%(name="from_page"))
      end

      it "explains when nothing on the page is available" do
        get user_list_path(user, list, sort_by: streaming_option)
        expect(response.body).to include("None of the movies on this page are on your streaming services.")
      end
    end
  end
end
