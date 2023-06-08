Rails.application.routes.draw do
  devise_for :users
  root to: "stories#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  get '/stories', to: 'stories#index'
  # get '/stories/new', to: 'stories#new'
  post '/stories', to: 'stories#create'
  get '/stories/history', to: 'stories#history'
  get '/stories/:id', to: 'stories#show'
  post '/favorites/:id', to: 'favorites#create'
  get '/favorites', to: 'favorites#index'
  delete '/favorites/:id', to: 'favorites#destroy'
  post '/stories/:id', to: 'stories#create'
  patch '/stories/:id', to: 'stories#update'

  # for testing openai
  get '/openai', to: 'openai#index'
  post '/openai', to: 'openai#create'
end
