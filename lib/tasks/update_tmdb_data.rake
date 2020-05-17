# rake "tmdb_data:refresh"
# from console: Rake::Task["tmdb_data:refresh"].invoke

TIME_FRAME = 1.week.ago
BATCH_SIZE = 50

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
      res = TmdbHandler.tmdb_handler_update_movie(tmdb_id)
      if res
        puts "Movie refreshed. tmdb_id: #{tmdb_id}"
        updated_movies << tmdb_id
        sleep 0.01
      else
        break
      end
    end

    puts "*** Updated_movies: count: #{updated_movies.count}. tmdb_ids: #{updated_movies}"
  end
end
