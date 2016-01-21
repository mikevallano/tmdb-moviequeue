FactoryGirl.define do
  factory :rating do
    user
    movie
    value { "6 stars" }

    factory :invalid_rating do
      value nil
    end
  end

end
