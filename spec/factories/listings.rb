FactoryGirl.define do
  factory :listing do
    list
    movie

    factory :invalid_listing do
      movie nil
    end
  end

end
