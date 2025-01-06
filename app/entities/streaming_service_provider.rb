require "active_hash"

class StreamingServiceProvider < ActiveHash::Base
  field :search_url, default: ''

  def self.by_name
    order(tmdb_provider_name: :asc)
  end
  
  def title_search_url(title)
    parameterized_title = title.parameterize(separator: '+')
    search_url + parameterized_title
  end
  
  # Note: Find more providers at TMDB's watch_provider partner: https://www.justwatch.com/us
  # Note: to generate a unique uuid for new poses, run this in irb:
  # require 'securerandom'
  # SecureRandom.uuid
  self.data = [
    {
      id: "f9e44261-00f3-4bad-8b81-a772867fa663",
      display_name: 'Apple TV',
      tmdb_provider_name: "Apple TV",
      tmdb_provider_id: 2,
      tmdb_logo_path:"/9ghgSC0MA082EL6HLCW3GalykFD.jpg",
      search_url: 'https://tv.apple.com/search?term=',
    },
    {
      id: "b9444a73-d374-45fd-8098-8d340b047d73",
      display_name: 'Amazon Prime',
      tmdb_provider_name: 'Amazon Prime Video',
      tmdb_provider_id: 9,
      tmdb_logo_path: "/pvske1MyAoymrs5bguRfVqYiM9a.jpg",
      search_url: "https://www.amazon.com/s?i=instant-video&k="
    },
    {
      id: "94fd2937-745b-4cbc-ac7a-a53fa1fdf1a6",
      display_name: 'Amazon',
      tmdb_provider_name: 'Amazon Video',
      tmdb_provider_id: 10,
      tmdb_logo_path:"/seGSXajazLMCKGB5hnRCidtjay1.jpg",
      search_url: "https://www.amazon.com/s?i=instant-video&k="
    },
    {
      id: "a5b1e878-674b-4b95-8e34-a0f257450f72",
      display_name: "Amazon w/Ads",
      tmdb_provider_name: "Amazon Prime Video with Ads",
      tmdb_provider_id: 2100,
      tmdb_logo_path: "/8aBqoNeGGr0oSA85iopgNZUOTOc.jpg",
      search_url: "https://www.amazon.com/s?i=instant-video&k="
    },
    {
      id: "9e49a0de-fa13-4741-b21e-3e9fabc37b82",
      display_name: "Epix",
      tmdb_provider_name: "Epix Amazon Channel",
      tmdb_provider_id: 583,
      tmdb_logo_path: "/efu1Cqc63XrPBoreYnf2mn0Nizj.jpg",
      search_url: "https://www.amazon.com/s?i=instant-video&k="
    },
    {
      id: "b2c97df4-7178-4c05-bdcd-7a6e5794bd9c",
      display_name: 'Fandango',
      tmdb_provider_name: 'Fandango At Home',
      tmdb_provider_id: 7,
      tmdb_logo_path:"/19fkcOz0xeUgCVW8tO85uOYnYK9.jpg",
      search_url: "https://athome.fandango.com/content/movies/search?searchString="
    },
    {
      id: "7cd5b5bf-4a9f-4245-ba35-5a80a788cd50",
      display_name: "Freevee",
      tmdb_provider_name: "Freevee",
      tmdb_provider_id: 613,
      tmdb_logo_path: "/4VOCKZGiAtXMtoDyOrvHAN33uc2.jpg",
      search_url: "https://www.amazon.com/s?i=instant-video&k="
    },
    {
      id: "8d08da63-0975-43be-96c1-36557337f88c",
      display_name: 'FuboTV',
      tmdb_provider_name: "fuboTV",
      tmdb_provider_id: 257,
      tmdb_logo_path: "/9BgaNQRMDvVlji1JBZi6tcfxpKx.jpg",
      search_url: "https://www.fubo.tv/?"
    },
    {
      id: "0c129c49-1fbc-4d41-b9ec-0d8451d226b0",
      display_name: "Google Play",
      tmdb_provider_name: "Google Play Movies",
      tmdb_provider_id: 3,
      tmdb_logo_path:"/8z7rC8uIDaTM91X0ZfkRf04ydj2.jpg",
      search_url: "https://play.google.com/store/search?hl=en_US&q="
    },
    {
      id: "7f7111d4-1c3e-40f6-8e85-dad04421ebf9",
      display_name: 'Hoopla',
      tmdb_provider_name: 'Hoopla',
      tmdb_provider_id: 212,
      tmdb_logo_path: "/j7D006Uy3UWwZ6G0xH6BMgIWTzH.jpg",
      search_url: "https://www.hoopladigital.com/search?scope=everything&type=direct&kindId=7&q="
    },
    {
      id: "561fcd90-cc9a-4d5f-9026-2ecc2c430b98",  
      display_name: "Hulu",
      tmdb_provider_name: "Hulu",
      tmdb_provider_id: 15,
      tmdb_logo_path: "/bxBlRPEPpMVDc4jMhSrTf2339DW.jpg",
      search_url: "https://www.hulu.com/?"
    },
    {
      id: "10668b82-8717-4429-bbfd-4fa9a149c879",
      display_name: 'Kanopy',
      tmdb_provider_name: 'Kanopy',
      tmdb_provider_id: 191,
      tmdb_logo_path: "/vLZKlXUNDcZR7ilvfY9Wr9k80FZ.jpg",
      search_url: "https://www.kanopy.com/?q="
    },
    {
      id: "850bdf2c-d4da-4bec-ac8b-cd7b01058f65",
      display_name: "MGM+",
      tmdb_provider_name: "MGM Plus",
      tmdb_provider_id: 34,
      tmdb_logo_path: "/ctiRpS16dlaTXQBSsiFncMrgWmh.jpg",
      search_url: "https://www.mgmplus.com/search?query="
    },
    {
      id: "918b8a58-289b-481e-afe7-43a8cad56fd7",
      display_name: 'Microsoft',
      tmdb_provider_name: "Microsoft Store",
      tmdb_provider_id: 68,
      tmdb_logo_path:"/5vfrJQgNe9UnHVgVNAwZTy0Jo9o.jpg",
      search_url: "https://www.microsoft.com/en-us/search/explore?q="
    },
    {
      id: "892e3a04-7f0e-47ca-a41e-e6dbb5e084fd",
      display_name: "NBC",
      tmdb_provider_name: "NBC",
      tmdb_provider_id: 79,
      tmdb_logo_path: "/6hFf3sIdmXSAczy3i6tLSmy6gwK.jpg",
      search_url: "https://www.nbc.com/search"
    },
    {
      id: "5a871334-7e1c-4e3a-9d3c-ba4bf9a3bc7c",
      display_name: 'Netflix',
      tmdb_provider_name: 'Netflix',
      tmdb_provider_id: 8,
      tmdb_logo_path: "/pbpMk2JmcoNnQwx5JGpXngfoWtp.jpg",
      search_url: "http://www.netflix.com/search/?q="
    },
    {
      id: "6d480668-9fb1-4b1f-aa9b-69d60648b6d0",  
      display_name: "Netflix w/Ads",
      tmdb_provider_name: "Netflix basic with Ads",
      tmdb_provider_id: 1796,
      tmdb_logo_path: "/kICQccvOh8AIBMHGkBXJ047xeHN.jpg",
      search_url: "http://www.netflix.com/search/?q="
    },
    {
      id: "72a1e046-f9bb-4ec0-808f-2153ca9c18ca",
      display_name: "Paramount+",
      tmdb_provider_name: "Paramount Plus",
      tmdb_provider_id: 531,
      tmdb_logo_path: "/h5DcR0J2EESLitnhR8xLG1QymTE.jpg",
      search_url: "https://www.paramountplus.com/?="
    },
    {
      id: "d73f7843-408d-444f-a5d9-5efa4674b7ae",
      display_name: "Paramount+Apple",
      tmdb_provider_name: "Paramount Plus Apple TV Channel ",
      tmdb_provider_id: 1853,
      tmdb_logo_path: "/tJqmTmQ8jp9WfyaZfApHK8lSywA.jpg",
      search_url: "https://www.paramountplus.com/?="
    },
    {
      id: "86a96c00-d876-40e0-b247-b6be04e87886",
      display_name: "Paramount+Amazon",
      tmdb_provider_name: "Paramount+ Amazon Channel",
      tmdb_provider_id: 582,
      tmdb_logo_path: "/hExO4PtimLIYn3kBOrzsejNv7cT.jpg",
      search_url: "https://www.paramountplus.com/?="
    },
    {
      id: "ff90c3e0-d17b-401c-9697-b6b63753c489",
      display_name: 'Peacock',
      tmdb_provider_name: 'Peacock Premium',
      tmdb_provider_id: 386,
      tmdb_logo_path: "/6hFf3sIdmXSAczy3i6tLSmy6gwK.jpg",
      search_url: "https://www.peacocktv.com/watch/search?q="
    },
    {
      id: "e7db9fe5-e21c-4bb4-96bb-3448a0837496",
      display_name: 'Peacock+',
      tmdb_provider_name: 'Peacock Premium Plus',
      tmdb_provider_id: 387,
      tmdb_logo_path: "/drPlq5beqXtBaP7MNs8W616YRhm.jpg",
      search_url: "https://www.peacocktv.com/watch/search?q="
    },
    {
      id: "bbf23f2b-86e3-4635-bbba-a26ce48b14dc",
      display_name: 'Plex',
      tmdb_provider_name: "Plex",
      tmdb_provider_id: 538,
      tmdb_logo_path:"/vLZKlXUNDcZR7ilvfY9Wr9k80FZ.jpg",
      search_url: "https://www.plex.tv/watch-free/?="
    },
    {
      id: "59648bd5-d85d-435c-8cda-7f5c729ecb13",
      display_name: "Plex Channel",
      tmdb_provider_name: "Plex Channel",
      tmdb_provider_id: 2077,
      tmdb_logo_path: "/27WMfRN7pQE3j5Khm8fPM7vYyLV.jpg",
      search_url: "https://watch.plex.tv/live-tv/?="
    },
    {
      id: "1d407e04-4898-4e0d-a5fb-1b091c569855",
      display_name: "Public Domain",
      tmdb_provider_name: "Public Domain Movies",
      tmdb_provider_id: 638,
      tmdb_logo_path: "/aN0Y2BNZQBH91JkVOeLTs8IhQrH.jpg",
      search_url: "https://publicdomainmovie.net/?="
    },
    {
      id: "9c0c3dc0-de97-4649-8a33-dcc1635cb3f9",
      display_name: "Spectrum",
      tmdb_provider_name: "Spectrum On Demand",
      tmdb_provider_id: 486,
      tmdb_logo_path: "/aAb9CUHjFe9Y3O57qnrJH0KOF1B.jpg",
      search_url: "https://ondemand.spectrum.net/search/?q="
    },
    {
      id: "9c963ab2-5622-4592-ab33-b51a3c6d8d17",
      display_name: 'VUDU',
      tmdb_provider_name: 'VUDU Free',
      tmdb_provider_id: 332,
      tmdb_logo_path: "/6By0jm0Gr2WMOqUeHWhzRWaMdOo.jpg",
      search_url: "https://athome.fandango.com/content/movies/search?searchString="
    },
    {
      id: "0c517786-369c-431f-8d45-4e72a26b1cb2",
      display_name: 'YouTube',
      tmdb_provider_name: 'YouTube',
      tmdb_provider_id: 192,
      tmdb_logo_path:"/pTnn5JwWr4p3pG8H6VrpiQo7Vs0.jpg",
      search_url: "https://www.youtube.com/results?search_query="
    }
  ]
end
