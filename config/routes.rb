class AdminRequest
  def self.matches?(request)
    Whitehall.admin_whitelist?(request)
  end
end

Whitehall::Application.routes.draw do
  def redirect(path, options = {prefix: Whitehall.router_prefix})
    super(options[:prefix] + path)
  end

  root to: redirect("/admin/"), constraints: lambda { |request|
    ::Whitehall.admin_hosts.include?(request.host)
  }
  root to: redirect("/")

  match '/browse/*parent_tag/:id', to: 'mainstream_categories#show'

  namespace 'api' do
    resources :detailed_guides, path: 'specialist', only: [:show, :index], defaults: { format: :json } do
      collection do
        get :tags
      end
    end
    resources :world_locations, path: 'world-locations', only: [:index, :show], defaults: { format: :json } do
      resources :worldwide_organisations, path: 'organisations', only: [:index], defaults: { format: :json }
    end
    resources :worldwide_organisations, path: 'worldwide-organisations', only: [:show], defaults: { format: :json }
  end

  scope Whitehall.router_prefix, shallow_path: Whitehall.router_prefix do
    root to: "home#home"
    match "/how-government-works" => "home#how_government_works", as: 'how_government_works'
    match "/history" => "home#history", as: 'history'
    match "/get-involved" => "home#get_involved", as: 'get_involved'
    match '/feed' => 'home#feed', defaults: { format: :atom }, constraints: { format: :atom }, as: :atom_feed
    match '/tour' => redirect("/tour", prefix: "")

    resources :announcements, only: [:index], path: 'announcements', localised: true
    resources :policies, only: [:index], localised: true
    resources :policies, only: [:show] do
      member do
        get :activity
      end
      resources :supporting_pages, path: "supporting-pages", only: [:index, :show]
    end
    resources :news_articles, path: 'news', only: [:show], localised: true
    resources :fatality_notices, path: 'fatalities', only: [:show]
    match "/news" => redirect("/announcements")
    match "/fatalities" => redirect("/announcements")

    resources :publications, only: [:index, :show], localised: true
    match "/publications/:publication_id/:id" => 'html_versions#show', as: 'publication_html_version'

    resources :case_studies, path: 'case-studies', only: [:show, :index], localised: true
    resources :speeches, only: [:show], localised: true
    resources :statistical_data_sets, path: 'statistical-data-sets', only: [:index, :show]
    match "/speeches" => redirect("/announcements")
    resources :world_location_news_articles, path: 'world-location-news', only: [:index, :show], localised: true

    resources :worldwide_priorities, path: "priority", only: [:index, :show], localised: true do
      member do
        get :activity
      end
    end

    resources :consultations, only: [:index, :show] do
      collection do
        get :open
        get :closed
        get :upcoming
      end
    end

    resources :topics, path: "topics", only: [:index, :show]
    resources :topical_events, path: "topical-events", only: [:index, :show]

    resources :organisations, only: [:index, :show], localised: true do
      resources :document_series, only: [:index, :show], path: 'series'
      member do
        get :about, localised: true
        get :consultations
        get :chiefs_of_staff, path: 'chiefs-of-staff'
      end
      resources :corporate_information_pages, only: [:show], path: 'about'
      resources :groups, only: [:show]
    end
    match "/organisations/:organisation_id/groups" => redirect("/organisations/%{organisation_id}")

    resources :ministerial_roles, path: 'ministers', only: [:index, :show]
    resources :people, only: [:index, :show], localised: true
    resources :world_locations, path: 'world', only: [:index, :show], localised: true

    resources :policy_teams, path: 'policy-teams', only: [:index, :show]
    resources :policy_advisory_groups, path: 'policy-advisory-groups', only: [:index, :show]
    resources :operational_fields, path: 'fields-of-operation', only: [:index, :show]
    resources :worldwide_organisations, path: 'world/organisations', only: [:show], localised: true do
      resources :corporate_information_pages, only: [:show], path: 'about', localised: true
      resources :worldwide_offices, path: 'office', only: [:show]
    end
    match 'world/organisations/:organisation_id/office' =>redirect('/world/organisations/%{organisation_id}')
    match 'world/organisations/:organisation_id/about' => redirect('/world/organisations/%{organisation_id}')

    constraints(AdminRequest) do
      namespace :admin do
        root to: redirect('/admin/editions')

        resources :users, only: [:index, :show, :edit, :update]

        resources :authors, only: [:show]
        resources :document_series, only: [:index]
        resources :organisations do
          resources :groups, except: [:show]
          resources :document_series, except: [:index]
          resources :corporate_information_pages do
            resources :translations, controller: 'corporate_information_pages_translations'
          end
          resources :contacts
          resources :social_media_accounts
          resources :translations, controller: 'organisation_translations'
          member do
            get :documents, as: 'documents'
            get :document_series
            get :about
            get :people
          end
        end
        resources :policy_teams, except: [:show]
        resources :policy_advisory_groups, except: [:show]
        resources :operational_fields, except: [:show]
        resources :edition_organisations, only: [:edit, :update]
        resources :topics, path: "topics", except: [:show]
        resources :topical_events, path: "topical-events", except: [:show] do
          resources :classification_featurings, path: "featurings"
        end

        resources :worldwide_organisations do
          member do
            put :set_main_office
            get :offices
            get :access_info
          end
          resource :access_and_opening_time, path: 'access_info', except: [:index, :show, :new]
          resources :translations, controller: 'worldwide_organisations_translations'
          resources :worldwide_offices, path: 'offices', except: [:index, :show] do
            resource :access_and_opening_time, path: 'access_info', except: [:index, :show, :new]
          end
          resources :corporate_information_pages do
            resources :translations, controller: 'corporate_information_pages_translations'
          end
          resources :social_media_accounts
        end

        resources :editions, only: [:index] do
          member do
            post :submit, to: 'edition_workflow#submit'
            post :revise
            post :approve_retrospectively, to: 'edition_workflow#approve_retrospectively'
            post :reject, to: 'edition_workflow#reject'
            post :publish, to: 'edition_workflow#publish'
            get  :confirm_unpublish
            post :unpublish, to: 'edition_workflow#unpublish'
            post :schedule, to: 'edition_workflow#schedule'
            post :unschedule, to: 'edition_workflow#unschedule'
            post :convert_to_draft, to: 'edition_workflow#convert_to_draft'
          end
          resources :supporting_pages, path: "supporting-pages", except: [:index, :show]
          resources :translations, controller: "edition_translations", except: [:index, :show]
          resources :editorial_remarks, only: [:new, :create], shallow: true
          resources :fact_check_requests, only: [:show, :create, :edit, :update], shallow: true
          resource :document_sources, path: "document-sources", except: [:show]
        end

        # Ensure that supporting page routes are just ids in admin
        match "/editions/:edition_id/supporting-pages/:id" => "supporting_pages#show", constraints: {id: /[0-9]+/}, via: :get

        match "/editions/:id" => "editions#show", via: :get

        resources :publications, except: [:index]

        resources :policies, except: [:index]
        resources :worldwide_priorities, path: "priority", except: [:index]
        resources :news_articles, path: 'news', except: [:index]
        resources :world_location_news_articles, path: 'world-location-news', except: [:index]
        resources :fatality_notices, path: 'fatalities', except: [:index]
        resources :consultations, except: [:index]
        resources :speeches, except: [:index]
        resources :statistical_data_sets, path: 'statistical-data-sets', except: [:index]
        resources :detailed_guides, path: "detailed-guides", except: [:index]
        resources :people, except: [:show] do
          resources :translations, controller: 'person_translations'
        end
        resources :roles, except: [:show] do
          resources :role_appointments, only: [:new, :create, :edit, :update, :destroy], shallow: true
          resources :translations, controller: 'role_translations'
        end
        resources :world_locations, only: [:index, :edit, :update, :show] do
          get :features, localised: true
          resources :translations, controller: 'world_location_translations'
        end
        resources :feature_lists, only: [:show] do

          post :reorder, on: :member

          resources :features, only: [:new, :create] do
            post :unfeature, on: :member
          end
        end
        resources :case_studies, path: "case-studies", except: [:index]
        if Rails.env.test?
          resources :generic_editions, path: "generic-editions"
        end

        resources :imports do
          member do
            get :annotated
            post :run
            post :force_publish
            get :force_publish_log
          end
        end

        match "preview" => "preview#preview", via: :post
      end
    end

    match '/policy-topics' => redirect("/topics")


    match 'site/sha' => 'site#sha'

    match '/placeholder' => 'placeholder#show', as: :placeholder
  end

  get 'healthcheck' => 'healthcheck#check'
  get 'healthcheck/overdue' => 'healthcheck#overdue'

  # XXX: we use a blank prefix here because redirect has been
  # overridden further up in the routes
  match '/specialist/:id', constraints: {id: /[A-z0-9\-]+/}, to: redirect("/%{id}", prefix: '')
  # Detailed guidance lives at the root
  match ':id' => 'detailed_guides#show', constraints: {id: /[A-z0-9\-]+/}, as: 'detailed_guide'

  mount TestTrack::Engine => "test" if Rails.env.test?

  match '/government/uploads/system/uploads/consultation_response_form/*path.:extension' => LongLifeRedirect.new('/government/uploads/system/uploads/consultation_response_form_data/')
  match '/government/uploads/system/uploads/attachment_data/file/:id/*file.:extension' => "attachments#show"
  match '/government/uploads/*path.:extension' => "public_uploads#show"
end
