FactoryGirl.define do
  factory :list do
    owner_id 1
    sequence(:name) { |n| "list name#{n}" }
    is_main false
    is_public false
    description { FFaker::HipsterIpsum.phrase }

    factory :invalid_list do
      name nil
    end

    factory :list_with_too_long_name do
      name { SecureRandom.urlsafe_base64(81) }
    end
  end

end
