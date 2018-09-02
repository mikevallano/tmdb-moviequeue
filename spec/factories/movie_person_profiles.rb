FactoryBot.define do
  factory :movie_person_profile do
    sequence(:person_id) { |n| n + 10 }
    sequence(:profile_path) { |n| "profile_path_#{n}" }
    sequence(:name) { |n| "name #{n}" }
    sequence(:bio) { |n| "bio #{n}" }
    sequence(:birthday_and_age) { |n| "birthday_and_age #{n}" }

    initialize_with { new(person_id: person_id, name: name, bio: bio, birthday_and_age: birthday_and_age, profile_path: profile_path) }

    # factory :invalid_invite do
    #   email { nil }
    # end
    #
    # factory :invalid_email_invite do
    #   email { 'test.com' }
    # end
  end
end
