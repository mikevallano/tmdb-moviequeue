Rails.application.routes.draw do

  devise_for :users, :controllers => {:registrations => "registrations"}

  resources :movies, only: [:index, :show]
  resources :lists

  get 'tmdb/search', to: 'tmdb#search', as: :api_search
  get 'tmdb/more', to: 'tmdb#more', as: :more_info

  root 'pages#home'
  get 'pages/about'

end
