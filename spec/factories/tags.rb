FactoryGirl.define do
  factory :tag do
    name { FFaker::HipsterIpsum.word }

    factory :invalid_tag do
      name nil
    end
  end

end
