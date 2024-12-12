# frozen_string_literal: true

namespace :db do
  namespace :seed do
    desc "Create TVSeriesViewing Seeds"
    task :tv_series_viewings, [:user_id] => [:environment] do |_task, args|

      if !args[:user_id]
        puts "ERROR: user_id is required for tv_series_viewings seeds."
        puts "\nRun from the command line with:"
        puts "rails 'db:seed:tv_series_viewings[USER-ID-HERE]'"
        puts "\nOr inside the rails console with:"
        puts "Rails.application.load_tasks"
        puts 'Rake::Task["db:seed:tv_series_viewings"].invoke(user.id)'
        exit 1
      end

      user = User.find(args[:user_id])
     
      puts "Seeding TVSeriesViewings"
      user.tv_series_viewings.find_or_create_by(
        title: 'Brooklyn Nine Nine',
        url: '/tmdb/tv_series?show_id=48891',
        show_id: '48891',
        started_at: '2024-12-10'.to_datetime,
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

      puts "Finished."
    end
  end
end
