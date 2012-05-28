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
    root to: "site#sunset"
    match '/home' => "site#index", as: :home
    match 'feed.atom' => 'site#index', format: false, defaults: { format: 'atom' }, as: :atom_feed
    match '/tour' => 'site#tour'

    resources :announcements, only: [:index], path: 'news-and-speeches'
    resources :policies, only: [:index, :show] do
      resources :supporting_pages, path: "supporting-pages", only: [:index, :show]
    end
    resources :news_articles, path: 'news', only: [:show, :index]
    resources :publications, only: [:index, :show] do
      get '/by-policy-topic/:policy_topics', on: :collection,
        to: 'publications#by_policy_topic', as: :by_policy_topic
    end

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

    resources :policy_topics, path: "policy-topics", only: [:index, :show]
    resources :organisations, only: [:index, :show] do
      collection do
        get :alphabetical
      end
      member do
        get :about
        get :announcements, path: 'news-and-speeches'
        get :consultations
        get :contact_details, path: 'contact-details'
        get :ministers
        get :management_team, path: 'management-team'
        get :agencies_and_partners, path: 'agencies-and-partners'
        get :policies
        get :publications
      end
    end
    resources :ministerial_roles, path: 'ministers', only: [:index, :show]
    resources :countries, path: 'world', only: [:index, :show] do
      member do
        get :about
      end
    end

    match "/search" => "search#index"
    match "/autocomplete" => "search#autocomplete"

    constraints(AdminRequest) do
      namespace :admin do
        root to: redirect('/admin/documents')

        resource :user, only: [:show, :edit, :update]
        resources :authors, only: [:show]
        resources :organisations, except: [:show, :destroy]
        resources :document_organisations, only: [:update], as: :edition_organisations, controller: :edition_organisations
        resources :document_countries, only: [:update], as: :edition_countries, controller: :edition_countries
        resources :policy_topics, path: "policy-topics", except: [:show] do
          member do
            post :feature
            post :unfeature
          end
        end

        resources :documents, only: [:index], controller: :editions do
          member do
            post :submit, to: 'edition_workflow#submit'
            post :revise
            post :reject, to: 'edition_workflow#reject'
            post :publish, to: 'edition_workflow#publish'
          end
          resource :featuring, only: [:create, :update, :destroy]
          resources :supporting_pages, path: "supporting-pages", except: [:index]
          resources :fact_check_requests, only: [:show, :create, :edit, :update], shallow: true
          resources :editorial_remarks, only: [:new, :create], shallow: true
        end

        resources :publications, except: [:index]

        resources :policies, except: [:index]
        resources :international_priorities, path: "international-priorities", except: [:index]
        resources :news_articles, path: 'news', except: [:index]
        resources :consultations, except: [:index]
        resources :consultation_responses, path: 'responses', except: [:index]
        resources :speeches, except: [:index]
        resources :people, except: [:show]
        resources :roles, except: [:show]
        resources :countries, only: [:index, :edit, :update]

        match "preview" => "preview#preview", via: :post
      end
    end

    match '/topics' => redirect("/policy-topics")

    match 'site/sha' => 'site#sha'
    match 'site/headers' => 'site#headers'
    match 'site/grid' => 'site#grid'
    match '/home/grid' => 'home#show'
  end

  VanityRedirector.new(Rails.root.join("app", "data", "vanity-redirects.csv")).each do |from, to|
    match from, to: redirect(to)
    match from.upcase, to: redirect(to)
  end

  mount TestTrack::Engine => "test" if Rails.env.test?
end
