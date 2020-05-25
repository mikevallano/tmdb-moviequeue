# To run the rake task: rake "tmdb_data:refresh"
# To run from console: Rake::Task["tmdb_data:refresh"].invoke

TIME_FRAME = (ENV['tmdb_refresh_time_frame_days'] || 7).to_i.days.ago
BATCH_SIZE = (ENV['tmdb_refresh_batch_size'] || 50).to_i

namespace :tmdb_data do
  desc 'refresh tmdb_data'
  task :refresh => :environment do
    tmdb_ids = Movie
      .where('updated_at < ?', TIME_FRAME)
      .order(updated_at: :asc)
      .limit(BATCH_SIZE)
      .pluck(:tmdb_id)

    puts "*** Refreshing #{tmdb_ids.count} movies..."
    updated_movies = []

    tmdb_ids.each do |tmdb_id|
      TmdbHandler.tmdb_handler_update_movie(tmdb_id)
      puts "Movie refreshed. tmdb_id: #{tmdb_id}"
      updated_movies << tmdb_id
      sleep 0.01
    end
    output = "*** Updated_movies: count: #{updated_movies.count}. tmdb_ids: #{updated_movies}"
    puts output
  rescue => error
    output = "*** Updated_movies: count: #{updated_movies.count}. tmdb_ids: #{updated_movies}"
    puts "Not all movies uptated. #{output}"
    raise error
  end
end
