Rails.application.routes.draw do
  devise_for :users
  root "urls#index"

  resources :urls, only: [:create]

  namespace :api do
    namespace :v1 do
      resources :urls, only: [:index, :show, :create]
    end
  end

  namespace :admin do
    resources :urls, only: [:index, :destroy]
  end

  get "/:short_code", to: "urls#redirect", as: :short
end
