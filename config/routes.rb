Rails.application.routes.draw do

  devise_for :users, :controllers => {:registrations => "registrations"}

  get 'lists/public', to: 'lists#public', as: :public_lists

  resources :users, only: [:show], as: :user do
    resources :lists
  end

  resources :screenings, only: :create
  resources :movies, only: [:index, :show] do
    resources :reviews
    resources :ratings
    resources :screenings
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
  get 'tmdb/similar_movies', to: 'tmdb#similar_movies', as: :similar_movies
  get 'tmdb/full_cast', to: 'tmdb#full_cast', as: :full_cast
  get 'tmdb/actor_search', to: 'tmdb#actor_search', as: :actor_search
  get 'tmdb/actor_more', to: 'tmdb#actor_more', as: :actor_more
  get 'tmdb/actor_credit', to: 'tmdb#actor_credit', as: :actor_credit
  get 'tmdb/two_actor_search', to: 'tmdb#two_actor_search', as: :two_actor_search
  get 'tmdb/director_search', to: 'tmdb#director_search', as: :director_search
  get 'tmdb/tv_more', to: 'tmdb#tv_more', as: :tv_more
  get 'tmdb/tv_season', to: 'tmdb#tv_season', as: :tv_season
  get 'tmdb/two_movie_search', to: 'tmdb#two_movie_search', as: :two_movie_search
  get 'tmdb/discover_search', to: 'tmdb#discover_search', as: :discover_search

  resources :invites, only: [:create]

  root 'pages#home'
  get 'pages/about'
  get 'pages/awaiting_confirmation', as: :awaiting_confirmation

end
