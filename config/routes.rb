Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Authentication
  get "login", to: "sessions#new", as: :login
  post "login", to: "sessions#create"
  get "login/password", to: "sessions#password", as: :password_login
  post "login/password", to: "sessions#password_auth"
  get "auth/callback", to: "sessions#callback", as: :auth_callback
  get "auth/sent", to: "sessions#sent", as: :auth_sent
  delete "logout", to: "sessions#destroy", as: :logout

  # User settings
  get "settings", to: "settings#edit", as: :settings
  patch "settings", to: "settings#update"
  patch "settings/password", to: "settings#update_password", as: :settings_password

  # Posts
  resources :posts do
    resources :comments, only: [:create, :edit, :update, :destroy]
    member do
      post :upvote
      post :downvote
      delete :remove_vote
    end
  end

  # Comments voting
  resources :comments, only: [] do
    member do
      post :upvote
      post :downvote
      delete :remove_vote
    end
  end

  # Users
  resources :users, only: [:show], param: :username

  # Notifications
  resources :notifications, only: [:index] do
    collection do
      post :mark_all_read
    end
    member do
      post :mark_read
    end
  end

  # Feed views
  get "new", to: "posts#index", defaults: { sort: "new" }, as: :new_posts
  get "top", to: "posts#index", defaults: { sort: "top" }, as: :top_posts

  # Root
  root "posts#index"
end
