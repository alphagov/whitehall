Whitehall::Application.routes.draw do
  root to: redirect('/topics')

  resources :announcements, only: [:index]
  resources :policies, only: [:index, :show] do
    resources :supporting_documents, only: [:index, :show]
  end
  resources :news, as: :news_articles, controller: :news_articles, only: [:show, :index]
  resources :publications, only: [:index, :show]
  resources :consultations, only: [:index, :show]
  resources :speeches, only: [:index, :show]

  resources :topics, only: [:index, :show]
  resources :organisations, only: [:index, :show]
  resources :ministers, only: [:index, :show], as: :ministerial_roles, controller: :ministerial_roles
  resources :countries, only: [:index, :show]

  namespace :admin do
    root to: redirect('/admin/documents')

    resource :user, only: [:show, :edit, :update]
    resources :organisations, only: [:index, :new, :create, :edit, :update]
    resources :topics, only: [:index, :new, :create, :edit, :update, :destroy]

    resources :documents, only: [:index] do
      collection do
        get :draft
        get :submitted
        get :rejected
        get :published
      end
      member do
        post :submit
        post :revise
      end
      resource :publishing, controller: :document_publishing, only: [:create]
      resources :supporting_documents, only: [:new, :create, :show, :edit, :update], shallow: true
      resources :fact_check_requests, only: [:show, :create, :edit, :update], shallow: true
      resources :editorial_remarks, only: [:new, :create], shallow: true
    end

    resources :publications, only: [:new, :create, :edit, :update, :show, :destroy]
    resources :policies, only: [:new, :create, :edit, :update, :show, :destroy]
    resources :news, as: :news_articles, controller: :news_articles, only: [:new, :create, :edit, :update, :show, :destroy]
    resources :consultations, only: [:new, :create, :edit, :update, :show, :destroy]
    resources :speeches, only: [:new, :create, :edit, :update, :show, :destroy]
    resources :people, only: [:index, :new, :create, :edit, :update, :destroy]

    match "preview" => "preview#preview", via: :post
  end

  resource :session, only: [:create, :destroy]
  match 'login' => 'sessions#new', via: :get
  match 'logout' => 'sessions#destroy', via: :post
  match 'styleguide' => 'styleguide#index'
  match 'site/sha' => 'site#sha'

  mount TestTrack::Engine => "test" if Rails.env.test?
end