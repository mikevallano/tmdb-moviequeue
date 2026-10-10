# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Flicks On Lists** is a Rails 7.1 movie management application that helps users create and manage movie watchlists. It integrates with The Movie Database (TMDB) API to fetch comprehensive movie data including cast, crew, ratings, and streaming availability.

Live site: https://www.flicksonlists.com/

## Development Commands

### Setup
```bash
# Database setup (PostgreSQL)
rails db:setup

# Start the development server (Puma)
rails s
```

### Testing
```bash
# Run full test suite (uses Selenium with Firefox)
rspec

# Run a specific test file
rspec spec/models/movie_spec.rb

# Run a specific test
rspec spec/models/movie_spec.rb:42

# Run feature specs only
rspec spec/features

# Run model specs only
rspec spec/models
```

### Code Quality
```bash
# Run RuboCop linter
rubocop

# Auto-fix RuboCop violations where possible
rubocop -a
```

### Other Useful Commands
```bash
# Generate ERD diagram
bundle exec erd

# Rails console
rails c

# Database migrations
rails db:migrate
rails db:rollback
```

## Architecture

### Core Domain Models

The application is built around several key models with specific relationships:

- **User**: Authenticated via Devise. Can own multiple lists and be a member of shared lists
- **List**: Belongs to an owner (User), can have multiple members through Memberships. Uses FriendlyId for URL slugs
- **Movie**: Central model. Stores movie data from TMDB API. Uses FriendlyId. One movie can be on many lists
- **Listing**: Join table between List and Movie. Also belongs to User (the person who added it). Includes priority field (1-5)
- **Membership**: Join table for shared lists - connects users as members of lists they don't own
- **Screening**: Tracks when a user watched a movie (date_watched). Users can watch movies multiple times
- **Tag/Tagging**: Users can tag movies for organization. Tags are scoped to users and lists
- **Rating**: User ratings for movies
- **Review**: User reviews for movies

### TMDB API Integration

The app uses TMDB API extensively and has a specialized architecture for handling API data:

**Tmdb::Client** (`app/lib/tmdb/client.rb`):
- Central API client module
- Handles all HTTP requests to TMDB API
- API key stored in ENV variable: `tmdb_api_key`
- Base URL: `https://api.themoviedb.org/3`

**Service Layer** (`app/services/`):
- `MovieDataService`: Movie search, discovery, data fetching
- `PersonDataService`: Actor/director search and credits
- `TvSeriesDataService`: TV series data
- `UserStreamingServiceProviderDataService`: Streaming availability

**Entity Layer** (`app/entities/`):
- Plain Ruby objects that represent TMDB API responses
- Examples: `MovieSearchResult`, `MovieCredits`, `TvSeries`, `MoviePersonProfile`
- These are NOT ActiveRecord models - they're lightweight objects for API data that may not be persisted

**GuaranteedMovie Pattern** (`app/models/guaranteed_movie.rb`):
- Used when you need a movie object but it may not exist in the database yet
- `find_or_create(tmdb_id)`: Returns persisted Movie record
- `find_or_initialize_from_api(tmdb_id)`: Returns Movie if exists, or entity object from API
- This pattern prevents database bloat while allowing browsing of TMDB data

**TmdbController** (`app/controllers/tmdb_controller.rb`):
- Handles all TMDB search and browse functionality
- Methods for movie search, actor search, common actors between movies, etc.
- Uses service layer to fetch data

### Key Patterns

**Services are Modules, not Classes**:
Services in this app are modules with class methods, not service objects:
```ruby
module MovieDataService
  class << self
    def get_movie_data(tmdb_id)
      # ...
    end
  end
end
```

**List Membership**:
Lists have an owner and can have additional members. A user's lists are found via:
```ruby
List.by_user(user) # Returns owned lists + lists where user is a member
```

**Sorting Movies**:
Movies can be sorted in many ways on lists - see `MovieDataService::LIST_SORT_OPTIONS`. The sorting logic is in service methods and model scopes.

**Priority System**:
Listings have priority 1-5 (Bottom, Low, Normal, High, Top) stored as integers on the listing record.

## Test Setup

- **Framework**: RSpec with Capybara for feature tests
- **Test Database**: PostgreSQL (`tmdb-moviequeue_test`)
- **Browser**: Tests use Selenium with Firefox (via webdrivers gem)
- **VCR**: Used to record/replay HTTP interactions with TMDB API (see `spec/support/vcr.rb`)
- **Factory Bot**: For test data generation
- **Database Cleaner**: Handles test database cleanup between tests

Feature specs live in `spec/features/`, model specs in `spec/models/`, etc.

## Environment Variables

Required environment variable:
- `tmdb_api_key`: Your TMDB API key (get from https://www.themoviedb.org/documentation/api)

The app uses Figaro gem for environment variable management (see `config/application.yml` locally).

## Important Notes

- **PostgreSQL specific**: Uses PostgreSQL array columns (e.g., `genres` on movies)
- **Hotwire/Turbo**: App uses Hotwire (Turbo + Stimulus) for interactive features
- **No background jobs**: All operations are synchronous
- **Deployment**: Configured for Heroku (see `rails_12factor` gem, `Procfile`)
- **Error Tracking**: Uses Sentry for production error monitoring
