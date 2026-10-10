# frozen_string_literal: true

# A TMDB movie suggested by Claude, wrapping the matched TMDB search result.
# Duck-types enough of MovieSearchResult to render in movies/_movie_partial_loop.
class MovieSuggestion
  attr_reader :movie, :reason
  attr_accessor :labels

  delegate :title, :tmdb_id, :poster_path, :release_date, to: :movie

  def initialize(movie:, reason:)
    @movie = movie
    @reason = reason
    @labels = []
  end
end
