FactoryBot.define do
  factory :tag do
    sequence(:name) { |n| "tag name#{n}" }

    factory :invalid_tag do
      name { nil }
    end

    factory :tag_too_long do
      name { SecureRandom.urlsafe_base64(26) }
    end
  end

end
