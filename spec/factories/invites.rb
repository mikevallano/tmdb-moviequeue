FactoryBot.define do
  factory :invite do
    email { FFaker::Internet.email }
    association :sender, factory: :user
    association :receiver, factory: :user
    token { 'token1234' }
    list

    factory :invalid_invite do
      email { nil }
    end

    factory :invalid_email_invite do
      email { 'test.com' }
    end
  end

end
