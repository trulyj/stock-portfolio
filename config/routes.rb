Rails.application.routes.draw do
  devise_for :users
  #devise_for :users, path_names: {
  #  sign_in: 'login', sign_out: 'logout',
  #  password: 'secret', confirmation: 'verification',
  #  registration: 'register', edit: 'edit/profile'
  #}

  root to: "homepage#index"
  resources :stocks

  get 'homepage/index'
  get 'transactions', to: "static#transactions", as: "transactions"
  get 'buy', to: "stocks#new", as: "buy"
  #get 'refresh', to: "stocks#show", as: "buy"

  #resources :users do
  #  member do
  #    get :stocks
  #  end
  #end
  #root 'homepage#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
