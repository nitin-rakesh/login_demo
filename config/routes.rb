Rails.application.routes.draw do

  devise_for :users, :controllers => {:omniauth_callbacks => "devise/omniauth_callbacks"}
  resources :users, :posts
  root 'home#index'

  resources :tokens,:only => [:create], defaults: {format: 'json'}
  post 'tokens/get_key' => 'tokens#get_key', defaults: {format: 'json'}
  post 'tokens/user_sign_up' => 'tokens#user_sign_up', defaults: {format: 'json'}
  get 'tokens/destroy_token' => 'tokens#destroy_token', defaults: {format: 'json'}
  get 'tokens/check_token' => 'tokens#check_token', defaults: {format: 'json'}
  post 'tokens/facebook_authentication' => 'tokens#facebook_authentication', defaults: {format: 'json'}
  
  # get '*path' => redirect('/')
  
end
