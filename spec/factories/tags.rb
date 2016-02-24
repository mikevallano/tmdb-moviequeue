FactoryGirl.define do
  factory :tag do
    name { FFaker::HipsterIpsum.words(1) }

    factory :invalid_tag do
      name nil
    end

    factory :tag_too_long do
      name { SecureRandom.urlsafe_base64(21) }
    end
  end

end
