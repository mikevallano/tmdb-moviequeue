# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PersonDataService do
  let(:api) { Tmdb::Client }

  describe '.get_person_names' do
    it 'returns a list of unique actor names' do
      parsed_data = [
        { media_type: 'movie', original_title: 'Jennifer Lopez: Dance Again' },
        { media_type: 'person', name: 'Jennifer Lopez' },
        { media_type: 'person', name: 'Jennifer Gray' }
      ]
      allow(api).to receive(:request).and_return(results: parsed_data)
      names = described_class.get_person_names("doesn't matter")
      expect(names).to eq(['Jennifer Lopez', 'Jennifer Gray'])
      expect(names).to_not include('Jennifer Lopez: Dance Again')
    end
  end

  describe '.get_person_profile_data' do
    let(:person_id) { '2387' }
    let(:person_bio_data) do
      { name: 'Patrick Stewart',
        biography: 'An English film, television and stage actor.',
        birthday: '1940-07-13',
        deathday: nil,
        id: person_id,
        profile_path: '/wEy5qSDT5jT3ZASc2hbwi59voPL.jpg' }
    end

    let(:person_movie_credit_data) do
      {
        id: person_id,
        cast: [
          { adult: false,
            backdrop_path: '/aBMLpWsWXPOoTnbK37VKuQA0q0s.jpg',
            genre_ids: [878, 28, 12, 53],
            id: 193,
            original_language: 'en',
            original_title: 'Star Trek: Generations',
            overview: "Captain Jean-Luc Picard and the crew of the Enterprise-D find themselves at odds with the renegade scientist Soran who is destroying entire star systems. Only one man can help Picard stop Soran's scheme...and he's been dead for seventy-eight years.",
            poster_path: '/rHsCYDGHFUarGh5k987b0EFU6kC.jpg',
            release_date: '1994-11-18',
            title: 'Star Trek: Generations',
            video: false,
            vote_average: 6.5,
            vote_count: 992,
            popularity: 11.808,
            character: 'Captain Jean-Luc Picard',
            credit_id: '52fe4225c3a36847f80076d9',
            order: 0 }
        ],
        crew: [
          { adult: false,
            backdrop_path: '/xkgoxCfvLJeaA7LT7ewL9T0rMvC.jpg',
            genre_ids: [35],
            id: 84340,
            original_language: 'en',
            original_title: 'Sleepwalk with Me',
            overview: 'A burgeoning stand-up comedian struggles with the stress of a stalled career, a stale relationship, and the wild spurts of severe sleepwalking he is desperate to ignore.',
            poster_path: '/vs2wxfMrV48VWKTGbsYstIWrwI1.jpg',
            release_date: '2012-08-24',
            title: 'Sleepwalk with Me',
            video: false,
            vote_average: 6.6,
            vote_count: 139,
            popularity: 7.158,
            credit_id: '52fe48ed9251416c9109cf3b',
            department: 'Directing',
            job: 'Director' },
          { poster_path: '/9pbc44kltJhArUNyrdQcantMEvH.jpg',
            video: false,
            vote_average: 6.4,
            overview: "When an alien race and factions within Starfleet attempt to take over a planet that has \"regenerative\" properties, it falls upon Captain Picard and the crew of the Enterprise to defend the planet's people as well as the very ideals upon which the Federation itself was founded.",
            release_date: '1998-12-11',
            id: 200,
            adult: false,
            backdrop_path: '/goNk0VDnUjxKjB6o69kYS5vvZo2.jpg',
            vote_count: 888,
            genre_ids: [878, 28, 12, 53],
            title: 'Star Trek: Insurrection',
            original_language: 'en',
            original_title: 'Star Trek: Insurrection',
            popularity: 17.228,
            credit_id: '52fe4226c3a36847f8007c1d',
            department: 'Production',
            job: 'Producer' },
          { adult: false,
            backdrop_path: '/llT1qYnBy0AC0F3EZbYl97knchI.jpg',
            genre_ids: [35],
            id: 55804,
            original_language: 'en',
            original_title: 'What I Should Have Said Was Nothing',
            overview: 'Mike says, "A few years ago my therapist suggested I keep a journal of all the crazy things that were going on in my life, so that I could keep things in perspective. Around the same time audiences were demanding more material, and I realized that other people might enjoy these stories-so I started sending them out to my mailing list. Now, my Secret Public Journal has become a Comedy Central special and DVD for all the world to see. Not sure this is what my therapist had in mind."',
            poster_path: '/mRHqImaRNU096gEyiE0lMZqW5I4.jpg',
            release_date: '2008-02-09',
            title: 'What I Should Have Said Was Nothing',
            video: false,
            vote_average: 7.5,
            vote_count: 31,
            popularity: 3.845,
            credit_id: '52fe48e1c3a36847f817e659',
            department: 'Writing',
            job: 'Writer' },
          { adult: false,
            backdrop_path: '/wXNOOPJQjGm8NerPjjl8L3Xm50W.jpg',
            genre_ids: [35],
            id: 18480,
            original_language: 'en',
            original_title: 'Brüno',
            overview: 'Flamboyantly gay Austrian television reporter Bruno stirs up trouble with unsuspecting guests and large crowds through brutally frank interviews and painfully hilarious public displays of homosexuality.',
            poster_path: '/xLFYL5gwCPnMDp5Qmd5wiRSsRPX.jpg',
            release_date: '2009-07-08',
            title: 'Brüno',
            video: false,
            vote_average: 5.6,
            vote_count: 1324,
            popularity: 14.085,
            credit_id: '54c02fae9251416e9b0099ca',
            department: 'Editing',
            job: 'Editor' }
        ]
      }
    end

    let(:person_tv_credit_data) do
      {
        id: person_id,
        cast: [
          { first_air_date: '1953-03-18',
            id: 27023,
            name: 'The Oscars',
            poster_path: '/wF43fJ8D85i79ZrLZsnUZ2JurbP.jpg',
            character: 'Self',
            credit_id: '52588354760ee3466140b6a5' }
        ],
        crew: [
          { original_name: 'Kath & Kim',
            id: 15131,
            name: 'Kath & Kim',
            vote_count: 2,
            vote_average: 6.0,
            first_air_date: '2008-10-09',
            poster_path: '/oPoSygZTburk4aeyvV5lFE5T9GL.jpg',
            genre_ids: [35],
            original_language: 'en',
            backdrop_path: '/cuqbFcvHnjFhMQNybyJ2CH8SHxK.jpg',
            overview: "Kath & Kim is an American version of the Australian television comedy series of the same name starring Selma Blair and Molly Shannon. The series premiered on NBC on October 9, 2008. The Australian version was created by its original stars, Jane Turner and Gina Riley, who also serve as executive producers and consultants on this version as well, which is co-produced through Reveille Productions and Universal Media Studios.\n\nIts first episode premiered in Australia on Sunday, October 12 on the Seven Network and its Australian broadcast was cancelled after the second episode the following week. The series was then pushed to a graveyard slot of 11pm Mondays, and then pre-empted for the 2009 Australian Open after the first-run airing of episode 9, \"Friends\". Although the show initially garnered unremarkable ratings and mixed reviews from critics, NBC picked up Kath & Kim for a full season order of 22 episodes on October 31, 2008. On January 15, 2009, NBC cut the episode order from 22 to 17 episodes. The show's season finale aired on March 12, 2009. On May 19, 2009, NBC confirmed the series cancellation.",
            origin_country: ['US'],
            popularity: 5.558,
            credit_id: '54c02fe39251416e9b0099d0',
            department: 'Editing',
            episode_count: 2,
            job: 'Editor' },
          { poster_path: '/qIvBbZ1yq3tzIXKqhU3VxYPbizF.jpg',
            first_air_date: '2019-06-12',
            id: 83074,
            vote_average: 6.5,
            overview: "U.S. police chief Bill Hixon lands in the British town of Boston, Lincolnshire, with his 14-year-old daughter Kelsey in tow hoping they can flee their painful recent past. But this unfamiliar, unimpressed community will force Bill to question everything about himself and leave him asking whether it's Boston that needs Bill, or Bill that needs Boston?",
            name: 'Wild Bill',
            original_name: 'Wild Bill',
            origin_country: ['GB'],
            vote_count: 14,
            genre_ids: [18, 35, 80],
            backdrop_path: '/odsxbvsSi0tv3bI37b5gtU0BWen.jpg',
            original_language: 'en',
            popularity: 7.156,
            credit_id: '5bc198a792514179ca02822d',
            department: 'Production',
            episode_count: 6,
            job: 'Executive Producer' },
          { backdrop_path: '/yYaxXMbobcB7PIM6XljZZk2x4FQ.jpg',
            name: 'Saturday Night Live',
            genre_ids: [35, 10763],
            original_name: 'Saturday Night Live',
            origin_country: ['US'],
            first_air_date: '1975-10-11',
            poster_path: '/bfiBW2qtdPEdcDOhYGNiP8XX8ok.jpg',
            id: 1667,
            vote_average: 6.9,
            overview: 'A late-night live television sketch ',
            vote_count: 295,
            original_language: 'en',
            popularity: 78.621,
            credit_id: '52570fdb760ee3776a0b1a09',
            department: 'Writing',
            episode_count: 181,
            job: 'Writer' },
          { name: 'Laverne & Shirley',
            original_name: 'Laverne & Shirley',
            origin_country: ['US'],
            vote_count: 44,
            backdrop_path: '/1zLn6Ou9dJ0jzrKtkPGZ95OIahc.jpg',
            vote_average: 7.5,
            genre_ids: [35],
            id: 3033,
            original_language: 'en',
            overview: 'American television sitcom that ran on ABC from January 27, 1976 to May 10, 1983.',
            poster_path: '/1w6v2Uq5qvjlFq3eQQLXxzAHvh9.jpg',
            first_air_date: '1976-01-27',
            popularity: 19.368,
            credit_id: '52574b66760ee36aaa13c246',
            department: 'Directing',
            episode_count: 1,
            job: 'Director' }
        ]
      }
    end

    before do
      allow(api).to receive(:request).with(:person_data, person_id: person_id).and_return(person_bio_data)
      allow(api).to receive(:request).with(:person_movie_credits, person_id: person_id).and_return(person_movie_credit_data)
      allow(api).to receive(:request).with(:person_tv_credits, person_id: person_id).and_return(person_tv_credit_data)
    end

    it 'returns a person_id' do
      person = described_class.get_person_profile_data(person_id)
      expect(person.person_id).to eq(person_id)
    end

    it 'returns profile data' do
      person = described_class.get_person_profile_data(person_id)
      expect(person.profile.person_id).to eq(person_id)
      expect(person.profile.name).to eq('Patrick Stewart')
      expect(person.profile.profile_path).to eq('/wEy5qSDT5jT3ZASc2hbwi59voPL.jpg')
      expect(person.profile.bio).to include('An English film')
      expect(person.profile.birthday).to eq('1940-07-13')
    end

    it 'returns movie credit data' do
      person = described_class.get_person_profile_data(person_id)
      expect(person.movie_credits).to be_instance_of(MoviePersonCredits)
      expect(person.movie_credits.actor.first.character).to eq('Captain Jean-Luc Picard')
      expect(person.movie_credits.directing.first.title).to eq('Sleepwalk with Me')
      expect(person.movie_credits.editing.first.credit_id).to eq('54c02fae9251416e9b0099ca')
      expect(person.movie_credits.writing.first.credit_id).to eq('52fe48e1c3a36847f817e659')
      expect(person.movie_credits.screenplay).to eq([])
      expect(person.movie_credits.producer.first.department).to eq('Production')
    end

    it 'returns tv credit data' do
      person = described_class.get_person_profile_data(person_id)
      expect(person.tv_credits).to be_instance_of(TVPersonCredits)
      expect(person.tv_credits.actor.first.character).to eq('Self')
      expect(person.tv_credits.directing.first.show_name).to eq('Laverne & Shirley')
      expect(person.tv_credits.editing.first.show_name).to eq('Kath & Kim')
      expect(person.tv_credits.writing.first.credit_id).to eq('52570fdb760ee3776a0b1a09')
      expect(person.tv_credits.screenplay).to eq([])
      expect(person.tv_credits.producer.first.show_name).to eq('Wild Bill')
    end
  end
end
