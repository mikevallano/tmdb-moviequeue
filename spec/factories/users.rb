FactoryGirl.define do
  factory :user, :aliases => [:member, :owner] do
    email { FFaker::Internet.email }
    password 'password'
    password_confirmation 'password'

    factory :invalid_user do
      email nil
    end
  end

end