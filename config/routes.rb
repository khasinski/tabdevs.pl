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
  get "accept-terms", to: "sessions#accept_terms", as: :accept_terms
  post "accept-terms", to: "sessions#submit_terms"

  # User settings
  get "settings", to: "settings#edit", as: :settings
  patch "settings", to: "settings#update"
  patch "settings/password", to: "settings#update_password", as: :settings_password
  get "settings/export", to: "settings#export_data", as: :settings_export
  post "settings/newsletter", to: "settings#subscribe_newsletter", as: :settings_newsletter
  delete "settings/newsletter", to: "settings#unsubscribe_newsletter"
  delete "settings", to: "settings#destroy", as: :settings_destroy

  # Posts
  resources :posts do
    resources :comments, only: [ :create, :edit, :update, :destroy ]
    member do
      post :upvote
      post :downvote
      delete :remove_vote
    end
    resource :bookmark, only: [ :create, :destroy ]
    resource :flag, only: [ :new, :create ]
  end

  # Bookmarks
  get "bookmarks", to: "bookmarks#index", as: :bookmarks

  # Comments voting
  resources :comments, only: [] do
    member do
      post :upvote
      post :downvote
      delete :remove_vote
    end
    resource :flag, only: [ :new, :create ]
  end

  # Users
  resources :users, only: [ :show ], param: :username

  # Notifications
  resources :notifications, only: [ :index ] do
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

  # Search
  get "search", to: "posts#search", as: :search

  # Static pages
  get "faq", to: "pages#faq", as: :faq
  get "regulamin", to: "pages#terms", as: :terms
  get "prywatnosc", to: "pages#privacy", as: :privacy
  get "kontakt", to: "pages#contact", as: :contact

  # Cookie consent
  post "consent", to: "pages#consent", as: :consent

  # Newsletter
  post "newsletter", to: "newsletter#create", as: :newsletter
  get "newsletter/confirm/:token", to: "newsletter#confirm", as: :newsletter_confirm
  get "newsletter/unsubscribe/:token", to: "newsletter#unsubscribe", as: :newsletter_unsubscribe

  # SEO
  get "sitemap.xml", to: "seo#sitemap", defaults: { format: :xml }
  get "feed.rss", to: "seo#feed", defaults: { format: :rss }

  # Admin panel
  namespace :admin do
    get "/", to: redirect("/admin/dashboard")
    get "dashboard", to: "dashboard#show"
    resources :users, only: [:index, :show] do
      member do
        patch :update_role
        post :ban
        post :unban
      end
    end
    resources :moderation, only: [:index] do
      member do
        post :approve
        post :reject
      end
    end
    post "posts/:id/hide", to: "moderation#hide_post", as: :hide_post
    post "posts/:id/unhide", to: "moderation#unhide_post", as: :unhide_post
    post "comments/:id/hide", to: "moderation#hide_comment", as: :hide_comment
    post "comments/:id/unhide", to: "moderation#unhide_comment", as: :unhide_comment
    resources :flags, only: [:index] do
      member do
        post :resolve
        post :dismiss
      end
    end
  end

  # Root
  root "posts#index"
end
