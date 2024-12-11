# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

 user = User.find_or_create_by(email: 'admin@email.com') do |user|
  user.password = 'password'
  user.password_confirmation = 'password'
  user.username = 'McAdmins'
  user.admin = true
end

user.tv_series_viewings.find_or_create_by(
  title: 'Brooklyn Nine Nine',
  url: '/tmdb/tv_series?show_id=48891',
  show_id: '48891',
  started_at: 2.weeks.ago,
  ended_at: nil
)

user.tv_series_viewings.find_or_create_by(
  title: 'Star Trek: The Next Generation',
  url: '/tmdb/tv_series?show_id=655',
  show_id: '655',
  started_at: '2023-04-01'.to_datetime,
  ended_at: '2024-05-27'.to_datetime
)

user.tv_series_viewings.find_or_create_by(
  title: 'DS9',
  url: '/tmdb/tv_series?show_id=580',
  show_id: '580',
  started_at: '2021-06-13'.to_datetime,
  ended_at: '2023-01-23'.to_datetime
)

user.tv_series_viewings.find_or_create_by(
  title: 'Star Trek: The Next Generation',
  url: '/tmdb/tv_series?show_id=655',
  show_id: '655',
  started_at: '2019-12-28'.to_datetime,
  ended_at: '2001-06-12'.to_datetime
)
