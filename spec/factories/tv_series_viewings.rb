FactoryBot.define do
  factory :tv_series_viewing do
    user
    title { FFaker::HipsterIpsum.phrase }
    sequence(:url) { |n| "/example/#{n}" }
    sequence(:show_id) { |n| n * 100 }
    started_at { 1.week.ago }

    factory :invalid_tv_series_viewing do
      started_at { nil }
    end
  end
end
