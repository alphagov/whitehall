Whitehall::Application.routes.draw do
  resources :policies, :except => [:destroy]

  match 'styleguide' => 'styleguide#index'
end
