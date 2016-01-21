FactoryGirl.define do
  factory :listing do
    list
    movie
    priority "medium"

    factory :invalid_listing do
      movie nil
    end
  end

end
