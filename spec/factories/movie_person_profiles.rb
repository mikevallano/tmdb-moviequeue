FactoryBot.define do
  factory :movie_person_profile do
    sequence(:person_id) { |n| n + 10 }
    sequence(:profile_path) { |n| "profile_path_#{n}" }
    sequence(:name) { |n| "name #{n}" }
    sequence(:bio) { |n| "#{MoviePersonProfile::WIKIPEDIA_CREDIT[:starting]} \r\nbio #{n}\n\r#{MoviePersonProfile::WIKIPEDIA_CREDIT[:trailing]}" }
    birthday { '2000-01-28' }

    initialize_with do
      new(person_id: person_id,
          profile_path: profile_path,
          name: name,
          bio: bio,
          birthday: birthday)
    end
  end
end
