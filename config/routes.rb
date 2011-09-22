Whitehall::Application.routes.draw do
  root :to => 'policies#index'
  resources :policies, :except => [:destroy] do
    collection do
      get :submitted
    end
    member do
      post :publish
    end
  end

  resource :session, :only => [:create]
  match 'login' => 'sessions#new'
  match 'styleguide' => 'styleguide#index'
end
