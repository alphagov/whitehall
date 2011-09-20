Whitehall::Application.routes.draw do
  root :to => 'policies#index'
  resources :policies, :except => [:destroy]

  match 'styleguide' => 'styleguide#index'
end
