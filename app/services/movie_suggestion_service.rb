# frozen_string_literal: true

module MovieSuggestionService
  REQUESTED_COUNT = 12 # ask for a few extra since some won't match on TMDB
  MAX_RESULTS = 10
  TASTE_SAMPLE_SIZE = 25
  RECENT_TASTE_WINDOW = 6.months
  EXCLUSION_WINDOW = 12.months
  NOPE_LIST_NAME = 'Nope' # where movies they don't want to watch go

  SYSTEM_PROMPT = <<~PROMPT
    You suggest movies for people who keep watchlists of movies they want to watch.

    You'll get a request (a movie list to find more movies for, a free-text description, or both),
    plus the watch history and ratings of the people the suggestions are for. Priorities, in order:
    1. Fit the request. For a list, work out what ties its movies together (theme, era, tone, genre,
       style) and suggest movies that share it. Free text refines or replaces that.
    2. Use the people's taste to choose among movies that fit the request. Taste should not pull
       suggestions away from the request toward their all-time favorites.
    3. Prefer movies none of them have seen, unless the request asks for rewatches.

    When there are several people, suggest movies likely to work for all of them. Something one person
    loved and another rated low is a risky pick.

    Rules:
    - Suggest only real, released feature films. Use each film's exact English title as listed on
      TMDB and its original release year.
    - Never suggest a movie from the "Do not suggest" or "Not interested" sections.
    - "Not interested" movies are ones they've decided they don't want to watch. Treat them as a
      signal of what they dislike, and steer away from similar movies.
    - Mix well-known picks with less obvious ones; avoid only suggesting the most famous films.
    - Give a one-sentence reason for each suggestion, referring to the request or their taste.
  PROMPT

  RESPONSE_SCHEMA = {
    type: 'object',
    properties: {
      suggestions: {
        type: 'array',
        items: {
          type: 'object',
          properties: {
            title: { type: 'string' },
            year: { type: 'integer' },
            reason: { type: 'string' }
          },
          required: %w[title year reason],
          additionalProperties: false
        }
      }
    },
    required: ['suggestions'],
    additionalProperties: false
  }.freeze

  class << self
    def get_suggestions(user:, list: nil, query: nil)
      audience = audience_for(user: user, list: list)
      list_movies = list ? list.movies.to_a : []
      recently_watched_by_all = recently_watched_by_all(audience)
      nope_movies = nope_movies(audience)

      prompt = build_prompt(
        list: list,
        list_movies: list_movies,
        query: query,
        audience: audience,
        user: user,
        excluded_movies: (list_movies + recently_watched_by_all).uniq,
        nope_movies: nope_movies
      )
      response = Claude::Client.request_json(system: SYSTEM_PROMPT, prompt: prompt, schema: RESPONSE_SCHEMA)

      excluded_tmdb_ids = (list_movies + recently_watched_by_all + nope_movies).map(&:tmdb_id).to_set
      suggestions = match_to_tmdb(response[:suggestions] || [])
        .uniq(&:tmdb_id)
        .reject { |suggestion| excluded_tmdb_ids.include?(suggestion.tmdb_id) }

      add_labels(suggestions, user: user, audience: audience)
      movies = sort_new_first(suggestions).first(MAX_RESULTS)

      OpenStruct.new(
        movies: movies,
        not_found_message: ("Claude's suggestions didn't match any movies on TMDB. Try again?" if movies.empty?)
      )
    rescue Claude::Client::Error => e
      Rails.logger.error("[claude] #{e.class}: #{e.message}")
      Sentry.capture_exception(e)
      OpenStruct.new(movies: [], not_found_message: 'Something went wrong getting suggestions. Try again?')
    end

    private

    def audience_for(user:, list:)
      return [user] if list.nil?

      ([list.owner] + list.members.to_a).uniq
    end

    # Movies every person in the audience has watched within the exclusion window.
    def recently_watched_by_all(audience)
      cutoff = EXCLUSION_WINDOW.ago.to_date
      movie_ids = audience
        .map { |person| Screening.by_user(person).where('date_watched >= ?', cutoff).distinct.pluck(:movie_id) }
        .reduce(:&)
      Movie.where(id: movie_ids).to_a
    end

    # Movies on any "Nope" list belonging to (or shared with) the audience.
    def nope_movies(audience)
      nope_list_ids = audience
        .flat_map { |person| List.by_user(person) }
        .select { |list| list.name.strip.casecmp?(NOPE_LIST_NAME) }
        .map(&:id)
        .uniq
      Movie.joins(:listings).where(listings: { list_id: nope_list_ids }).distinct.to_a
    end

    def build_prompt(list:, list_movies:, query:, audience:, user:, excluded_movies:, nope_movies: [])
      sections = []
      sections << "# Request\n#{query}" if query.present?
      if list
        sections << <<~LIST.strip
          # List: #{list.name}
          #{"Description: #{list.description}\n" if list.description.present?}Movies on the list:
          #{movie_lines(list_movies)}
        LIST
      end
      audience.each { |person| sections << taste_section(person, asker: person == user) }
      sections << "# Not interested\n#{movie_lines(nope_movies)}" if nope_movies.any?
      sections << "# Do not suggest\n#{movie_lines(excluded_movies)}" if excluded_movies.any?
      sections << "Suggest #{REQUESTED_COUNT} movies."
      sections.join("\n\n")
    end

    def taste_section(person, asker:)
      screenings = Screening.by_user(person).includes(:movie).to_a
      watches_by_movie = screenings.group_by(&:movie)
      ratings = Rating.by_user(person).includes(:movie).order(value: :desc).to_a

      most_rewatched = watches_by_movie
        .select { |_movie, watches| watches.size > 1 }
        .sort_by { |_movie, watches| -watches.size }
        .first(TASTE_SAMPLE_SIZE)
        .map { |movie, watches| "#{movie_label(movie)} - watched #{watches.size} times" }
      recently_watched = watches_by_movie
        .map { |movie, watches| [movie, watches.map(&:date_watched).compact.max] }
        .select { |_movie, date| date && date >= RECENT_TASTE_WINDOW.ago.to_date }
        .sort_by { |_movie, date| date }
        .reverse
        .first(TASTE_SAMPLE_SIZE)
        .map { |movie, _date| movie_label(movie) }
      highest_rated = ratings.select { |rating| rating.value >= 8 }.first(TASTE_SAMPLE_SIZE)
      lowest_rated = ratings.select { |rating| rating.value <= 4 }.last(TASTE_SAMPLE_SIZE).reverse

      heading = "# Taste: #{person.username}#{' (the person asking)' if asker}"
      lines = ["#{heading}\nMovies watched: #{watches_by_movie.size}"]
      lines << "Most rewatched:\n#{bullets(most_rewatched)}" if most_rewatched.any?
      lines << "Highest rated (out of 10):\n#{bullets(rating_lines(highest_rated))}" if highest_rated.any?
      lines << "Lowest rated (out of 10):\n#{bullets(rating_lines(lowest_rated))}" if lowest_rated.any?
      lines << "Watched in the last 6 months:\n#{bullets(recently_watched)}" if recently_watched.any?
      lines.join("\n")
    end

    def match_to_tmdb(suggestions)
      suggestions.filter_map do |suggestion|
        results = Tmdb::Client.request(:movie_search, query: suggestion[:title])[:results] || []
        same_era = results.select do |result|
          year = result[:release_date].to_s[0, 4].to_i
          year.positive? && (year - suggestion[:year].to_i).abs <= 1
        end
        match = same_era.find { |result| result[:title].casecmp?(suggestion[:title]) } || same_era.first
        next unless match

        MovieSuggestion.new(movie: MovieSearchResult.build_list([match]).first, reason: suggestion[:reason])
      rescue StandardError => e
        # One failed lookup shouldn't sink the rest of the suggestions
        Rails.logger.warn("[claude] TMDB lookup failed for #{suggestion[:title].inspect}: #{e.class}: #{e.message}")
        nil
      end
    end

    def add_labels(suggestions, user:, audience:)
      movies = Movie.where(tmdb_id: suggestions.map(&:tmdb_id)).index_by(&:tmdb_id)
      return if movies.empty?

      listings = Listing
        .where(list_id: List.by_user(user).map(&:id), movie_id: movies.values.map(&:id))
        .includes(:list)
        .group_by(&:movie_id)
      last_watched = Screening
        .where(user: audience, movie_id: movies.values.map(&:id))
        .group(:movie_id, :user_id)
        .maximum(:date_watched)

      suggestions.each do |suggestion|
        movie = movies[suggestion.tmdb_id]
        next unless movie

        listings.fetch(movie.id, []).each do |listing|
          suggestion.labels << "On #{listing.list.name} since #{listing.created_at.year}"
        end
        audience.each do |person|
          date = last_watched[[movie.id, person.id]]
          next unless date

          who = person == user ? 'You' : person.username
          suggestion.labels << "#{who} watched #{date.strftime('%b %Y')}"
        end
      end
    end

    # Movies nobody has listed or watched come first; otherwise keep Claude's order.
    def sort_new_first(suggestions)
      suggestions.each_with_index.sort_by { |suggestion, index| [suggestion.labels.any? ? 1 : 0, index] }.map(&:first)
    end

    def movie_label(movie)
      year = movie.release_date&.year
      year ? "#{movie.title} (#{year})" : movie.title
    end

    def movie_lines(movies)
      bullets(movies.map { |movie| movie_label(movie) })
    end

    def rating_lines(ratings)
      ratings.map { |rating| "#{movie_label(rating.movie)} - #{rating.value}" }
    end

    def bullets(lines)
      lines.map { |line| "- #{line}" }.join("\n")
    end
  end
end
