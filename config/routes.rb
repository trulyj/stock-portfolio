Rails.application.routes.draw do
  devise_for :users
  #devise_for :users, path_names: {
  #  sign_in: 'login', sign_out: 'logout',
  #  password: 'secret', confirmation: 'verification',
  #  registration: 'register', edit: 'edit/profile'
  #}

  get 'homepage/index'

  resources :stocks
  #resources :users do
  #  member do
  #    get :stocks
  #  end
  #end

  root to: "homepage#index"
  #root 'homepage#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
