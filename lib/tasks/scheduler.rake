# To run the rake task: rake tmdb_data:refresh
# To run from console: Rake::Task["tmdb_data:refresh"].invoke

TIME_FRAME = (ENV['tmdb_refresh_time_frame_days'] || 7).to_i.days.ago
BATCH_SIZE = (ENV['tmdb_refresh_batch_size'] || 50).to_i

namespace :tmdb_data do
  desc 'refresh tmdb_data'
  task :refresh => :environment do
    movies = Movie
      .where('updated_at < ?', TIME_FRAME)
      .order(updated_at: :asc)
      .limit(BATCH_SIZE)

    puts "*** Refreshing #{movies.count} movies..."
    updated_movies = []

    movies.each do |movie|
      TmdbHandler.tmdb_handler_update_movie(movie)
      puts "Movie refreshed. #{movie.title}. tmdb_id: #{movie.tmdb_id}"
      updated_movies << movie.tmdb_id
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
