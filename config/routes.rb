class AdminRequest
  def self.matches?(request)
    !invalid_admin_host?(request.host)
  end

  def self.invalid_admin_host?(host)
    Rails.env.production? && Whitehall.admin_host != host
  end
end

Whitehall::Application.routes.draw do
  def redirect(path, options = {prefix: Whitehall.router_prefix})
    super(options[:prefix] + path)
  end

  def external_redirect(path_prefix, target)
    get path_prefix => redirect(target, prefix: '')
    get "#{path_prefix}/*anything" => redirect(target, prefix: '')
  end

  root to: redirect("/admin/"), constraints: lambda { |request|
    ::Whitehall.admin_host == request.host
  }

  get '/government/ministers/minister-of-state--11' => redirect('/government/people/kris-hopkins', prefix: '')

  namespace 'api' do
    resources :governments, only: [:index, :show], defaults: { format: :json }
    resources :organisations, only: [:index, :show], defaults: { format: :json }
    resources :world_locations, path: 'world-locations', only: [:index, :show], defaults: { format: :json } do
      resources :worldwide_organisations, path: 'organisations', only: [:index], defaults: { format: :json }
    end
    resources :worldwide_organisations, path: 'worldwide-organisations', only: [:show], defaults: { format: :json }
  end

  # World locations and Worldwide organisations
  get '/world/organisations/:organisation_id/office' => redirect('/world/organisations/%{organisation_id}', prefix: '')
  get '/world/organisations/:organisation_id/about' => redirect('/world/organisations/%{organisation_id}', prefix: '')
  resources :worldwide_organisations, path: 'world/organisations', only: [:show], localised: true do
    resources :corporate_information_pages, only: [:show], path: 'about', localised: true
    # Dummy path for the sake of polymorphic_path: will always be directed above.
    get :about
    resources :worldwide_offices, path: 'office', only: [:show]
  end

  resources :embassies, path: 'world/embassies', only: [:index]

  resources :world_locations, path: 'world', only: [:index, :show], localised: true do
    resources :world_location_news, path: 'news', only: [:index]
  end

  scope Whitehall.router_prefix, shallow_path: Whitehall.router_prefix do
    external_redirect '/organisations/ministry-of-defence-police-and-guarding-agency',
      "http://webarchive.nationalarchives.gov.uk/20121212174735/http://www.mod.uk/DefenceInternet/AboutDefence/WhatWeDo/SecurityandIntelligence/MDPGA/"

    root to: redirect("/", { prefix: '' }), via: :get, as: :main_root
    get "/how-government-works" => "home#how_government_works", as: 'how_government_works'
    scope '/get-involved' do
      root to: 'home#get_involved', as: :get_involved, via: :get
      get 'take-part' => redirect('/get-involved#take-part')

      # Controller removed. Whitehall frontend no longer serves these
      # pages however the route is needed to generate path and url
      # helper methods.
      # TODO: Remove when take part page paths can be otherwise generated
      get 'take-part/:id', to: 'take_part_pages#show', as: 'take_part_page'
    end

    # Past foreign secretaries are currently hard-coded, so this
    # resource falls straight through to views.
    resources :past_foreign_secretaries, path: "/history/past-foreign-secretaries", only: [:index, :show]
    # Past chancellors is also hard-coded
    get "history/past-chancellors" => 'historic_appointments#past_chancellors'

    # Past foreign secretaries and past chancellors are here for the
    # purposes of reversing URLs in a consistent way from other views.

    # TODO: make these dynamic, they're hard-coded above.
    get "/history/:role" => "historic_appointments#index", constraints: { role: /(past-prime-ministers)|(past-chancellors)|(past-foreign-secretaries)/ }, as: 'historic_appointments'
    get "/history/:role/:person_id" => "historic_appointments#show", constraints: { role: /(past-prime-ministers)|(past-chancellors)|(past-foreign-secretaries)/ }, as: 'historic_appointment'
    resources :histories, path: "history", only: [:index, :show]

    resource :email_signups, path: 'email-signup', only: [:create, :new]
    get "/email-signup", to: redirect('/')

    get '/feed' => 'home#feed', defaults: { format: :atom }, constraints: { format: :atom }, as: :atom_feed
    get '/tour' => redirect("/tour", prefix: "")

    resources :announcements, only: [:index], path: 'announcements', localised: true
    resources :news_articles, path: 'news', only: [:show], localised: true
    resources :fatality_notices, path: 'fatalities', only: [:show]
    get "/news" => redirect("/announcements"), as: 'news_articles'
    get "/fatalities" => redirect("/announcements"), as: 'fatality_notices'

    get "/latest" => 'latest#index', as: 'latest'

    resources :publications, only: [:index, :show], localised: true
    get "/publications/:publication_id/:id" => 'html_attachments#show', as: 'publication_html_attachment'

    resources :case_studies, path: 'case-studies', only: [:show], localised: true
    resources :speeches, only: [:show], localised: true
    # TODO: Remove when paths can be generated without a routes entry
    resources :statistical_data_sets, path: 'statistical-data-sets', only: [:show]
    get "/speeches" => redirect("/announcements")

    # Controller removed for stats announce show. Whitehall frontend no longer serves these
    # pages however the route is needed to generate path and url
    # helper methods.
    # TODO: Remove `:show` when stats announcement paths can be otherwise generated
    resources :statistics_announcements, path: 'statistics/announcements', only: [:index, :show]
    resources :statistics, only: [:index, :show], localised: true
    resources :world_location_news_articles, path: 'world-location-news', only: [:index, :show], localised: true

    resources :consultations, only: [:index, :show] do
      collection do
        get :open
        get :closed
        get :upcoming
      end
    end
    get "/consultations/:consultation_id/:id" => 'html_attachments#show', as: 'consultation_html_attachment'

    resources :topics, path: "topics", only: [:show]
    resources :topical_events, path: "topical-events", only: [:show] do
      # Controller removed. Whitehall frontend no longer serves these
      # pages however the route is needed to generate path and url
      # helper methods.
      # TODO: Remove when about page paths can be otherwise generated
      resource :about_pages, path: "about", only: [:show]
    end

    resources :document_collections, only: [:show], path: 'collections'
    get '/collections' => redirect("/publications")
    resources :organisations, only: [:index], localised: false
    resources :organisations, only: [:show], localised: true do
      get '/series/:slug' => redirect("/collections/%{slug}")
      get '/series' => redirect("/publications")

      member do
        get :consultations
        get :chiefs_of_staff, path: 'chiefs-of-staff'
      end
      resources :corporate_information_pages, only: [:show, :index], path: 'about', localised: true
      resources :groups, only: [:show]
    end
    get "/organisations/:organisation_id/groups" => redirect("/organisations/%{organisation_id}")
    get "/organisations/:organisation_slug/email-signup" => 'email_signup_information#show',
      as: :organisation_email_signup_information

    resources :ministerial_roles, path: 'ministers', only: [:index, :show], localised: true
    resources :people, only: :show, localised: true

    # TODO: Remove `:show` when policy group paths can be otherwise generated
    resources :policy_groups, path: 'groups', only: [:show]
    resources :operational_fields, path: 'fields-of-operation', only: [:index, :show]

    # Redirect everything under /government/world to /world
    # It may look like we're redirecting back to the same page but the
    # source is automatically prefixed with /government by Rails.
    get '/world' => redirect('/world', prefix: '')
    get '/world/*page' => redirect('/world/%{page}', prefix: '')

    constraints(AdminRequest) do
      namespace :admin do
        root to: 'dashboard#index', via: :get

        get 'find-in-admin-bookmarklet' => 'find_in_admin_bookmarklet#index', as: :find_in_admin_bookmarklet_instructions_index
        get 'find-in-admin-bookmarklet/:browser' => 'find_in_admin_bookmarklet#show', as: :find_in_admin_bookmarklet_instructions
        get 'by-content-id/:content_id' => 'documents#by_content_id'

        resources :users, only: [:index, :show, :edit, :update]

        resources :authors, only: [:show]
        resource :document_searches, only: [:show]
        resources :document_collections, path: "collections", except: [:index] do
          resources :document_collection_groups, as: :groups, path: 'groups' do
            member { get :delete }
            resource :document_collection_group_membership, as: :members,
                                                        path: 'members',
                                                        only: [:destroy]
          end
          resource :document_collection_group_membership, as: :new_member,
                                                      path: 'members',
                                                      only: [:create]
          post 'groups/update_memberships' => 'document_collection_groups#update_memberships', as: :update_group_memberships
        end
        resources :organisations do
          resources :groups, except: [:show]
          resources :corporate_information_pages do
            resources :translations, controller: 'corporate_information_pages_translations'
          end
          resources :contacts do
            resources :translations, controller: 'contact_translations', only: [:create, :edit, :update, :destroy]
            member do
              post :remove_from_home_page
              post :add_to_home_page
            end
            post :reorder_for_home_page, on: :collection
          end
          resources :social_media_accounts
          resources :translations, controller: 'organisation_translations'
          resources :promotional_features do
            resources :promotional_feature_items, as: :items, path: 'items', except: [:index]
          end
          member do
            get :features, localised: true
            get :people
          end
          resources :financial_reports, except: [:show]
          resources :offsite_links
          resources :featured_policies do
            post :reorder, on: :collection
          end
        end
        resources :corporate_information_pages, only: [] do
          resources :attachments, except: [:show] do
            put :order, on: :collection
          end
        end
        resources :policy_groups, path: 'groups', except: [:show] do
          resources :attachments do
            put :order, on: :collection
          end
        end
        resources :operational_fields, except: [:show]
        resources :edition_organisations, only: [:edit, :update]
        resources :topics, path: "topics" do
          resources :classification_featurings, path: "featurings" do
            put :order, on: :collection
          end
        resources :offsite_links
        end
        resources :topical_events, path: "topical-events" do
          resource :about_pages, path: 'about'
          resources :classification_featurings, path: "featurings" do
            put :order, on: :collection
          end
          resources :offsite_links
        end

        resources :worldwide_organisations do
          member do
            put :set_main_office
            get :access_info
          end
          resource :access_and_opening_time, path: 'access_info', except: [:index, :show, :new]
          resources :translations, controller: 'worldwide_organisations_translations'
          resources :worldwide_offices, path: 'offices', except: [:show] do
            member do
              post :remove_from_home_page
              post :add_to_home_page
            end
            post :reorder_for_home_page, on: :collection
            resource :access_and_opening_time, path: 'access_info', except: [:index, :show, :new]
            resources :translations, controller: 'worldwide_office_translations', only: [:create, :edit, :update, :destroy]
          end
          resources :corporate_information_pages do
            resources :translations, controller: 'corporate_information_pages_translations'
          end
          resources :social_media_accounts
        end

        resources :editions, only: [:index] do
          resource :tags, only: [:edit, :update], controller: :edition_tags

          collection do
            post :export
            get :confirm_export
          end
          member do
            post :submit, to: 'edition_workflow#submit'
            post :revise
            get  :diff
            post :approve_retrospectively, to: 'edition_workflow#approve_retrospectively'
            post :reject, to: 'edition_workflow#reject'
            post :publish, to: 'edition_workflow#publish'
            get  :confirm_force_publish, to: 'edition_workflow#confirm_force_publish'
            post :force_publish, to: 'edition_workflow#force_publish'
            get  :confirm_unpublish, to: 'edition_workflow#confirm_unpublish'
            post :unpublish, to: 'edition_workflow#unpublish'
            get  :confirm_unwithdraw, to: 'edition_workflow#confirm_unwithdraw'
            post :unwithdraw, to: 'edition_workflow#unwithdraw'
            post :schedule, to: 'edition_workflow#schedule'
            post :force_schedule, to: 'edition_workflow#force_schedule'
            post :unschedule, to: 'edition_workflow#unschedule'
            post :convert_to_draft, to: 'edition_workflow#convert_to_draft'
            get :audit_trail, to: 'edition_audit_trail#index'
          end
          resources :link_check_reports
          resource :unpublishing, controller: 'edition_unpublishing', only: [:edit, :update]
          resources :translations, controller: "edition_translations", except: [:index, :show]
          resources :editorial_remarks, only: [:new, :create], shallow: true
          resources :fact_check_requests, only: [:show, :create, :edit, :update], shallow: true
          resource :document_sources, path: "document-sources", except: [:show]
          resources :attachments, except: [:show] do
            put :order, on: :collection
            put :update_many, on: :collection, constraints: {format: "json"}
          end
          resources :bulk_uploads, except: [:show, :edit, :update] do
            post :upload_zip, on: :collection
            get :set_titles, on: :member
          end
        end

        get "/editions/:id" => "editions#show"

        resources :statistics_announcements, except: [:destroy] do
          member do
            get :cancel
            get :cancel_reason
            post :publish_cancellation
          end
          resource :tags, only: [:edit, :update], controller: :statistics_announcement_tags
          resources :statistics_announcement_date_changes, as: 'changes', path: 'changes'
          resource :statistics_announcement_unpublishings, as: 'unpublish', path: 'unpublish', only: [:new, :create]
        end

        resources :suggestions, only: [:index]

        resources :publications, except: [:index]

        get "/policies/:policy_id/topics" => "policies#topics"

        resources :news_articles, path: 'news', except: [:index]
        resources :world_location_news_articles, path: 'world-location-news', except: [:index, :new, :create]
        resources :fatality_notices, path: 'fatalities', except: [:index]
        resources :consultations, except: [:index] do
          resource :outcome, controller: 'responses', type: 'ConsultationOutcome', except: [:new, :destroy]
          resource :public_feedback, controller: 'responses', type: 'ConsultationPublicFeedback', except: [:new, :destroy]
        end
        resources :responses, only: :none do
          resources :attachments do
            put :order, on: :collection
          end
        end

        resources :speeches, except: [:index]
        resources :statistical_data_sets, path: 'statistical-data-sets', except: [:index]
        resources :detailed_guides, path: "detailed-guides", except: [:index]
        resources :people do
          resources :translations, controller: 'person_translations'
          resources :historical_accounts
        end
        resource :cabinet_ministers, only: [:show, :update]
        resources :roles, except: [:show] do
          resources :role_appointments, only: [:new, :create, :edit, :update, :destroy], shallow: true
          resources :translations, controller: 'role_translations'
        end
        resources :world_locations, only: [:index, :edit, :update, :show] do
          member do
            get :features, localised: true
          end
          resources :translations, controller: 'world_location_translations'
          resources :offsite_links
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

        resources :governments, except: [:destroy] do
          member do
            get :prepare_to_close, path: "prepare-to-close"
            post :close
          end
        end

        post "preview" => "preview#preview"

        scope '/get-involved' do
          root to: 'get_involved#index', as: :get_involved, via: :get
          resources :take_part_pages, except: [:show] do
            post :reorder, on: :collection
          end
        end

        resources :sitewide_settings
        post "/link_checker_api_callback" => "link_checker_api#callback"
      end
    end

    get '/policy-topics' => redirect("/topics")

    get '/placeholder' => 'placeholder#show', as: :placeholder
  end

  resources :organisations, only: [:index, :show], path: 'courts-tribunals', localised: true,
    as: :courts, courts_only: true

  get 'healthcheck' => 'healthcheck#check'
  get 'healthcheck/overdue' => 'healthcheck#overdue'

  # TODO: Remove when paths for new content can be generated without a route helper
  get '/guidance/:id' => 'detailed_guides#show', constraints: {id: /[A-z0-9\-]+/}, as: 'detailed_guide', localised: true

  get '/government/uploads/system/uploads/consultation_response_form/*path.:extension' => LongLifeRedirect.new('/government/uploads/system/uploads/consultation_response_form_data/')
  get '/government/uploads/system/uploads/attachment_data/file/:id/*file.:extension' => "attachments#show"
  get '/government/uploads/system/uploads/attachment_data/file/:id/*file.:extension/preview' => "attachments#preview", as: :preview_attachment
  get '/government/uploads/*path.:extension' => "public_uploads#show", as: :public_upload

  mount TestTrack::Engine => "test" if Rails.env.test?
end
