FactoryBot.define do
  factory :movie_person_profile do
    sequence(:person_id) { |n| n + 10 }
    sequence(:profile_path) { |n| "profile_path_#{n}" }
    sequence(:name) { |n| "name #{n}" }
    sequence(:bio) { |n| "#{MoviePersonProfile::WIKIPEDIA_CREDIT[:starting]} \r\nbio #{n}\n\r#{MoviePersonProfile::WIKIPEDIA_CREDIT[:trailing]}" }
    birthday { '2000-01-28' }
    deathday { '2020-02-15' }

    initialize_with do
      new(person_id: person_id,
          profile_path: profile_path,
          name: name,
          bio: bio,
          birthday: birthday,
          deathday: deathday)
    end

    factory :living_movie_person_profile do
      name { 'Brad Pitt' }
      birthday { '1963-12-18' }
      deathday { nil }
    end

    factory :deceased_movie_person_profile do
      name { 'Judy Garland' }
      birthday { '1922-06-10' }
      deathday { '1969-06-22' }
    end

  end

end
