FactoryBot.define do
  factory :tv_actor_credit do
    sequence(:actor_id) { |n| n + 20 }
    sequence(:actor_name) { |n| "actor_name #{n}" }
    sequence(:character) { |n| "character #{n}" }
    sequence(:known_for) { |n| "known_for #{n}" }
    sequence(:profile_path) { |n| "profile_path_#{n}" }
    sequence(:show_id) { |n| n + 10 }
    sequence(:show_name) { |n| "show #{n}" }
    episodes do
      [{:id=>37065,
      :name=>"The Naked Now",
      :overview=>
       "Stardate: 41209.2. The crew of the Enterprise are infected with a virus contracted by the away team while they were investigating  the mysterious deaths of the entire crew of the Starship Tsilkovsky.",
      :media_type=>"tv_episode",
      :vote_average=>6.4,
      :vote_count=>57,
      :air_date=>"1987-10-05",
      :episode_number=>2,
      :episode_type=>"standard",
      :production_code=>"40271-103",
      :runtime=>46,
      :season_number=>1,
      :show_id=>655,
      :still_path=>"/ev3d6SQf7tPoOZ0bE778LlrPumJ.jpg"}]
    end
    seasons do
      [{:id=>1989,
      :name=>"Season 1",
      :overview=>
       "Picking up decades after the original Star Trek series, season one begins the intergalactic adventures of Capt. Jean-Luc Picard and his loyal crew aboard the all-new USS Enterprise NCC-1701D, as they explore new worlds.",
      :profile_path=>"/cqfhZiCBqryQjo7s0cqZJOssE7d.jpg",
      :media_type=>"tv_season",
      :vote_average=>6.5,
      :air_date=>"1987-09-28",
      :season_number=>1,
      :show_id=>655,
      :episode_count=>25}]
    end

    initialize_with do
      new(
        actor_id: actor_id,
        actor_name: actor_name,
        character: character,
        known_for: known_for,
        profile_path: profile_path,
        show_id: show_id,
        show_name: show_name,
        episodes: episodes,
        seasons: seasons,
      )
    end

    trait :with_episodes do 
      episodes do
        [{:id=>37065,
        :name=>"The Naked Now",
        :overview=>
        "Stardate: 41209.2. The crew of the Enterprise are infected with a virus contracted by the away team while they were investigating  the mysterious deaths of the entire crew of the Starship Tsilkovsky.",
        :media_type=>"tv_episode",
        :vote_average=>6.4,
        :vote_count=>57,
        :air_date=>"1987-10-05",
        :episode_number=>2,
        :episode_type=>"standard",
        :production_code=>"40271-103",
        :runtime=>46,
        :season_number=>1,
        :show_id=>655,
        :still_path=>"/ev3d6SQf7tPoOZ0bE778LlrPumJ.jpg"}]
      end
    end
  end
end
