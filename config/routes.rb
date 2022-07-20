class AdminRequest
  def self.matches?(request)
    # Allow access to all routes in development, and restrict to the
    # internal or external admin host otherwise.
    !Rails.env.production? || valid_admin_host?(request.host)
  end

  def self.valid_admin_host?(host)
    [Whitehall.admin_host, Whitehall.internal_admin_host].include? host
  end
end

Whitehall::Application.routes.draw do
  valid_locales_regex = Regexp.compile(Locale.non_english.map(&:code).join("|"))

  def redirect(path, options = { prefix: Whitehall.router_prefix })
    super(options[:prefix] + path)
  end

  def external_redirect(path_prefix, target)
    get path_prefix => redirect(target, prefix: "")
    get "#{path_prefix}/*anything" => redirect(target, prefix: "")
  end

  root to: redirect("/admin/"),
       constraints: lambda { |request|
                      ::Whitehall.admin_host == request.host
                    }

  # This API is documented here:
  # https://github.com/alphagov/whitehall/blob/master/docs/api.md
  namespace "api" do
    resources :governments, only: %i[index show], defaults: { format: :json }
    resources :world_locations, path: "world-locations", only: %i[index show], defaults: { format: :json } do
      resources :worldwide_organisations, path: "organisations", only: [:index], defaults: { format: :json }
    end
    resources :worldwide_organisations, path: "worldwide-organisations", only: [:show], defaults: { format: :json }
  end

  # World locations and Worldwide organisations
  get "/world/organisations/:organisation_id/office" => redirect("/world/organisations/%{organisation_id}", prefix: "")
  get "/world/organisations/:organisation_id/about" => redirect("/world/organisations/%{organisation_id}", prefix: "")
  get "/world/organisations/:id(.:locale)", as: "worldwide_organisation", to: "worldwide_organisations#show", constraints: { locale: valid_locales_regex }

  resources :worldwide_organisations, path: "world/organisations", only: [] do
    get "/about/:id(.:locale)", as: "corporate_information_page", to: "corporate_information_pages#show", constraints: { locale: valid_locales_regex }
    # Dummy path for the sake of polymorphic_path: will always be directed above.
    get "/about(.:locale)", as: "about", to: "_#_", constraints: { locale: valid_locales_regex }

    get "/office/:id(.:locale)", to: "worldwide_offices#show", as: :worldwide_office, constraints: { locale: valid_locales_regex }
  end

  resources :embassies, path: "world/embassies", only: [:index]

  get "/world(.:locale)", as: "world_locations", to: "world_locations#index", constraints: { locale: valid_locales_regex }
  get "/world/:id(.:locale)", as: "world_location", to: "world_locations#show", constraints: { locale: valid_locales_regex }
  get "/world/:world_location_id/news(.:locale)", as: "world_location_news_index", to: "world_location_news#index", constraints: { locale: valid_locales_regex }

  # Override the /auth/failure route in gds-sso, as Slimmer gets
  # involved and causes the page to fail to render
  #
  # This can be removed once Slimmer is removed from Whitehall.
  get "/auth/failure", to: "admin/base#auth_failure", as: "auth_failure_fixed"

  scope Whitehall.router_prefix, shallow_path: Whitehall.router_prefix do
    root to: redirect("/", prefix: ""), via: :get, as: :main_root
    get "/how-government-works" => "home#how_government_works", as: "how_government_works"
    scope "/get-involved" do
      # Controller removed. Whitehall frontend no longer serves these
      # pages however the route is needed to generate path and url
      # helper methods.
      root to: "home#get_involved", as: :get_involved, via: :get

      get "take-part/:id", to: "take_part_pages#show", as: "take_part_page"
    end

    # Past foreign secretaries are currently hard-coded, so this
    # resource falls straight through to views.
    resources :past_foreign_secretaries, path: "/history/past-foreign-secretaries", only: %i[index show]
    # Past chancellors is also hard-coded
    get "history/past-chancellors" => "historic_appointments#past_chancellors"

    # Past foreign secretaries and past chancellors are here for the
    # purposes of reversing URLs in a consistent way from other views.

    # TODO: make these dynamic, they're hard-coded above.
    get "/history/:role" => "historic_appointments#index", constraints: { role: /(past-prime-ministers)|(past-chancellors)|(past-foreign-secretaries)/ }, as: "historic_appointments"
    get "/history/:role/:person_id" => "historic_appointments#show", constraints: { role: /(past-prime-ministers)|(past-chancellors)|(past-foreign-secretaries)/ }, as: "historic_appointment"

    resource :email_signups, path: "email-signup", only: %i[create new]
    get "/email-signup", to: redirect("/")

    get "/tour" => redirect("/tour", prefix: "")

    get "/announcements(.:locale)", as: "announcements", to: "announcements#index", constraints: { locale: valid_locales_regex }
    get "/news/:id(.:locale)", as: "news_article", to: "news_articles#show", constraints: { locale: valid_locales_regex }
    resources :fatality_notices, path: "fatalities", only: [:show]
    get "/news" => redirect("/announcements"), as: "news_articles"
    get "/fatalities" => redirect("/announcements"), as: "fatality_notices"

    get "/latest" => "latest#index", as: "latest"

    get "/publications(.:locale)", as: "publications", to: "publications#index", constraints: { locale: valid_locales_regex }
    get "/publications/:id(.:locale)", as: "publication", to: "_#_", constraints: { locale: valid_locales_regex }
    get "/publications/:publication_id/:id" => "_#_", as: "publication_html_attachment"

    # TODO: Remove when paths can be generated without a routes entry
    get "/case-studies/:id(.:locale)", as: "case_study", to: "case_studies#show", constraints: { locale: valid_locales_regex }
    get "/speeches/:id(.:locale)", as: "speech", to: "speeches#show", constraints: { locale: valid_locales_regex }
    resources :statistical_data_sets, path: "statistical-data-sets", only: [:show]

    get "/speeches" => redirect("/announcements")

    # Controller removed for stats announce show. Whitehall frontend no longer serves these
    # pages however the route is needed to generate path and url
    # helper methods.
    # TODO: Remove `:show` when stats announcement paths can be otherwise generated
    resources :statistics_announcements, path: "statistics/announcements", only: %i[index show]
    get "/statistics(.:locale)", as: "statistics", to: "statistics#index", constraints: { locale: valid_locales_regex }
    get "/statistics/:id(.:locale)", as: "statistic", to: "_#_", constraints: { locale: valid_locales_regex }
    get "/statistics/:statistics_id/:id" => "_#_", as: "statistic_html_attachment"

    get "/consultations/:id(.:locale)", as: "consultation", to: "consultations#show", constraints: { locale: valid_locales_regex }
    resources :consultations, only: %i[index] do
      collection do
        get :open
        get :closed
        get :upcoming
      end
    end
    get "/consultations/:consultation_id/:id" => "_#_", as: "consultation_html_attachment"
    get "/consultations/:consultation_id/outcome/:id" => "_#_", as: "consultation_outcome_html_attachment"
    get "/consultations/:consultation_id/public-feedback/:id" => "_#_", as: "consultation_public_feedback_html_attachment"

    resources :topical_events, path: "topical-events", only: [:show] do
      # Controller removed. Whitehall frontend no longer serves these
      # pages however the route is needed to generate path and url
      # helper methods.
      # TODO: Remove when about page paths can be otherwise generated
      resource :about_pages, path: "about", only: [:show]
    end

    # TODO: Remove when paths can be generated without a routes entry
    get "/collections/:id(.:locale)", as: "document_collection", to: "document_collections#show", constraints: { locale: valid_locales_regex }
    get "/collections" => redirect("/publications")

    get "/organisations/:id(.:locale)", as: "organisation", to: "organisations#show", constraints: { locale: valid_locales_regex }
    resources :organisations, only: [:index]

    resources :organisations, only: [] do
      # No need to forward the locale as collections aren't localised.
      get "/series/:slug(.:locale)" => redirect("/collections/%{slug}"), constraints: { locale: valid_locales_regex }
      get "/series(.:locale)" => redirect("/publications"), constraints: { locale: valid_locales_regex }
      get "/about(.:locale)", as: "corporate_information_pages", to: "corporate_information_pages#index", constraints: { locale: valid_locales_regex }
      get "/about/:id(.:locale)", as: "corporate_information_page", to: "corporate_information_pages#show", constraints: { locale: valid_locales_regex }
    end
    get "/organisations/:organisation_id/groups" => redirect("/organisations/%{organisation_id}")
    get "/organisations/:organisation_id/groups/:id" => redirect("/organisations/%{organisation_id}")
    get "/organisations/:organisation_id/consultations" => redirect("/organisations/%{organisation_id}")
    get "/organisations/:organisation_id/chiefs-of-staff" => redirect("/organisations/%{organisation_id}")
    get "/organisations/:organisation_slug/email-signup", to: "mhra_email_signup#show", as: :mhra_email_signup

    get "/ministers(.:locale)", as: "ministerial_roles", to: "ministerial_roles#index", constraints: { locale: valid_locales_regex }
    get "/ministers/:id(.:locale)", as: "ministerial_role", to: "ministerial_roles#show", constraints: { locale: valid_locales_regex }
    get "/people/:id(.:locale)", as: "person", to: "people#show", constraints: { locale: valid_locales_regex }

    # TODO: Remove `:show` when policy group paths can be otherwise generated
    resources :policy_groups, path: "groups", only: [:show]
    resources :operational_fields, path: "fields-of-operation", only: %i[index show]

    constraints(AdminRequest) do
      namespace :admin do
        root to: "dashboard#index", via: :get

        namespace "export" do
          resources :document, only: %i[show index], defaults: { format: :json } do
            member do
              post :lock
              post :unlock
              post :migrated
            end
          end
        end

        get "find-in-admin-bookmarklet" => "find_in_admin_bookmarklet#index", as: :find_in_admin_bookmarklet_instructions_index
        get "find-in-admin-bookmarklet/:browser" => "find_in_admin_bookmarklet#show", as: :find_in_admin_bookmarklet_instructions
        get "by-content-id/:content_id" => "documents#by_content_id"
        get "/:content_id/needs" => "needs#edit", as: :edit_needs
        patch "/:content_id/needs" => "needs#update", as: :update_needs

        resources :users, only: %i[index show edit update]

        resources :authors, only: [:show]
        resource :document_searches, only: [:show]
        resources :document_collections, path: "collections", except: [:index] do
          resources :document_collection_groups, as: :groups, path: "groups" do
            member { get :delete }
            resource :document_collection_group_membership,
                     as: :members,
                     path: "members",
                     only: [:destroy]
          end
          post "whitehall-member" => "document_collection_group_memberships#create_whitehall_member", as: :new_whitehall_member
          post "non-whitehall-member" => "document_collection_group_memberships#create_non_whitehall_member", as: :new_non_whitehall_member
          post "groups/update_memberships" => "document_collection_groups#update_memberships", as: :update_group_memberships
        end
        resources :organisations do
          resources :groups, except: [:show]
          resources :corporate_information_pages do
            resources :translations, controller: "corporate_information_pages_translations"
          end
          resources :contacts do
            resources :translations, controller: "contact_translations", only: %i[create edit update destroy]
            member do
              post :remove_from_home_page
              post :add_to_home_page
            end
            post :reorder_for_home_page, on: :collection
          end
          resources :social_media_accounts
          resources :translations, controller: "organisation_translations"
          resources :promotional_features do
            resources :promotional_feature_items, as: :items, path: "items", except: [:index]
          end
          member do
            get "/features(.:locale)", as: "features", to: "organisations#features", constraints: { locale: valid_locales_regex }
            get :people
          end
          resources :financial_reports, except: [:show]
          resources :offsite_links
        end
        resources :corporate_information_pages, only: [] do
          resources :attachments, except: [:show] do
            put :order, on: :collection
          end
        end
        resources :policy_groups, path: "groups", except: [:show] do
          resources :attachments do
            put :order, on: :collection
          end
        end
        resources :operational_fields, except: [:show]
        resources :edition_organisations, only: %i[edit update]
        resources :topics, path: "topics" do
          resources :classification_featurings, path: "featurings" do
            put :order, on: :collection
          end
          resources :offsite_links
        end
        resources :topical_events, path: "topical-events" do
          resource :topical_event_about_pages, path: "about"
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
          resource :access_and_opening_time, path: "access_info", except: %i[index show new]
          resources :translations, controller: "worldwide_organisations_translations"
          resources :worldwide_offices, path: "offices", except: [:show] do
            member do
              post :remove_from_home_page
              post :add_to_home_page
            end
            post :reorder_for_home_page, on: :collection
            resource :access_and_opening_time, path: "access_info", except: %i[index show new]
            resources :translations, controller: "worldwide_office_translations", only: %i[create edit update destroy]
          end
          resources :corporate_information_pages do
            resources :translations, controller: "corporate_information_pages_translations"
          end
          resources :social_media_accounts
        end

        resources :editions, only: [:index] do
          resource :tags, only: %i[edit update], controller: :edition_tags
          resource :legacy_associations, only: %i[edit update], controller: :edition_legacy_associations
          resource :world_tags, only: %i[edit update], controller: :edition_world_tags

          collection do
            post :export
            get :confirm_export
          end
          member do
            post :submit, to: "edition_workflow#submit"
            post :revise
            get  :diff
            post :approve_retrospectively, to: "edition_workflow#approve_retrospectively"
            post :reject, to: "edition_workflow#reject"
            post :publish, to: "edition_workflow#publish"
            get  :confirm_force_publish, to: "edition_workflow#confirm_force_publish"
            post :force_publish, to: "edition_workflow#force_publish"
            get  :confirm_unpublish, to: "edition_workflow#confirm_unpublish"
            post :unpublish, to: "edition_workflow#unpublish"
            get  :confirm_unwithdraw, to: "edition_workflow#confirm_unwithdraw"
            post :unwithdraw, to: "edition_workflow#unwithdraw"
            post :schedule, to: "edition_workflow#schedule"
            post :force_schedule, to: "edition_workflow#force_schedule"
            post :unschedule, to: "edition_workflow#unschedule"
            post :convert_to_draft, to: "edition_workflow#convert_to_draft"
            get  :audit_trail, to: "edition_audit_trail#index"
            get  :show_locked, to: "editions#show_locked"
            patch :update_bypass_id
          end
          resources :link_check_reports
          resource :unpublishing, controller: "edition_unpublishing", only: %i[edit update]
          resources :translations, controller: "edition_translations", except: %i[index show]
          resources :editorial_remarks, only: %i[new create], shallow: true
          resources :fact_check_requests, only: %i[show create edit update], shallow: true
          resource :document_sources, path: "document-sources", except: [:show]
          resources :attachments, except: [:show] do
            put :order, on: :collection
            put :update_many, on: :collection, constraints: { format: "json" }
          end
          resources :bulk_uploads, except: %i[show edit update] do
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
          resource :tags, only: %i[edit update], controller: :statistics_announcement_tags
          resources :statistics_announcement_date_changes, as: "changes", path: "changes"
          resource :statistics_announcement_unpublishings, as: "unpublish", path: "unpublish", only: %i[new create]
        end

        resources :suggestions, only: [:index]

        resources :publications, except: [:index]

        resources :news_articles, path: "news", except: [:index]
        resources :fatality_notices, path: "fatalities", except: [:index]
        resources :consultations, except: [:index] do
          resource :outcome, controller: "responses", type: "ConsultationOutcome", except: %i[new destroy]
          resource :public_feedback, controller: "responses", type: "ConsultationPublicFeedback", except: %i[new destroy]
        end
        resources :responses, only: :none do
          resources :attachments do
            put :order, on: :collection
          end
        end

        resources :speeches, except: [:index]
        resources :statistical_data_sets, path: "statistical-data-sets", except: [:index]
        resources :detailed_guides, path: "detailed-guides", except: [:index]
        resources :people do
          resources :translations, controller: "person_translations"
          resources :historical_accounts
        end
        resource :cabinet_ministers, only: %i[show update]
        resources :roles, except: [:show] do
          resources :role_appointments, only: %i[new create edit update destroy], shallow: true
          resources :translations, controller: "role_translations"
        end
        resources :world_locations, only: %i[index edit update show] do
          member do
            get "/features(.:locale)", as: "features", to: "world_locations#features", constraints: { locale: valid_locales_regex }
          end
          resources :translations, controller: "world_location_translations"
          resources :offsite_links
        end
        resources :feature_lists, only: [:show] do
          post :reorder, on: :member

          resources :features, only: %i[new create] do
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

        scope "/get-involved" do
          root to: "get_involved#index", as: :get_involved, via: :get
          resources :take_part_pages, except: [:show] do
            post :reorder, on: :collection
          end
        end

        resources :sitewide_settings
        post "/link-checker-api-callback" => "link_checker_api#callback"
      end
    end

    get "/policy-topics" => redirect("/topics")

    get "/placeholder" => "placeholder#show", as: :placeholder
  end

  # TODO: the organisations controller has been removed but this route is still required to get the relevant helper methods. This can be removed once new helpers have been created.
  get "/courts-tribunals/:id(.:locale)", as: "court", to: "organisations#show", courts_only: true, constraints: { locale: valid_locales_regex }

  get "/healthcheck/live", to: proc { [200, {}, %w[OK]] }
  get "/healthcheck/ready", to: GovukHealthcheck.rack_response(
    GovukHealthcheck::ActiveRecord,
    GovukHealthcheck::SidekiqRedis,
    GovukHealthcheck::RailsCache,
    Healthcheck::S3,
  )

  get "healthcheck/overdue" => "healthcheck#overdue"
  get "healthcheck/unenqueued_scheduled_editions" => "healthcheck#unenqueued_scheduled_editions"

  # TODO: Remove when paths for new content can be generated without a route helper
  get "/guidance/:id(.:locale)", as: "detailed_guide", to: "detailed_guides#show", constraints: { id: /[A-z0-9\-]+/, locale: valid_locales_regex }

  get "/government/uploads/system/uploads/attachment_data/file/:id/*file.:extension/preview" => "csv_preview#show", as: :csv_preview

  resources :broken_links_export_request, path: "/export/broken_link_reports", param: :export_id, only: [:show]
  resources :document_list_export_request, path: "/export/:document_type_slug", param: :export_id, only: [:show]

  if Rails.env.development?
    class DisableSlimmer
      def initialize(app)
        @app = app
      end

      def call(*args)
        status, headers, body = @app.call(*args)
        headers[Slimmer::Headers::SKIP_HEADER] = "true"

        [status, headers, body]
      end
    end

    require "sidekiq/web"
    mount DisableSlimmer.new(Sidekiq::Web), at: "/sidekiq"
  end

  mount GovukPublishingComponents::Engine, at: "/component-guide" if Rails.env.development?
end
