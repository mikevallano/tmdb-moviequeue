FactoryBot.define do
  factory :tv_series_viewing do
    user
    sequence(:title) { |n| "TV Series #{n}" }
    sequence(:url) { |n| "/example/#{n}" }
    sequence(:show_id) { |n| n * 100 }
    started_at { 1.week.ago }

    factory :invalid_tv_series_viewing do
      started_at { nil }
    end
  end
end
