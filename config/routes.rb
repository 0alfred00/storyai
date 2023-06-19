require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users

  root to: "pages#home"

  resources :stories, only: [:index, :show, :create, :new, :update] do
    get :history, on: :collection
    resources :favorites, only: [:create]
    get :check_story, on: :collection
  end
  resources :favorites, only: [:index, :destroy]

  mount Sidekiq::Web => '/sidekiq'
end
