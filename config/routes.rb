class AdminRequest
  def self.matches?(request)
    not Whitehall.government_single_domain?(request)
  end
end

Whitehall::Application.routes.draw do
  def redirect(path)
    super(Whitehall.router_prefix + path)
  end

  root to: redirect("/")

  scope Whitehall.router_prefix, shallow_path: Whitehall.router_prefix do
    root to: "site#index"
    match 'feed.atom' => 'site#index', format: false, defaults: { format: 'atom' }, as: :atom_feed

    resources :announcements, only: [:index], path: 'news-and-speeches'
    resources :policies, only: [:index, :show] do
      resources :supporting_pages, path: "supporting-pages", only: [:index, :show]
    end
    resources :news_articles, path: 'news', only: [:show, :index]
    resources :publications, only: [:index, :show]
    resources :international_priorities, path: "international-priorities", only: [:index, :show]
    resources :consultations, only: [:index, :show] do
      collection do
        get :open
        get :closed
        get :upcoming
      end

      resource :response, only: [:show], controller: :consultation_responses
    end

    resources :speeches, only: [:index, :show]

    resources :policy_areas, path: "policy-areas", only: [:index, :show]
    resources :organisations, only: [:index, :show] do
      collection do
        get :alphabetical
      end
      member do
        get :about
        get :news
      end
    end
    resources :ministerial_roles, path: 'ministers', only: [:index, :show]
    resources :countries, path: 'world', only: [:index, :show]

    match "/search" => "search#index"
    match "/autocomplete" => "search#autocomplete"

    constraints(AdminRequest) do
      namespace :admin do
        root to: redirect('/admin/documents')

        resource :user, only: [:show, :edit, :update]
        resources :organisations, only: [:index, :new, :create, :edit, :update]
        resources :document_organisations, only: [:update]
        resources :policy_areas, path: "policy-areas", only: [:index, :new, :create, :edit, :update, :destroy] do
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
          resource :featuring, only: [:create, :update, :destroy]
          resources :supporting_pages, path: "supporting-pages",
                    only: [:new, :create, :show, :edit, :update, :destroy], shallow: true
          resources :fact_check_requests, only: [:show, :create, :edit, :update], shallow: true
          resources :editorial_remarks, only: [:new, :create], shallow: true
        end

        resources :publications, only: [:new, :create, :edit, :update, :show, :destroy]

        resources :policies, only: [:new, :create, :edit, :update, :show, :destroy]
        resources :international_priorities, path: "international-priorities", only: [:new, :create, :edit, :update, :show, :destroy]
        resources :news_articles, path: 'news', only: [:new, :create, :edit, :update, :show, :destroy]
        resources :consultations, only: [:new, :create, :edit, :update, :show, :destroy]
        resources :consultation_responses, path: 'responses', only: [:new, :create, :edit, :update, :show, :destroy]
        resources :speeches, only: [:new, :create, :edit, :update, :show, :destroy]
        resources :people, only: [:index, :new, :create, :edit, :update, :destroy]
        resources :roles, only: [:index, :new, :create, :edit, :update, :destroy]
        resources :countries, only: [:index, :edit, :update]

        match "preview" => "preview#preview", via: :post
      end
    end

    match 'styleguide' => 'styleguide#index'
    match '/topics' => redirect("/policy-areas")

    match 'site/sha' => 'site#sha'
    match 'site/headers' => 'site#headers'
  end

  mount TestTrack::Engine => "test" if Rails.env.test?
end