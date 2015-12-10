FactoryGirl.define do
  factory :invite do
    email { FFaker::Internet.email }
    sender_id 1
    receiver_id 2
    token "token1234"
    list

    factory :invalid_invite do
      email nil
    end

    factory :invalid_email_invite do
      email "test.com"
    end
  end

end
