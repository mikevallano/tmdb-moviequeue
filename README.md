## README

[![Build Status](https://travis-ci.org/mikevallano/tmdb-moviequeue.svg?branch=master)](https://travis-ci.org/mikevallano/tmdb-moviequeue) [![Code Climate](https://codeclimate.com/github/mikevallano/tmdb-moviequeue/badges/gpa.svg)](https://codeclimate.com/github/mikevallano/tmdb-moviequeue) [![Coverage Status](https://coveralls.io/repos/github/mikevallano/tmdb-moviequeue/badge.svg?branch=master)](https://coveralls.io/github/mikevallano/tmdb-moviequeue?branch=master)

This Rails app helps your movie viewing in a few ways:

 1. You can create lists of movies that they want to watch. No more wasting precious movie-watching time with movie-finding time. No more stale popcorn.
 2. You can track movies they've seen. You may wish to forget that you've watched Sharknado, but the data doesn't lie (you can also rate it and prioritize it so you don't have to suffer through it again).
 3. You can share a list with someone you watch lots of movies with. Members of the list can add or remove movies from lists, and members can see each other's tags. Movies are better watched together.
 4. Is that the guy from that one movie? Was that guy in a movie with that other guy? Now you'll know. This app allows you to search by various means to determine if that was indeed that guy.
 5. Find movies you want to watch. With loads of different ways to search, you can build lists of movies to make sure you're well stocked when the mood is right.
 6. Browse other users' lists. Want to know what other people watch during the holidays or when they're in the mood for a dark comedy? You can easily browse and add movies to your lists.

Things to note:

* Ruby version: 2.2.2

* Rails version: 4.2.3

* PostgreSQL v9.3.4

* No special database setup instructions. $ rake db:setup should do it.

* No special server info. It's using Puma, but $ rails s will do it.

* There are no special rake tasks or seeds.

* Simply running $ rsepc will run the test suite, which uses Selenium, and therefore launches Firefox.

* There are no background jobs.

* The data is gathered from the awesome API available from TMDB: <https://www.themoviedb.org/documentation/api>, which is managed in the tmdb_controller and the tmdb_handler module in the lib directory.
