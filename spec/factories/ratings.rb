FactoryGirl.define do
  factory :rating do
    user
    movie
    value 8

    factory :invalid_rating do
      value nil
    end
  end

end
