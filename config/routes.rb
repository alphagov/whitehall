Whitehall::Application.routes.draw do
  root to: redirect('/topics')

  resources :documents, only: [:index] do
    resources :supporting_documents, only: [:show]
  end

  resources :policies, only: [:show]
  resources :news_articles, only: [:show]
  resources :publications, only: [:show]
  resources :consultations, only: [:show]
  resources :speeches, only: [:show]
  resources :news_articles, controller: :documents, only: [:show]

  resources :topics, only: [:index, :show]
  resources :organisations, only: [:index, :show]
  resources :ministers, only: [:index, :show], as: :ministerial_roles, controller: :ministerial_roles

  namespace :admin do
    root to: redirect('/admin/documents')
    resources :organisations, only: [:index, :new, :create, :edit, :update]
    resources :documents, except: [:new, :create, :edit, :update, :show, :destroy] do
      collection do
        get :submitted
        get :published
      end
      member do
        post :publish
        post :submit
        post :revise
      end

      resources :supporting_documents, only: [:new, :create, :show, :edit, :update], shallow: true
      resources :fact_check_requests, only: [:show, :create, :edit, :update], shallow: true
    end

    resources :topics, only: [:index, :edit, :update]
    resources :publications, only: [:new, :create, :edit, :update, :show, :destroy]
    resources :policies, only: [:new, :create, :edit, :update, :show, :destroy]
    resources :news_articles, only: [:new, :create, :edit, :update, :show, :destroy]
    resources :consultations, only: [:new, :create, :edit, :update, :show, :destroy]
    resources :speeches, only: [:new, :create, :edit, :update, :show, :destroy]

    match "preview" => "preview#preview", via: :post
  end

  resource :session, only: [:create, :destroy]
  match 'login' => 'sessions#new', via: :get
  match 'logout' => 'sessions#destroy', via: :post
  match 'styleguide' => 'styleguide#index'
  match 'site/sha' => 'site#sha'

  mount TestTrack::Engine => "test" if Rails.env.test?
end