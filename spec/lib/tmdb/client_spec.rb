# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tmdb::Client do
  describe '.movie_autocomplete' do
    it 'returns a list of unique movie names' do
      parsed_data = {
        page: 1,
        results: [
          {:title=>'A'},
          {:title=>'A'},
          {:title=>'B'},
          {:title=>'C'}
        ]
      }
      allow(described_class).to receive(:get_parsed_movie_search_results).and_return(parsed_data)
      names = described_class.movie_autocomplete("doesn't matter")
      expect(names).to eq(['A', 'B', 'C'])
    end
  end

  describe '.person_autocomplete' do
    it 'returns a list of unique actor names' do
      parsed_data = {
        page: 1,
        results: [
          {:media_type=>"movie", :original_title=>"Jennifer Lopez: Dance Again"},
          {:media_type=>"person", :name=>"Jennifer Lopez"},
          {:media_type=>"person", :name=>"Jennifer Gray"}
        ]
      }
      allow(described_class).to receive(:get_parsed_multi_search_results).and_return(parsed_data)
      names = described_class.person_autocomplete("doesn't matter")
      expect(names).to eq(['Jennifer Lopez', 'Jennifer Gray'])
      expect(names).to_not include('Jennifer Lopez: Dance Again')
    end
  end

  # describe '.get_full_cast' do
  #   let(:parsed_data) do
  #     {
  #       page: 1,
  #       results: [
  #         {:media_type=>"movie", :original_title=>"Jennifer Lopez: Dance Again"},
  #         {:media_type=>"person", :name=>"Jennifer Lopez"},
  #         {:media_type=>"person", :name=>"Jennifer Gray"}
  #       ]
  #     }
  #   end
  #   before do
  #     allow(described_class).to receive(:fetch_parsed_response).and_return(parsed_data)
  #   end
  #
  #   xit 'returns movie data' do
  #   end
  #
  #   xit 'returns actor data' do
  #   end
  #
  #   xit 'returns director data' do
  #   end
  #
  #   xit 'returns editor data' do
  #   end
  # end

  describe '.person_detail_search' do
    let(:person_id) { '2387' }
    let(:person_bio_data) do
      {:name=>"Patrick Stewart",
       :biography=>"An English film, television and stage actor.",
       :birthday=>"1940-07-13",
       :deathday=>nil,
       :id=>person_id,
       :profile_path=>"/wEy5qSDT5jT3ZASc2hbwi59voPL.jpg"}
    end

    let(:person_movie_credit_data) do
      {
        id: person_id,
        cast: [
          {:adult=>false,
         :backdrop_path=>"/aBMLpWsWXPOoTnbK37VKuQA0q0s.jpg",
         :genre_ids=>[878, 28, 12, 53],
         :id=>193,
         :original_language=>"en",
         :original_title=>"Star Trek: Generations",
         :overview=>
          "Captain Jean-Luc Picard and the crew of the Enterprise-D find themselves at odds with the renegade scientist Soran who is destroying entire star systems. Only one man can help Picard stop Soran's scheme...and he's been dead for seventy-eight years.",
         :poster_path=>"/rHsCYDGHFUarGh5k987b0EFU6kC.jpg",
         :release_date=>"1994-11-18",
         :title=>"Star Trek: Generations",
         :video=>false,
         :vote_average=>6.5,
         :vote_count=>992,
         :popularity=>11.808,
         :character=>"Captain Jean-Luc Picard",
         :credit_id=>"52fe4225c3a36847f80076d9",
         :order=>0}],
       crew:[
         {:adult=>false,
          :backdrop_path=>"/xkgoxCfvLJeaA7LT7ewL9T0rMvC.jpg",
          :genre_ids=>[35],
          :id=>84340,
          :original_language=>"en",
          :original_title=>"Sleepwalk with Me",
          :overview=>
           "A burgeoning stand-up comedian struggles with the stress of a stalled career, a stale relationship, and the wild spurts of severe sleepwalking he is desperate to ignore.",
          :poster_path=>"/vs2wxfMrV48VWKTGbsYstIWrwI1.jpg",
          :release_date=>"2012-08-24",
          :title=>"Sleepwalk with Me",
          :video=>false,
          :vote_average=>6.6,
          :vote_count=>139,
          :popularity=>7.158,
          :credit_id=>"52fe48ed9251416c9109cf3b",
          :department=>"Directing",
          :job=>"Director"},
         {:poster_path=>"/9pbc44kltJhArUNyrdQcantMEvH.jpg",
          :video=>false,
          :vote_average=>6.4,
          :overview=>
           "When an alien race and factions within Starfleet attempt to take over a planet that has \"regenerative\" properties, it falls upon Captain Picard and the crew of the Enterprise to defend the planet's people as well as the very ideals upon which the Federation itself was founded.",
          :release_date=>"1998-12-11",
          :id=>200,
          :adult=>false,
          :backdrop_path=>"/goNk0VDnUjxKjB6o69kYS5vvZo2.jpg",
          :vote_count=>888,
          :genre_ids=>[878, 28, 12, 53],
          :title=>"Star Trek: Insurrection",
          :original_language=>"en",
          :original_title=>"Star Trek: Insurrection",
          :popularity=>17.228,
          :credit_id=>"52fe4226c3a36847f8007c1d",
          :department=>"Production",
          :job=>"Producer"},
        {:adult=>false,
         :backdrop_path=>"/llT1qYnBy0AC0F3EZbYl97knchI.jpg",
         :genre_ids=>[35],
         :id=>55804,
         :original_language=>"en",
         :original_title=>"What I Should Have Said Was Nothing",
         :overview=>
          "Mike says, \"A few years ago my therapist suggested I keep a journal of all the crazy things that were going on in my life, so that I could keep things in perspective. Around the same time audiences were demanding more material, and I realized that other people might enjoy these stories-so I started sending them out to my mailing list. Now, my Secret Public Journal has become a Comedy Central special and DVD for all the world to see. Not sure this is what my therapist had in mind.\"",
         :poster_path=>"/mRHqImaRNU096gEyiE0lMZqW5I4.jpg",
         :release_date=>"2008-02-09",
         :title=>"What I Should Have Said Was Nothing",
         :video=>false,
         :vote_average=>7.5,
         :vote_count=>31,
         :popularity=>3.845,
         :credit_id=>"52fe48e1c3a36847f817e659",
         :department=>"Writing",
         :job=>"Writer"},
       {:adult=>false,
         :backdrop_path=>"/wXNOOPJQjGm8NerPjjl8L3Xm50W.jpg",
         :genre_ids=>[35],
         :id=>18480,
         :original_language=>"en",
         :original_title=>"Brüno",
         :overview=>
          "Flamboyantly gay Austrian television reporter Bruno stirs up trouble with unsuspecting guests and large crowds through brutally frank interviews and painfully hilarious public displays of homosexuality.",
         :poster_path=>"/xLFYL5gwCPnMDp5Qmd5wiRSsRPX.jpg",
         :release_date=>"2009-07-08",
         :title=>"Brüno",
         :video=>false,
         :vote_average=>5.6,
         :vote_count=>1324,
         :popularity=>14.085,
         :credit_id=>"54c02fae9251416e9b0099ca",
         :department=>"Editing",
         :job=>"Editor"}
       ]
      }
    end

    let(:person_tv_credit_data) do
      {
        id: person_id,
        cast: [
          {:first_air_date=>"1953-03-18",
          :id=>27023,
          :name=>"The Oscars",
          :poster_path=>"/wF43fJ8D85i79ZrLZsnUZ2JurbP.jpg",
          :character=>"Self",
          :credit_id=>"52588354760ee3466140b6a5"}
        ],
        crew: [
          {:original_name=>"Kath & Kim",
           :id=>15131,
           :name=>"Kath & Kim",
           :vote_count=>2,
           :vote_average=>6.0,
           :first_air_date=>"2008-10-09",
           :poster_path=>"/oPoSygZTburk4aeyvV5lFE5T9GL.jpg",
           :genre_ids=>[35],
           :original_language=>"en",
           :backdrop_path=>"/cuqbFcvHnjFhMQNybyJ2CH8SHxK.jpg",
           :overview=>
            "Kath & Kim is an American version of the Australian television comedy series of the same name starring Selma Blair and Molly Shannon. The series premiered on NBC on October 9, 2008. The Australian version was created by its original stars, Jane Turner and Gina Riley, who also serve as executive producers and consultants on this version as well, which is co-produced through Reveille Productions and Universal Media Studios.\n\nIts first episode premiered in Australia on Sunday, October 12 on the Seven Network and its Australian broadcast was cancelled after the second episode the following week. The series was then pushed to a graveyard slot of 11pm Mondays, and then pre-empted for the 2009 Australian Open after the first-run airing of episode 9, \"Friends\". Although the show initially garnered unremarkable ratings and mixed reviews from critics, NBC picked up Kath & Kim for a full season order of 22 episodes on October 31, 2008. On January 15, 2009, NBC cut the episode order from 22 to 17 episodes. The show's season finale aired on March 12, 2009. On May 19, 2009, NBC confirmed the series cancellation.",
           :origin_country=>["US"],
           :popularity=>5.558,
           :credit_id=>"54c02fe39251416e9b0099d0",
           :department=>"Editing",
           :episode_count=>2,
           :job=>"Editor"},
          {:poster_path=>"/qIvBbZ1yq3tzIXKqhU3VxYPbizF.jpg",
          :first_air_date=>"2019-06-12",
          :id=>83074,
          :vote_average=>6.5,
          :overview=>
           "U.S. police chief Bill Hixon lands in the British town of Boston, Lincolnshire, with his 14-year-old daughter Kelsey in tow hoping they can flee their painful recent past. But this unfamiliar, unimpressed community will force Bill to question everything about himself and leave him asking whether it's Boston that needs Bill, or Bill that needs Boston?",
          :name=>"Wild Bill",
          :original_name=>"Wild Bill",
          :origin_country=>["GB"],
          :vote_count=>14,
          :genre_ids=>[18, 35, 80],
          :backdrop_path=>"/odsxbvsSi0tv3bI37b5gtU0BWen.jpg",
          :original_language=>"en",
          :popularity=>7.156,
          :credit_id=>"5bc198a792514179ca02822d",
          :department=>"Production",
          :episode_count=>6,
          :job=>"Executive Producer"},
          {:backdrop_path=>"/yYaxXMbobcB7PIM6XljZZk2x4FQ.jpg",
          :name=>"Saturday Night Live",
          :genre_ids=>[35, 10763],
          :original_name=>"Saturday Night Live",
          :origin_country=>["US"],
          :first_air_date=>"1975-10-11",
          :poster_path=>"/bfiBW2qtdPEdcDOhYGNiP8XX8ok.jpg",
          :id=>1667,
          :vote_average=>6.9,
          :overview=>"A late-night live television sketch ",
          :vote_count=>295,
          :original_language=>"en",
          :popularity=>78.621,
          :credit_id=>"52570fdb760ee3776a0b1a09",
          :department=>"Writing",
          :episode_count=>181,
          :job=>"Writer"},
          {:name=>"Laverne & Shirley",
          :original_name=>"Laverne & Shirley",
          :origin_country=>["US"],
          :vote_count=>44,
          :backdrop_path=>"/1zLn6Ou9dJ0jzrKtkPGZ95OIahc.jpg",
          :vote_average=>7.5,
          :genre_ids=>[35],
          :id=>3033,
          :original_language=>"en",
          :overview=>
           "American television sitcom that ran on ABC from January 27, 1976 to May 10, 1983.",
          :poster_path=>"/1w6v2Uq5qvjlFq3eQQLXxzAHvh9.jpg",
          :first_air_date=>"1976-01-27",
          :popularity=>19.368,
          :credit_id=>"52574b66760ee36aaa13c246",
          :department=>"Directing",
          :episode_count=>1,
          :job=>"Director"}
        ],
      }
    end

    before do
      allow(described_class).to receive(:get_parsed_person_bio).and_return(person_bio_data)
      allow(described_class).to receive(:get_parsed_person_movie_credits).and_return(person_movie_credit_data)
      allow(described_class).to receive(:get_parsed_person_tv_credits).and_return(person_tv_credit_data)
    end

    it 'returns a person_id' do
      person = described_class.person_detail_search(person_id)
      expect(person.person_id).to eq(person_id)
    end

    it 'returns profile data' do
      person = described_class.person_detail_search(person_id)
      expect(person.profile.person_id).to eq(person_id)
      expect(person.profile.name).to eq("Patrick Stewart")
      expect(person.profile.profile_path).to eq("/wEy5qSDT5jT3ZASc2hbwi59voPL.jpg")
      expect(person.profile.bio).to include("An English film")
      expect(person.profile.birthday).to eq("1940-07-13")
    end

    it 'returns movie credit data' do
      person = described_class.person_detail_search(person_id)
      expect(person.movie_credits).to be_instance_of(MoviePersonCredits)
      expect(person.movie_credits.actor.first.character).to eq("Captain Jean-Luc Picard")
      expect(person.movie_credits.directing.first.title).to eq('Sleepwalk with Me')
      expect(person.movie_credits.editing.first.credit_id).to eq('54c02fae9251416e9b0099ca')
      expect(person.movie_credits.writing.first.credit_id).to eq('52fe48e1c3a36847f817e659')
      expect(person.movie_credits.screenplay).to eq([])
      expect(person.movie_credits.producer.first.department).to eq('Production')
    end

    it 'returns tv credit data' do
      person = described_class.person_detail_search(person_id)
      expect(person.tv_credits).to be_instance_of(TVPersonCredits)
      expect(person.tv_credits.actor.first.character).to eq('Self')
      expect(person.tv_credits.directing.first.show_name).to eq('Laverne & Shirley')
      expect(person.tv_credits.editing.first.show_name).to eq('Kath & Kim')
      expect(person.tv_credits.writing.first.credit_id).to eq('52570fdb760ee3776a0b1a09')
      expect(person.tv_credits.screenplay).to eq([])
      expect(person.tv_credits.producer.first.show_name).to eq('Wild Bill')
    end
  end

  xdescribe '.update_movie' do
  end

  describe '.tv_actor_appearance_credits' do
    let(:parsed_credits) do
      {
        media: {
         :name=>"The Good Place",
         :id=>66573,
         :character=>"Doug Forcett",
         :episodes=>
          [{:air_date=>"2018-11-15",
            :episode_number=>8,
            :id=>1593085,
            :name=>"Don't Let The Good Life Pass You By",
            :overview=>"Michael and Janet visit the person.",
            :production_code=>"",
            :season_number=>3,
            :show_id=>66573,
            :still_path=>"/7wZBtiIlcTPekf3KiyKn1wwD6DQ.jpg",
            :vote_average=>7.526,
            :vote_count=>19}],
         :seasons=>
          [{:air_date=>"2018-09-27",
            :episode_count=>12,
            :id=>105508,
            :name=>"Season 3",
            :overview=>"",
            :poster_path=>"/3dJDT1dVSuHBYqWD0OLT1ZXeLq7.jpg",
            :season_number=>3,
            :show_id=>66573}]
        },
        person: {
          :name=>"Michael McKean",
          :id=>21731,
          :profile_path=>"/xuEZeuylzznJcf0nDs1RlvuzaPr.jpg",
          :known_for=>
          [{:backdrop_path=>"/hpU2cHC9tk90hswCFEpf5AtbqoL.jpg",
            :id=>456.0,
            :genre_ids=>[10751.0, 16.0, 35.0],
            :original_language=>"en",
            :media_type=>"tv",
            :poster_path=>"/tubgEpjTUA7t0kejVMBsNBZDarZ.jpg",
            :popularity=>765.151,
            :vote_count=>7531.0,
            :vote_average=>7.9,
            :original_name=>"The Simpsons",
            :origin_country=>["US"],
            :overview=>"Set in Springfield, the average American town.",
            :name=>"The Simpsons",
            :first_air_date=>"1989-12-17"}]
        }
      }
    end
    before do
      allow(described_class).to receive(:get_parsed_credit).and_return(parsed_credits)
    end

    it 'returns tv_actor_credit data' do
      person = described_class.tv_actor_appearance_credits('foo')
      expect(person).to be_instance_of(TVActorCredit)
      expect(person.actor_id).to eq(21731)
      expect(person.actor_name).to eq('Michael McKean')
      expect(person.character).to eq('Doug Forcett')
      expect(person.episodes.first.episode_number).to eq(8)
      expect(person.known_for.first[:name]).to eq('The Simpsons')
      expect(person.profile_path).to eq('/xuEZeuylzznJcf0nDs1RlvuzaPr.jpg')
      expect(person.show_id).to eq(66573)
      expect(person.show_name).to eq('The Good Place')
      expect(person.seasons.first.air_date).to eq('9/27/2018')
    end
  end

  describe '.tv_series_autocomplete' do
    let(:parsed_tv_search_results) do
      [ { :id=>2382, :name=>"Freaks and Geeks" },
        { :id=>97018, :name=>"Freaks!" } ]
    end

    it 'returns a list of only Series names' do
      allow(described_class).to receive(:get_parsed_tv_search_results).and_return(parsed_tv_search_results)
      suggestions = described_class.tv_series_autocomplete('foo')
      expect(suggestions).to eq(['Freaks and Geeks', 'Freaks!'])
    end
  end

  describe '.tv_series_search' do
    let(:parsed_tv_search_results) do
      [{
        :backdrop_path=>"/hpU2cHC9tk90hswCFEpf5AtbqoL.jpg",
        :first_air_date=>"1989-12-17",
        :genre_ids=>[10751, 16, 35],
        :id=>456,
        :name=>"The Simpsons",
        :origin_country=>["US"],
        :original_language=>"en",
        :original_name=>"The Simpsons",
        :overview=>"Set in Springfield.",
        :popularity=>707.512,
        :poster_path=>"/tubgEpjTUA7t0kejVMBsNBZDarZ.jpg",
        :vote_average=>7.9,
        :vote_count=>7536
      }]
    end
    before do
      allow(described_class).to receive(:get_parsed_tv_search_results).and_return(parsed_tv_search_results)
    end
    it 'returns an array of TVSeries objects with data' do
      series = described_class.tv_series_search('foo').first
      expect(series.show_id).to eq(456)
      expect(series.first_air_date).to eq('12/17/1989')
      expect(series.last_air_date).to eq(nil)
      expect(series.show_name).to eq('The Simpsons')
      expect(series.backdrop_path).to eq('/hpU2cHC9tk90hswCFEpf5AtbqoL.jpg')
      expect(series.poster_path).to eq('/tubgEpjTUA7t0kejVMBsNBZDarZ.jpg')
      expect(series.number_of_episodes).to eq(nil)
      expect(series.number_of_seasons).to eq(nil)
      expect(series.overview).to eq('Set in Springfield.')
      expect(series.seasons).to eq(nil)
      expect(series.actors).to eq(nil)
    end
  end

  describe 'tv_series' do
    let(:parsed_tv_search_results) do
      {
        :backdrop_path=>"/hpU2cHC9tk90hswCFEpf5AtbqoL.jpg",
        :first_air_date=>"1989-12-17",
        :genre_ids=>[10751, 16, 35],
        :id=>456,
        :name=>"The Simpsons",
        :number_of_seasons=>7,
        :origin_country=>["US"],
        :original_language=>"en",
        :original_name=>"The Simpsons",
        :overview=>"Set in Springfield.",
        :popularity=>707.512,
        :poster_path=>"/tubgEpjTUA7t0kejVMBsNBZDarZ.jpg",
        :vote_average=>7.9,
        :vote_count=>7536,
        credits: {
          cast: [
            {:adult=>false,
              :gender=>2,
              :id=>2387,
              :known_for_department=>"Acting",
              :name=>"Patrick Stewart",
              :original_name=>"Patrick Stewart",
              :popularity=>16.35,
              :profile_path=>"/5FBzMRNy65vV9RzibBBwW4p6lUq.jpg",
              :character=>"Jean-Luc Picard",
              :credit_id=>"52538dc019c2957940268e14",
              :order=>0}
          ]
        }
      }
    end
    before do
      allow(described_class).to receive(:get_parsed_tv_series_data).and_return(parsed_tv_search_results)
    end
    it 'returns a TVSeries object with data' do
      series = described_class.tv_series('foo')
      expect(series.show_id).to eq('foo')
      expect(series.first_air_date).to eq('12/17/1989')
      expect(series.last_air_date).to eq(nil)
      expect(series.show_name).to eq('The Simpsons')
      expect(series.backdrop_path).to eq('/hpU2cHC9tk90hswCFEpf5AtbqoL.jpg')
      expect(series.poster_path).to eq('/tubgEpjTUA7t0kejVMBsNBZDarZ.jpg')
      expect(series.number_of_episodes).to eq(nil)
      expect(series.number_of_seasons).to eq(7)
      expect(series.overview).to eq('Set in Springfield.')
      expect(series.seasons).to eq([1, 2, 3, 4, 5, 6, 7])
      expect(series.actors.first.name).to eq('Patrick Stewart')
    end
  end

  describe 'tv_season' do
    let(:tv_series) { build(:tv_series, show_id: 1) }
    let(:parsed_tv_season_data) do
      {
        :_id=>"52538d0319c2957940260d67",
        :air_date=>"1990-09-24",
        :id=>1991,
        :name=>"Season 4",
        :overview=>"Riker tries to save the Enterprise and the Earth",
        :production_code=>"40274-175",
        :season_number=>4,
        :still_path=>"/12345.jpg",
        :poster_path=>"/67891.jpg",
        :vote_average=>8.194,
        :vote_count=>31,
        credits: {
          cast: [
           {:adult=>false,
            :gender=>2,
            :id=>2388,
            :known_for_department=>"Acting",
            :name=>"Jonathan Frakes",
            :original_name=>"Jonathan Frakes",
            :popularity=>7.206,
            :profile_path=>"/koY6DtPAnuiJpdOW3bPHzmoC6cZ.jpg",
            :character=>"William T. Riker",
            :credit_id=>"52538dc019c2957940268e42",
            :order=>1},
          ],
        },
        :episodes=>
        [{:air_date=>"1990-09-30",
          :episode_number=>2,
          :crew=>
           [{:department=>"Directing",
             :job=>"Director",
             :credit_id=>"52538d0819c2957940261261",
             :adult=>false,
             :gender=>2,
             :id=>1219320,
             :known_for_department=>"Directing",
             :name=>"Cliff Bole",
             :original_name=>"Cliff Bole",
             :popularity=>0.771,
             :profile_path=>nil
           }],
        }]
      }
    end
    it 'returns a TVSeason object with data' do
      allow(described_class).to receive(:get_parsed_tv_season_data).and_return(parsed_tv_season_data)
      season = described_class.tv_season(series: tv_series, season_number: 'foo')

      expect(season.series.show_id).to eq(1)
      expect(season.show_id).to eq(1)
      expect(season.air_date).to eq('1990-09-24'.to_date)
      expect(season.name).to eq('Season 4')
      expect(season.overview).to eq('Riker tries to save the Enterprise and the Earth')
      expect(season.season_id).to eq(1991)
      expect(season.season_id).to eq(1991)
      expect(season.poster_path).to eq('/67891.jpg')
      expect(season.season_number).to eq(4)
      expect(season.credits[:cast].first[:name]).to eq('Jonathan Frakes')
      expect(season.cast_members.first.name).to eq('Jonathan Frakes')
      expect(season.episodes.first.air_date.to_s).to eq('1990-09-30')
    end
  end
end
