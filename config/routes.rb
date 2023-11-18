Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  devise_for :users

  root to: 'offers#index'

  resource :profile, except: %i[index show destroy]
  resources :offers do
    member do
      post :publish
    end
    get :bulk_add_invitations, to: 'offer_invitations#bulk_add'
    post :bulk_create_invitations, to: 'offer_invitations#bulk_create'
    resource :offer_invitation, as: :invitation, only: [] do
      member do
        post :accept
        post :decline
      end
    end
  end
end
