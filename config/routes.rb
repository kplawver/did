Rails.application.routes.draw do
  devise_for :users

  namespace :users do
    resources :passkey_registrations, only: [ :new, :create, :destroy ]
    resource :passkey_authentication, only: [ :create ] do
      get :challenge
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#home"
end
