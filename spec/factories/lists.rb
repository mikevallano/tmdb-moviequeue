FactoryGirl.define do
  factory :list do
    owner_id 1
    name { FFaker::HipsterIpsum.word }
    is_main false
    is_public false

    factory :invalid_list do
      name nil
    end
  end

end
