Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "home#index"

  resources :pr_sets do
    get 'latest', on: :collection
  end

  resources :workouts
  resources :exercises, only: [:index]

  resources :exercises do
    collection do
      get :search
    end
    member do
      post :add_synonym
      delete :unlink_synonym
      post :toggle_benchmark
    end
  end
end
