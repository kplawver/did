Rails.application.routes.draw do
  devise_for :users

  namespace :users do
    resources :passkey_registrations, only: [ :new, :create, :destroy ]
    resource :passkey_authentication, only: [ :create ] do
      get :challenge
    end
    resource :passkey_setup, only: [ :show ] do
      post :skip
    end
  end

  authenticated :user do
    root "journal#show", as: :authenticated_root
  end

  resources :todo_items, only: [ :create, :update, :destroy ]
  resources :entries, only: [ :create, :destroy ]

  get "journal(/:date)", to: "journal#show", as: :journal, constraints: { date: /\d{4}-\d{2}-\d{2}/ }

  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#home"
end
