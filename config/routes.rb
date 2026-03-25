Rails.application.routes.draw do
  namespace :api do
    resources :notes, only: [:index, :show, :create, :update, :destroy]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
