FactoryGirl.define do
  factory :list do
    owner_id 1
    name { FFaker::HipsterIpsum.words(3).join(' ') }
    is_main false
    is_public false

    factory :invalid_list do
      name nil
    end
  end

end
