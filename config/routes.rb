class AdminRequest
  def self.matches?(request)
    # Allow access to all routes in development, and restrict to the
    # internal or external admin host otherwise.
    !Rails.env.production? || valid_admin_host?(request.host)
  end

  def self.valid_admin_host?(host)
    host.starts_with?("whitehall-admin")
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
       constraints: ->(request) { AdminRequest.valid_admin_host?(request.host) }

  rack_404 = proc { [404, {}, ["Not found"]] }

  # This API is documented here:
  # https://github.com/alphagov/whitehall/blob/master/docs/api.md
  namespace "api" do
    resources :governments, only: %i[index show], defaults: { format: :json }
    resources :world_locations, path: "world-locations", only: %i[index show], defaults: { format: :json } do
      resources :worldwide_organisations, path: "organisations", only: [:index], defaults: { format: :json }
    end
    resources :worldwide_organisations, path: "worldwide-organisations", only: [:show], defaults: { format: :json }
  end

  # Override the /auth/failure route in gds-sso, as Slimmer gets
  # involved and causes the page to fail to render
  #
  # This can be removed once Slimmer is removed from Whitehall.
  get "/auth/failure", to: "admin/base#auth_failure", as: "auth_failure_fixed"

  # Routes rendered by Whitehall to the public under the /world scope
  scope "/world" do
    get "(.:locale)", as: "world_locations", to: "world_locations#index", constraints: { locale: valid_locales_regex }

    get "/organisations/:id(.:locale)", as: "worldwide_organisation", to: "worldwide_organisations#show", constraints: { locale: valid_locales_regex }
    resources :worldwide_organisations, path: "organisations", only: [] do
      get "/:organisation_id/about" => redirect("/world/organisations/%{organisation_id}", prefix: "")
      get "/:organisation_id/office" => redirect("/world/organisations/%{organisation_id}", prefix: "")
      get "/:organisation_id/about(.:locale)", as: "about", constraints: { locale: valid_locales_regex }, to: rack_404
      get "/about/:id(.:locale)", as: "corporate_information_page", to: "corporate_information_pages#show", constraints: { locale: valid_locales_regex }
    end
  end

  # Routes rendered by Whitehall to the public under the /government scope (specified in lib/whitehall.rb under the `router_prefix` method)
  scope Whitehall.router_prefix, shallow_path: Whitehall.router_prefix do
    root to: redirect("/", prefix: ""), via: :get, as: :main_root

    constraints(AdminRequest) do
      namespace :admin do
        root to: "dashboard#index", via: :get

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
          resources :translations, controller: "organisation_translations" do
            get :confirm_destroy, on: :member
          end
          resources :promotional_features do
            get :reorder, on: :collection
            get :confirm_destroy, on: :member
            patch :update_order, on: :collection
            resources :promotional_feature_items, as: :items, path: "items", except: [:index] do
              get :confirm_destroy, on: :member
            end
          end
          member do
            get "/features(.:locale)", as: "features", to: "organisations#features", constraints: { locale: valid_locales_regex }
            get :people
          end
          resources :financial_reports, except: [:show] do
            get :confirm_destroy, on: :member
          end
          resources :offsite_links do
            get :confirm_destroy, on: :member
          end
        end
        resources :corporate_information_pages, only: [] do
          resources :attachments, except: [:show] do
            put :order, on: :collection
          end
        end
        resources :policy_groups, path: "groups", except: [:show] do
          get :confirm_destroy, on: :member
          resources :attachments do
            put :order, on: :collection
            get :confirm_destroy, on: :member
          end
        end
        resources :operational_fields, except: [:show]
        resources :edition_organisations, only: %i[edit update]

        resources :topical_events, path: "topical-events" do
          resource :topical_event_about_pages, path: "about"
          resources :topical_event_featurings, path: "featurings" do
            get :reorder, on: :collection
            put :order, on: :collection
            get :confirm_destroy, on: :member
          end
          resources :topical_event_organisations, path: "organisations" do
            get :reorder, on: :collection
            put :order, on: :collection
            get :toggle_lead, on: :member
          end
          resources :offsite_links do
            get :confirm_destroy, on: :member
          end
          get :confirm_destroy, on: :member
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
          resources :change_notes, controller: :edition_change_notes do
            get :confirm_destroy, on: :member
          end

          get :edit_slug, on: :member, controller: :edition_slug
          patch :update_slug, on: :member, controller: :edition_slug

          collection do
            post :export
            get :confirm_export
          end
          member do
            post :submit, to: "edition_workflow#submit"
            post :revise
            get  :diff
            get  :confirm_approve_retrospectively, to: "edition_workflow#confirm_approve_retrospectively"
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
            get  :confirm_force_schedule, to: "edition_workflow#confirm_force_schedule"
            post :force_schedule, to: "edition_workflow#force_schedule"
            get :confirm_unschedule, to: "edition_workflow#confirm_unschedule"
            post :unschedule, to: "edition_workflow#unschedule"
            get :audit_trail, to: "edition_audit_trail#index"
            get :document_history, to: "edition_document_history#index"
            patch :update_bypass_id
            patch :update_image_display_option
            get :confirm_destroy
          end
          resources :link_check_reports
          resource :unpublishing, controller: "edition_unpublishing", only: %i[edit update]
          resources :translations, controller: "edition_translations", except: %i[index show] do
            get :confirm_destroy, on: :member
          end
          resources :editorial_remarks, only: %i[new create destroy], shallow: true do
            get :confirm_destroy, on: :member
          end
          resources :fact_check_requests, only: %i[show create edit update], shallow: true
          resources :attachments, except: [:show] do
            put :order, on: :collection
            get :reorder, on: :collection
            get :confirm_destroy, on: :member
          end
          resources :bulk_uploads, except: %i[show edit update] do
            post :upload_zip, on: :collection
            get :set_titles, on: :member
          end
          resources :images, controller: "edition_images", only: %i[create destroy edit update index] do
            get :confirm_destroy, on: :member
          end
        end

        get "/editions/:id" => "editions#show"

        get "/whats-new" => "whats_new#index", as: :whats_new

        resources :statistics_announcements, except: [:destroy] do
          member do
            get :cancel
            post :publish_cancellation
            get :cancel_reason
            patch :update_cancel_reason
          end
          resource :tags, only: %i[edit update], controller: :statistics_announcement_tags
          resources :statistics_announcement_date_changes, as: "changes", path: "changes"
          resource :statistics_announcement_unpublishings, as: "unpublish", path: "unpublish", only: %i[new create]
          resources :statistics_announcement_publications, as: "publication", path: "publication", only: %i[index] do
            get "connect"
          end
        end

        resources :suggestions, only: [:index]

        resources :publications, except: [:index]

        resources :news_articles, path: "news", except: [:index]
        resources :fatality_notices, path: "fatalities", except: [:index]
        resources :consultations, except: [:index] do
          resource :outcome, controller: "consultation_responses", type: "ConsultationOutcome", except: %i[new destroy]
          resource :public_feedback, controller: "consultation_responses", type: "ConsultationPublicFeedback", except: %i[new destroy]
        end

        resources :consultation_responses, only: :none do
          resources :attachments do
            put :order, on: :collection
            get :confirm_destroy, on: :member
            get :reorder, on: :collection
          end
        end

        resources :calls_for_evidence, path: "calls-for-evidence", except: [:index] do
          resource :outcome, controller: "call_for_evidence_responses", type: "CallForEvidenceOutcome", except: %i[new destroy]
        end

        resources :call_for_evidence_responses, only: :none do
          resources :attachments do
            put :order, on: :collection
            get :confirm_destroy, on: :member
            get :reorder, on: :collection
          end
        end

        resources :speeches, except: [:index]
        resources :statistical_data_sets, path: "statistical-data-sets", except: [:index]
        resources :detailed_guides, path: "detailed-guides", except: [:index]
        resources :people do
          resources :translations, controller: "person_translations" do
            get :confirm_destroy, on: :member
          end
          resources :historical_accounts do
            get :confirm_destroy, on: :member
          end
          get :reorder_role_appointments, on: :member
          patch :update_order_role_appointments, on: :member
          get :confirm_destroy, on: :member
        end

        resource :cabinet_ministers, only: %i[show update] do
          get :reorder_cabinet_minister_roles, on: :member
          get :reorder_also_attends_cabinet_roles, on: :member
          get :reorder_whip_roles, on: :member
          get :reorder_ministerial_organisations, on: :member
        end

        resources :roles, except: [:show] do
          get :confirm_destroy, on: :member
          resources :role_appointments, only: %i[new create edit update destroy], shallow: true do
            get :confirm_destroy, on: :member
          end
          resources :translations, controller: "role_translations" do
            get :confirm_destroy, on: :member
          end
        end

        resources :world_location_news, only: %i[index edit update show] do
          member do
            get "/features(.:locale)", as: "features", to: "world_location_news#features", constraints: { locale: valid_locales_regex }
          end
          resources :translations, controller: "world_location_news_translations" do
            get :confirm_destroy, on: :member
          end
          resources :offsite_links do
            get :confirm_destroy, on: :member
          end
        end

        resources :feature_lists, only: [:show] do
          get :reorder, on: :member
          post :update_order, on: :member

          resources :features, only: %i[new create] do
            get :confirm_unfeature, on: :member
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
            get :confirm_destroy, on: :member
            get :update_order, on: :collection
          end
        end

        resources :sitewide_settings
        post "/link-checker-api-callback" => "link_checker_api#callback"
      end
    end

    get "/policy-topics" => redirect("/topics")

    get "/placeholder" => "placeholder#show", as: :placeholder
  end

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
  get "/guidance/:id(.:locale)", as: "detailed_guide", constraints: { id: /[A-z0-9-]+/, locale: valid_locales_regex }, to: rack_404

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

  mount GovukPublishingComponents::Engine, at: "/component-guide" unless Rails.env.production?
end
