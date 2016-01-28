FactoryGirl.define do
  factory :listing do
    list
    movie
    user
    priority 3

    factory :invalid_listing do
      movie nil
    end
  end

end
