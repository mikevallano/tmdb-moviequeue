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
  title: 'DS9',
  url: '/tmdb/tv_series?show_id=580',
  show_id: '580',
  started_at: '2024-03-01'.to_datetime,
  ended_at: '2024-12-10'.to_datetime
)
