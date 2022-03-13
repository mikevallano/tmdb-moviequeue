# frozen_string_literal: true

module MovieDataService
  LIST_SORT_OPTIONS = [ ["title", "title"], ["shortest runtime", "shortest runtime"],
  ["longest runtime", "longest runtime"], ["newest release", "newest release"],
  ["vote average", "vote average"], ["recently added to list", "recently added to list"],
  ["watched movies", "watched movies"], ["unwatched movies", "unwatched movies"],
  ["recently watched", "recently watched"], ["highest priority", "highest priority"],
  ["only show unwatched", "only show unwatched"], ["only show watched", "only show watched"] ]

  MY_MOVIES_SORT_OPTIONS = [ ["title", "title"], ["shortest runtime", "shortest runtime"],
  ["longest runtime", "longest runtime"], ["newest release", "newest release"],
  ["vote average", "vote average"], ["watched movies", "watched movies"], ["recently watched", "recently watched"],
  ["unwatched movies", "unwatched movies"], ["only show unwatched", "only show unwatched"],
  ["only show watched", "only show watched"], ["movies not on a list", "movies not on a list"] ]

  GENRES = [["Action", 28], ["Adventure", 12], ["Animation", 16], ["Comedy", 35], ["Crime", 80],
  ["Documentary", 99], ["Drama", 18], ["Family", 10751], ["Fantasy", 14], ["Foreign", 10769], ["History", 36],
  ["Horror", 27], ["Music", 10402], ["Mystery", 9648], ["Romance", 10749], ["Science Fiction", 878], ["TV Movie", 10770],
  ["Thriller", 53], ["War", 10752], ["Western", 37]]

  MPAA_RATINGS = [ ["R", "R"], ["NC-17", "NC-17"], ["PG-13", "PG-13"], ["G", "G"] ]

  SORT_BY = [ ["Popularity", "popularity"], ["Release date", "release_date"], ["Revenue", "revenue"],
  ["Vote average", "vote_average"], ["Vote count","vote_count"] ]

  YEAR_SELECT = [ ["Exact Year", "exact"], ["After This Year", "after"], ["Before This Year", "before"] ]

end
