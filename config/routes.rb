Rails.application.routes.draw do
  root 'pages#home'

  devise_for :users, :controllers => {:registrations => "registrations"}

  get 'lists/public', to: 'lists#public', as: :public_lists

  resources :users, only: [:show], as: :user do
    resources :lists
    get 'ratings', to: 'users/ratings#index'
  end

  resources :screenings, only: :create

  get 'movies/modal', to: 'movies#modal', as: :movie_modal
  get 'movies/modal_close', to: 'movies#modal_close', as: :movie_modal_close
  resources :movies, only: [:index, :show, :update] do
    resources :reviews
    resources :ratings
    resources :screenings, only: [:index, :new, :edit, :create, :update, :destroy]
  end

  patch '/listings/:list_id/:movie_id', to: 'listings#update', as: :update_listing
  delete '/listings/:list_id/:movie_id', to: 'listings#destroy', as: :delete_listing
  resources :listings, only: [:create]

  get 'tags/:tag', to: 'movies#index', as: :tag
  delete '/taggings/:tag_id/:movie_id', to: 'taggings#destroy', as: :delete_tagging
  resources :taggings, only:[:create]

  get 'genres/:genre', to: 'movies#index', as: :genre

  get 'tmdb/search', to: 'tmdb#search', as: :api_search
  get 'tmdb/movie_more', to: 'tmdb#movie_more', as: :movie_more
  get 'tmdb/update_tmdb_data', to: 'tmdb#update_tmdb_data', as: :update_tmdb_data
  get 'tmdb/full_cast', to: 'tmdb#full_cast', as: :full_cast
  get 'tmdb/actor_search', to: 'tmdb#actor_search', as: :actor_search
  get 'tmdb/actor_more', to: 'tmdb#actor_more', as: :actor_more
  get 'tmdb/actor_credit', to: 'tmdb#actor_credit', as: :actor_credit
  get 'tmdb/two_actor_search', to: 'tmdb#two_actor_search', as: :two_actor_search
  get 'tmdb/director_search', to: 'tmdb#director_search', as: :director_search
  get 'tmdb/tv_episode', to: 'tmdb#tv_episode', as: :tv_episode
  get 'tmdb/tv_series', to: 'tmdb#tv_series', as: :tv_series
  get 'tmdb/tv_series_search', to: 'tmdb#tv_series_search', as: :tv_series_search
  get 'tmdb/tv_season', to: 'tmdb#tv_season', as: :tv_season
  get 'tmdb/two_movie_search', to: 'tmdb#two_movie_search', as: :two_movie_search
  get 'tmdb/discover_search', to: 'tmdb#discover_search', as: :discover_search
  get 'tmdb/movie_autocomplete', to: 'tmdb#movie_autocomplete', as: :movie_autocomplete
  get 'tmdb/tv_series_autocomplete', to: 'tmdb#tv_series_autocomplete', as: :tv_series_autocomplete
  get 'tmdb/person_autocomplete', to: 'tmdb#person_autocomplete', as: :person_autocomplete

  resources :invites, only: [:create]

  get 'about', to: 'pages#about', as: :about
  get 'faq', to: 'pages#faq', as: :faq
  get 'pages/awaiting_confirmation', as: :awaiting_confirmation
  get 'demo', to: 'pages#demo', as: :demo
end
