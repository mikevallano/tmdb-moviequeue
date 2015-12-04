FactoryGirl.define do
  factory :list do
    owner_id 1
    name { FFaker::HipsterIpsum.word }

    factory :invalid_list do
      name nil
    end
  end

end
