Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  devise_for :users

  authenticated :user do
    root to: 'events#index', as: :authenticated_root
    get :sidebar, to: 'sidebar#show'

    if defined?(Sidekiq)
      require 'sidekiq/web'
      require 'sidekiq-scheduler/web'
      mount Sidekiq::Web => '/sidekiq'
    end
  end

  root to: 'welcome#index'
  get :about, to: 'welcome#about'
  post :'dark_mode/toggle', to: 'dark_mode#toggle'

  resource :profile, except: %i[index show destroy]
  resources :events do
    member do
      post :publish
    end
    get :bulk_add_invitations, to: 'event_invitations#bulk_add'
    post :bulk_create_invitations, to: 'event_invitations#bulk_create'
    resource :event_invitation, as: :invitation, only: [] do
      member do
        post :accept
        post :decline
      end
    end
  end
  resources :friends, only: %i[index create destroy] do
    member do
      patch :accept
      patch :reject
    end
  end
  resources :people, only: %i[index]
end
