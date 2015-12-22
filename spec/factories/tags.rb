FactoryGirl.define do
  factory :tag do
    name { FFaker::HipsterIpsum.words(2) }

    factory :invalid_tag do
      name nil
    end
  end

end
