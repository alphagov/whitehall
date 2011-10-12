Whitehall::Application.routes.draw do
  root to: redirect('/topics')

  resources :documents, only: [:index, :show] do
    resources :supporting_documents, only: [:show]
  end

  resources :topics, only: [:index, :show]
  resources :organisations, only: [:index, :show]
  resources :ministers, only: [:index, :show], as: :ministerial_roles, controller: :ministerial_roles

  namespace :admin do
    root to: redirect('/admin/documents')
    resources :documents, except: [:destroy] do
      collection do
        get :submitted
        get :published
      end
      member do
        put :publish
        put :submit
        post :revise
      end

      resources :supporting_documents, only: [:new, :create, :show, :edit, :update], shallow: true
      resources :fact_check_requests, only: [:show, :create, :edit, :update]
    end
  end

  resource :session, only: [:create, :destroy]
  match 'login' => 'sessions#new', via: :get
  match 'logout' => 'sessions#destroy', via: :post
  match 'styleguide' => 'styleguide#index'
  match 'site/sha' => 'site#sha'
end