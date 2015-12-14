FactoryGirl.define do
  factory :review do
    user
    movie
    body { FFaker::HipsterIpsum.sentence }

    factory :invalid_review do
      body nil
    end
  end

end
