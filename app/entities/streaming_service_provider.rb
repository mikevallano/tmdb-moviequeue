require "active_hash"

class StreamingServiceProvider < ActiveHash::Base
  def self.free
    where(pay_model: "free")
  end

  def self.rent
    where(pay_model: "rent")
  end

  def self.buy
    where(pay_model: "buy")
  end

  def self.maybe_available
    where(pay_model: "not_found")
  end
  
  def title_search_url(title)
    parameterized_title = title.parameterize(separator: '+')
    search_url + parameterized_title
  end
  
  # Find more providers at TMDB's watch_provider partner: https://www.justwatch.com/us
  self.data = [
    {
      id: "b9444a73-d374-45fd-8098-8d340b047d73",
      display_name: 'Amazon Prime',
      tmdb_provider_name: 'Amazon Prime Video',
      tmdb_provider_id: 9,
      pay_model: "not_found",
      search_url: "https://www.amazon.com/s?i=instant-video&k="
    },
    {
      id: "94fd2937-745b-4cbc-ac7a-a53fa1fdf1a6",
      display_name: 'Amazon',
      tmdb_provider_name: 'Amazon Video',
      tmdb_provider_id: 10,
      pay_model: "not_found",
      search_url: "https://www.amazon.com/s?i=instant-video&k="
    },
    {
      id: "b2c97df4-7178-4c05-bdcd-7a6e5794bd9c",
      display_name: 'Fandango',
      tmdb_provider_name: 'Fandango At Home',
      tmdb_provider_id: 7,
      pay_model: "not_found",
      search_url: "https://athome.fandango.com/content/movies/search?searchString="
    },
    {
      id: "7f7111d4-1c3e-40f6-8e85-dad04421ebf9",
      display_name: 'Hoopla',
      tmdb_provider_name: 'Hoopla',
      tmdb_provider_id: 212,
      pay_model: "not_found",
      search_url: "https://www.hoopladigital.com/search?scope=everything&type=direct&kindId=7&q="
    },
    {
      id: "10668b82-8717-4429-bbfd-4fa9a149c879",
      display_name: 'Kanopy',
      tmdb_provider_name: 'Kanopy',
      tmdb_provider_id: 191,
      pay_model: "not_found",
      search_url: "https://www.kanopy.com/?q="
    },
    {
      id: "5a871334-7e1c-4e3a-9d3c-ba4bf9a3bc7c",
      display_name: 'Netflix',
      tmdb_provider_name: 'Netflix',
      tmdb_provider_id: 8,
      pay_model: "not_found",
      search_url: "http://www.netflix.com/search/?q="
    },
    {
      id: "0c517786-369c-431f-8d45-4e72a26b1cb2",
      display_name: 'YouTube',
      tmdb_provider_name: 'YouTube',
      tmdb_provider_id: 192,
      pay_model: "not_found",
      search_url: "https://www.youtube.com/results?search_query="
    },
    {
      id: "ff90c3e0-d17b-401c-9697-b6b63753c489",
      display_name: 'Peacock',
      tmdb_provider_name: 'Peacock Premium',
      tmdb_provider_id: 386,
      pay_model: "not_found",
      search_url: "https://www.peacocktv.com/watch/search?q="
    },
    {
      id: "e7db9fe5-e21c-4bb4-96bb-3448a0837496",
      display_name: 'Peacock+',
      tmdb_provider_name: 'Peacock Premium Plus',
      tmdb_provider_id: 387,
      pay_model: "not_found",
      search_url: "https://www.peacocktv.com/watch/search?q="
    },
    {
      id: "9c963ab2-5622-4592-ab33-b51a3c6d8d17",
      display_name: 'VUDU',
      tmdb_provider_name: 'VUDU Free',
      tmdb_provider_id: 332,
      pay_model: "not_found",
      search_url: "https://athome.fandango.com/content/movies/search?searchString="
    }
  ]
end