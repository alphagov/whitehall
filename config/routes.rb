class AdminRequest
  def self.matches?(request)
    not Whitehall.government_single_domain?(request)
  end
end

Whitehall::Application.routes.draw do
  def redirect(path)
    super(Whitehall.router_prefix + path)
  end

  scope Whitehall.router_prefix, shallow_path: Whitehall.router_prefix do
    root to: redirect('/policy-areas')

    resources :announcements, only: [:index], path: 'news-and-speeches'
    resources :policies, only: [:index, :show] do
      resources "supporting-pages", controller: :supporting_pages, as: :supporting_pages,
                only: [:index, :show]
    end
    resources :news, as: :news_articles, controller: :news_articles, only: [:show, :index]
    resources :publications, only: [:index, :show]
    resources "international-priorities", controller: :international_priorities, as: :international_priorities, only: [:index, :show]
    resources :consultations, only: [:index, :show] do
      collection do
        get :open
        get :closed
        get :upcoming
      end
    end

    resources :speeches, only: [:index, :show]

    resources "policy-areas", as: :policy_areas, controller: :policy_areas, only: [:index, :show]
    resources :organisations, only: [:index, :show] do
      member do
        get :about
      end
    end
    resources :ministers, only: [:index, :show], as: :ministerial_roles, controller: :ministerial_roles
    resources :countries, only: [:index, :show]

    constraints(AdminRequest) do
      namespace :admin do
        root to: redirect('/admin/documents')

        resource :user, only: [:show, :edit, :update]
        resources :organisations, only: [:index, :new, :create, :edit, :update]
        resources "policy-areas", as: :policy_areas, controller: :policy_areas, only: [:index, :new, :create, :edit, :update, :destroy] do
          member do
            post :feature
            post :unfeature
          end
        end

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
          resources "supporting-pages", controller: :supporting_pages, as: :supporting_pages,
                    only: [:new, :create, :show, :edit, :update, :destroy], shallow: true
          resources :fact_check_requests, only: [:show, :create, :edit, :update], shallow: true
          resources :editorial_remarks, only: [:new, :create], shallow: true
        end

        resources :publications, only: [:new, :create, :edit, :update, :show, :destroy]
        resources :policies, only: [:new, :create, :edit, :update, :show, :destroy]
        resources "international-priorities", controller: :international_priorities, as: :international_priorities, only: [:new, :create, :edit, :update, :show, :destroy]
        resources :news, as: :news_articles, controller: :news_articles, only: [:new, :create, :edit, :update, :show, :destroy] do
          member do
            post :feature
            post :unfeature
          end
        end
        resources :consultations, only: [:new, :create, :edit, :update, :show, :destroy] do
          member do
            post :feature
            post :unfeature
          end
        end
        resources :speeches, only: [:new, :create, :edit, :update, :show, :destroy]
        resources :people, only: [:index, :new, :create, :edit, :update, :destroy]
        resources :roles, only: [:index, :new, :create, :edit, :update, :destroy]

        match "preview" => "preview#preview", via: :post
      end
    end

    resource :search, only: [:show]

    match 'styleguide' => 'styleguide#index'
    match '/topics' => redirect("/policy-areas")

    match 'site/sha' => 'site#sha'
    match 'site/headers' => 'site#headers'
  end

  mount TestTrack::Engine => "test" if Rails.env.test?
end