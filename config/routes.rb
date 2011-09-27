Whitehall::Application.routes.draw do
  root to: 'policies#index'
  resources :policies, only: [:index, :show]

  namespace :admin do
    root to: 'editions#index'
    resources :editions, except: [:destroy] do
      collection do
        get :submitted
        get :published
      end
      member do
        put :publish
      end
    end
  end

  resource :session, only: [:create, :destroy]
  match 'login' => 'sessions#new', via: :get
  match 'logout' => 'sessions#destroy', via: :post
  match 'styleguide' => 'styleguide#index'
end
