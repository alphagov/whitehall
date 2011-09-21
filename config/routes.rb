Whitehall::Application.routes.draw do
  root :to => 'policies#index'
  resources :policies, :except => [:destroy]

  resource :session, :only => [:create]
  match 'login' => 'sessions#new'
  match 'styleguide' => 'styleguide#index'
end
