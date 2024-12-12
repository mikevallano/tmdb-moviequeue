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

Rake::Task["db:seed:tv_series_viewings"].invoke(user.id)
