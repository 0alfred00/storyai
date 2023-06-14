Rails.application.routes.draw do
  devise_for :users

  root to: "pages#home"

  resources :stories, only: [:index, :show, :create, :new, :update] do
    get :history, on: :collection
    resources :favorites, only: [:create]
  end
  resources :favorites, only: [:index, :destroy]

  # for testing openai
  get '/openai', to: 'openai#index'
  post '/openai', to: 'openai#create'

  # old routes now deprecated
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  # get '/stories', to: 'stories#index'
  # # get '/stories/new', to: 'stories#new'
  # post '/stories', to: 'stories#create'
  # get '/stories/history', to: 'stories#history'
  # get '/stories/:id', to: 'stories#show', as: 'story'
  # post '/favorites/:id', to: 'favorites#create'
  # get '/favorites', to: 'favorites#index'
  # delete '/favorites/:id', to: 'favorites#destroy'
  # post '/stories/:id', to: 'stories#create'
  # patch '/stories/:id', to: 'stories#update'
end
