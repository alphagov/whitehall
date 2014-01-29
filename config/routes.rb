class AdminRequest
  def self.matches?(request)
    Whitehall.admin_whitelist?(request)
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
    ::Whitehall.admin_hosts.include?(request.host)
  }

  get '/government/ministers/minister-of-state--11' => redirect('/government/people/kris-hopkins', prefix: '')

  get '/browse/*parent_tag/:id', to: 'mainstream_categories#show'

  namespace 'api' do
    resources :detailed_guides, path: 'specialist', only: [:show, :index], defaults: { format: :json } do
      collection do
        get :tags
      end
    end
    resources :organisations, only: [:index, :show], defaults: { format: :json }
    resources :world_locations, path: 'world-locations', only: [:index, :show], defaults: { format: :json } do
      resources :worldwide_organisations, path: 'organisations', only: [:index], defaults: { format: :json }
    end
    resources :worldwide_organisations, path: 'worldwide-organisations', only: [:show], defaults: { format: :json }
  end

  scope Whitehall.router_prefix, shallow_path: Whitehall.router_prefix do
    external_redirect '/organisations/ministry-of-defence-police-and-guarding-agency',
      "http://webarchive.nationalarchives.gov.uk/20121212174735/http://www.mod.uk/DefenceInternet/AboutDefence/WhatWeDo/SecurityandIntelligence/MDPGA/"

    root to: redirect("/", { prefix: '' }), via: :get, as: :main_root
    get "/how-government-works" => "home#how_government_works", as: 'how_government_works'
    scope '/get-involved' do
      root to: 'home#get_involved', as: :get_involved, via: :get
      get 'take-part' => redirect('/get-involved#take-part')
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
    resources :policies, only: [:index, :show], localised: true do
      member do
        get :activity
      end
      resources :supporting_pages, path: "supporting-pages", only: [:index, :show]
    end
    resources :news_articles, path: 'news', only: [:show], localised: true
    resources :fatality_notices, path: 'fatalities', only: [:show]
    get "/news" => redirect("/announcements"), as: 'news_articles'
    get "/fatalities" => redirect("/announcements"), as: 'fatality_notices'

    resources :publications, only: [:index, :show], localised: true
    get "/publications/:publication_id/:id" => 'html_attachments#show', as: 'publication_html_attachment'

    resources :case_studies, path: 'case-studies', only: [:show, :index], localised: true
    resources :speeches, only: [:show], localised: true
    resources :statistical_data_sets, path: 'statistical-data-sets', only: [:index, :show]
    get "/speeches" => redirect("/announcements")
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
    get "/consultations/:consultation_id/:id" => 'html_attachments#show', as: 'consultation_html_attachment'

    resources :topics, path: "topics", only: [:index, :show]
    resources :topical_events, path: "topical-events", only: [:index, :show] do
      resource :about_pages, path: "about", only: [:show]
    end

    resources :document_collections, only: [:show], path: 'collections'
    get '/collections' => redirect("/publications")
    resources :organisations, only: [:index], localised: false
    resources :organisations, only: [:show], localised: true do
      get '/series/:slug' => redirect("/collections/%{slug}")
      get '/series' => redirect("/publications")

      member do
        get :about, localised: true
        get :consultations
        get :chiefs_of_staff, path: 'chiefs-of-staff'
      end
      resources :corporate_information_pages, only: [:show], path: 'about'
      resources :groups, only: [:show]
    end
    get "/organisations/:organisation_id/groups" => redirect("/organisations/%{organisation_id}")

    resources :ministerial_roles, path: 'ministers', only: [:index, :show], localised: true
    resources :people, only: [:index, :show], localised: true

    resources :policy_teams, path: 'policy-teams', only: [:index, :show]
    resources :policy_advisory_groups, path: 'policy-advisory-groups', only: [:index, :show]
    resources :operational_fields, path: 'fields-of-operation', only: [:index, :show]
    resources :worldwide_organisations, path: 'world/organisations', only: [:show, :index], localised: true do
      resources :corporate_information_pages, only: [:show], path: 'about', localised: true
      resources :worldwide_offices, path: 'office', only: [:show]
    end
    resources :world_locations, path: 'world', only: [:index, :show], localised: true
    get 'world/organisations/:organisation_id/office' =>redirect('/world/organisations/%{organisation_id}')
    get 'world/organisations/:organisation_id/about' => redirect('/world/organisations/%{organisation_id}')

    constraints(AdminRequest) do
      namespace :admin do
        root to: 'dashboard#index', via: :get

        get 'find-in-admin-bookmarklet' => 'find_in_admin_bookmarklet#index', as: :find_in_admin_bookmarklet_instructions_index
        get 'find-in-admin-bookmarklet/:browser' => 'find_in_admin_bookmarklet#show', as: :find_in_admin_bookmarklet_instructions

        resources :users, only: [:index, :show, :edit, :update]
        resources :user_needs, only: [:create]

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
            get :about
            get :people
          end
          resource :featured_topics_and_policies_list, path: 'featured-topics-and-policies', only: [:show, :update]
          resources :financial_reports, except: [:show]
        end
        resources :corporate_information_pages, only: [] do
          resources :attachments, except: [:show] do
            put :order, on: :collection
          end
        end
        resources :policy_teams, except: [:show]
        resources :policy_advisory_groups, except: [:show] do
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
        end
        resources :topical_events, path: "topical-events" do
          resource :about_pages, path: 'about'
          resources :classification_featurings, path: "featurings" do
            put :order, on: :collection
          end
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
            post :schedule, to: 'edition_workflow#schedule'
            post :unschedule, to: 'edition_workflow#unschedule'
            post :convert_to_draft, to: 'edition_workflow#convert_to_draft'
            get :audit_trail, to: 'edition_audit_trail#index'
          end
          resources :translations, controller: "edition_translations", except: [:index, :show]
          resources :editorial_remarks, only: [:new, :create], shallow: true
          resources :fact_check_requests, only: [:show, :create, :edit, :update], shallow: true
          resource :document_sources, path: "document-sources", except: [:show]
          resources :attachments, except: [:show] do
            put :order, on: :collection
          end
          resources :bulk_uploads, except: [:show, :edit, :update] do
            post :upload_zip, on: :collection
            get :set_titles, on: :member
          end
        end

        # Ensure that supporting page routes are just ids in admin
        get "/editions/:edition_id/supporting-pages/:id" => "supporting_pages#show", constraints: {id: /[0-9]+/}
        get '/editions/:policy_id/supporting-pages/new', constraints: {id: /(\d+)/}, to: redirect("/admin/supporting-pages/new?edition[related_policy_ids][]=%{policy_id}"), as: 'new_policy_supporting_page'

        get "/editions/:id" => "editions#show"

        resources :suggestions, only: [:index]

        resources :publications, except: [:index]

        resources :policies, except: [:index] do
          member { get :topics }
        end
        resources :supporting_pages, path: "supporting-pages", except: [:index]
        resources :worldwide_priorities, path: "priority", except: [:index]
        resources :news_articles, path: 'news', except: [:index]
        resources :world_location_news_articles, path: 'world-location-news', except: [:index]
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
            get :new_document_list
            get :error_list
            get :import_log
          end
        end

        resources :email_curation_queue_items, path: 'email-curation-queue', except: [:show, :new, :create] do
          post :send_to_subscribers, on: :member
        end

        post "preview" => "preview#preview"

        scope '/get-involved' do
          root to: 'get_involved#index', as: :get_involved, via: :get
          resources :take_part_pages, except: [:show] do
            post :reorder, on: :collection
          end
        end
      end
    end

    get '/policy-topics' => redirect("/topics")


    get 'site/sha' => 'site#sha'

    get '/placeholder' => 'placeholder#show', as: :placeholder
  end

  get 'healthcheck' => 'healthcheck#check'
  get 'healthcheck/overdue' => 'healthcheck#overdue'

  # XXX: we use a blank prefix here because redirect has been
  # overridden further up in the routes
  get '/specialist/:id', constraints: {id: /[A-z0-9\-]+/}, to: redirect("/%{id}", prefix: '')
  # Detailed guidance lives at the root
  get ':id' => 'detailed_guides#show', constraints: {id: /[A-z0-9\-]+/}, as: 'detailed_guide'

  get '/government/uploads/system/uploads/consultation_response_form/*path.:extension' => LongLifeRedirect.new('/government/uploads/system/uploads/consultation_response_form_data/')
  get '/government/uploads/system/uploads/attachment_data/file/:id/*file.:extension' => "attachments#show"
  get '/government/uploads/system/uploads/attachment_data/file/:id/*file.:extension/preview' => "attachments#preview", as: :preview_attachment
  get '/government/uploads/*path.:extension' => "public_uploads#show"

  mount TestTrack::Engine => "test" if Rails.env.test?
end
