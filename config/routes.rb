Rails.application.routes.draw do



  devise_for :users, :controllers => {:registrations => "registrations"}

  resources :movies, only: [:index, :show]
  resources :lists
  delete '/listings/:list_id/:movie_id', to: 'listings#destroy', as: :delete_listing
  resources :listings, only: [:create]

  get 'tags/:tag', to: 'movies#index', as: :tag
  resources :taggings, only:[:create, :destroy]

  get 'tmdb/search', to: 'tmdb#search', as: :api_search
  get 'tmdb/more', to: 'tmdb#more', as: :more_info

  root 'pages#home'
  get 'pages/about'

end
