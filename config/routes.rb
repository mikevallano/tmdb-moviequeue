Rails.application.routes.draw do

  devise_for :users, :controllers => {:registrations => "registrations"}

  resources :movies, only: [:index, :show] do
    resources :reviews
    resources :ratings
    resources :screenings
  end

  resources :lists
  patch '/listings/:list_id/:movie_id', to: 'listings#update', as: :update_listing
  delete '/listings/:list_id/:movie_id', to: 'listings#destroy', as: :delete_listing
  resources :listings, only: [:create]

  get 'tags/:tag', to: 'movies#index', as: :tag
  resources :taggings, only:[:create, :destroy]

  get 'tmdb/search', to: 'tmdb#search', as: :api_search
  get 'tmdb/more', to: 'tmdb#more', as: :more_info

  resources :invites, only: [:create]

  root 'pages#home'
  get 'pages/about'

end
