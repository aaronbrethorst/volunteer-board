Rails.application.routes.draw do
  resource :session
  resource :registration, only: %i[new create]
  resources :passwords, param: :token
  resources :users, only: %i[show]
  resource :profile, only: %i[edit update] do
    resources :listings, only: :index, controller: "profile_listings"
    resources :organizations, only: :index, controller: "profile_organizations"
  end
  resources :organizations, param: :slug, except: :destroy
  resources :organizations, param: :slug, only: [] do
    resources :listings, only: %i[new create], module: :organizations
    resource :flag, only: %i[new create]
  end
  resources :listings, only: %i[index show edit update] do
    resource :interest, only: %i[new create destroy]
    resources :interests, only: %i[show], as: :interest_details
    resource :flag, only: %i[new create]
  end

  namespace :admin do
    root "dashboard#show"
    resources :organizations, only: [ :index, :update ]
    resources :listings, only: [ :index, :update ]
    resources :flags, only: [ :index, :update ]
    resources :users, only: :index
  end

  # OmniAuth callbacks
  get "/auth/:provider/callback", to: "omniauth_callbacks#create"
  get "/auth/failure", to: "omniauth_callbacks#failure"
  delete "/auth/:provider", to: "omniauth_callbacks#destroy"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "homepage#show"
end
