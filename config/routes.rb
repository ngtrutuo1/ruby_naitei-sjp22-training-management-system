Rails.application.routes.draw do
  scope "(:locale)", locale: /vi|en/ do
    get "static_pages/home"
    get "static_pages/help"
    get "static_pages/contact"

    root "static_pages#home"

    get "/signup", to: "users#new"
    post "/signup", to: "users#create"

    get "/login", to: "sessions#new"
    post "/login", to: "sessions#create"
    delete "/logout", to: "sessions#destroy"

    resources :users, except: %i(:index, :destroy)
    resources :account_activations, only: :edit
    resources :password_resets, only: %i(new create edit update)
    resources :courses, only: %i(show) do
      member do
        get :members
        get :subjects
      end
    end

    namespace :trainee do
      resources :daily_reports
    end
  end
end
