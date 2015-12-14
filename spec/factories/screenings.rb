FactoryGirl.define do
  factory :screening do
    user
    movie
    date_watched "2015-12-14"
    location_watched "in a theater"
    notes { FFaker::HipsterIpsum.sentence }

    factory :invalid_screening do
      user nil
    end
  end

end
