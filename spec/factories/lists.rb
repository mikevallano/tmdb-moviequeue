FactoryGirl.define do
  factory :list do
    owner_id 1
    name { FFaker::DizzleIpsum.words(3).join(' ') }
    is_main false
    is_public false
    description { FFaker::HipsterIpsum.phrase }

    factory :invalid_list do
      name nil
    end
  end

end
