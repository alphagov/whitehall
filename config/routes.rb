require "sidekiq/web"

Whitehall::Application.routes.draw do
  valid_locales_regex = Regexp.compile(Locale.non_english.map(&:code).join("|"))

  def redirect(path, options = { prefix: Whitehall.router_prefix })
    super(options[:prefix] + path)
  end

  root to: redirect("/admin/")

  scope Whitehall.router_prefix, shallow_path: Whitehall.router_prefix do
    root to: redirect("/", prefix: ""), via: :get, as: :main_root

    namespace :admin do
      root to: "dashboard#index", via: :get

      get "bookmarklets" => "bookmarklets#index", as: :bookmarklets_instructions_index
      get "by-content-id/:content_id" => "documents#by_content_id"

      concern :confirmable_destroy do
        get :confirm_destroy, on: :member
      end

      concern :attachable do
        resources :attachments, except: [:show], concerns: :confirmable_destroy do
          put :order, on: :collection
          get :reorder, on: :collection
        end
        resources :file_attachments, except: %i[index show], concerns: :confirmable_destroy
        resources :bulk_uploads, except: %i[show edit update new] do
          post :upload_files, on: :collection
          get :set_titles, on: :member
        end
      end

      # to include additional attachment types other than `file`
      # include the following concerns for each allowed type
      # as well as the `attachable` concern
      concern :attachable_with_html do
        resources :html_attachments, except: %i[index show], concerns: :confirmable_destroy
      end

      concern :attachable_with_external do
        resources :external_attachments, except: %i[index show], concerns: :confirmable_destroy
      end

      resources :users, only: %i[index show edit update]

      scope :republishing do
        root to: "republishing#index", as: :republishing_index, via: :get
        scope :page do
          get "/:page_slug/confirm" => "republishing#confirm_page", as: :republishing_page_confirm
          post "/:page_slug/republish" => "republishing#republish_page", as: :republishing_page_republish
        end
        scope :organisation do
          get "/find" => "republishing#find_organisation", as: :republishing_organisation_find
          post "/search" => "republishing#search_organisation", as: :republishing_organisation_search
          get "/:organisation_slug/confirm" => "republishing#confirm_organisation", as: :republishing_organisation_confirm
          post "/:organisation_slug/republish" => "republishing#republish_organisation", as: :republishing_organisation_republish
        end
        scope :person do
          get "/find" => "republishing#find_person", as: :republishing_person_find
          post "/search" => "republishing#search_person", as: :republishing_person_search
          get "/:person_slug/confirm" => "republishing#confirm_person", as: :republishing_person_confirm
          post "/:person_slug/republish" => "republishing#republish_person", as: :republishing_person_republish
        end
        scope :role do
          get "/find" => "republishing#find_role", as: :republishing_role_find
          post "/search" => "republishing#search_role", as: :republishing_role_search
          get "/:role_slug/confirm" => "republishing#confirm_role", as: :republishing_role_confirm
          post "/:role_slug/republish" => "republishing#republish_role", as: :republishing_role_republish
        end
        scope :document do
          get "/find" => "republishing#find_document", as: :republishing_document_find
          post "/search" => "republishing#search_document", as: :republishing_document_search
          get "/:document_slug/confirm" => "republishing#confirm_document", as: :republishing_document_confirm
          post "/:document_slug/republish" => "republishing#republish_document", as: :republishing_document_republish
        end
        scope :bulk do
          scope "by-type" do
            get "/new" => "bulk_republishing#new_by_type", as: :bulk_republishing_by_type_new
            post "/new" => "bulk_republishing#new_by_type_redirect", as: :bulk_republishing_by_type_new_redirect
            get "/:content_type/confirm" => "bulk_republishing#confirm_by_type", as: :bulk_republishing_by_type_confirm
            post "/:content_type/republish" => "bulk_republishing#republish_by_type", as: :bulk_republishing_by_type_republish
          end
          scope "documents-by-organisation" do
            get "/new" => "bulk_republishing#new_documents_by_organisation", as: :bulk_republishing_documents_by_organisation_new
            post "/search" => "bulk_republishing#search_documents_by_organisation", as: :bulk_republishing_documents_by_organisation_search
            get "/:organisation_slug/confirm" => "bulk_republishing#confirm_documents_by_organisation", as: :bulk_republishing_documents_by_organisation_confirm
            post "/:organisation_slug/republish" => "bulk_republishing#republish_documents_by_organisation", as: :bulk_republishing_documents_by_organisation_republish
          end
          scope "documents-by-content-ids" do
            get "/new" => "bulk_republishing#new_documents_by_content_ids", as: :bulk_republishing_documents_by_content_ids_new
            post "/search" => "bulk_republishing#search_documents_by_content_ids", as: :bulk_republishing_documents_by_content_ids_search
            get "/:content_ids/confirm" => "bulk_republishing#confirm_documents_by_content_ids", as: :bulk_republishing_documents_by_content_ids_confirm
            post "/:content_ids/republish" => "bulk_republishing#republish_documents_by_content_ids", as: :bulk_republishing_documents_by_content_ids_republish
          end
          get "/:bulk_content_type/confirm" => "bulk_republishing#confirm", as: :bulk_republishing_confirm
          post "/:bulk_content_type/republish" => "bulk_republishing#republish", as: :bulk_republishing_republish
        end
      end

      get "/retagging" => "retagging#index", as: :retagging_index
      post "/retagging" => "retagging#preview", as: :retagging_preview
      post "/retagging/publish" => "retagging#publish", as: :retagging_publish

      resources :documents, only: [] do
        resources :review_reminders, only: %i[new create edit update destroy] do
          get :confirm_destroy, on: :member
        end
      end

      resources :authors, only: [:show]

      resources :document_collections, path: "collections", except: [:index] do
        resources :document_collection_groups, as: :groups, path: "groups" do
          get :search_options, to: "document_collection_group_document_search#search_options"
          post :search_options, to: "document_collection_group_document_search#search"

          get :add_by_title, to: "document_collection_group_document_search#add_by_title"
          get :add_by_url, to: "document_collection_group_document_search#add_by_url"
          post "govuk-url-member" => "document_collection_group_memberships#create_member_by_govuk_url", as: :govuk_url_member

          get :confirm_destroy, on: :member
          get :reorder, on: :collection
          put :order, on: :collection

          resources :document_collection_group_memberships, path: "members", only: %i[index destroy] do
            get :confirm_destroy, on: :member
            get :reorder, on: :collection
            put :order, on: :collection
          end
        end
        get "email-subscriptions" => "document_collection_email_subscriptions#edit", as: :edit_email_subscription
        post "whitehall-member" => "document_collection_group_memberships#create_whitehall_member", as: :new_whitehall_member
      end

      resources :organisations do
        resources :groups, except: [:show]
        resources :corporate_information_pages do
          resources :translations, controller: "corporate_information_pages_translations"
        end
        resources :contacts do
          resources :translations, controller: "contact_translations", only: %i[create edit update destroy index] do
            member do
              get :confirm_destroy
            end
          end
          get :reorder, on: :collection
          member do
            get :confirm_destroy
          end
          post :reorder_for_home_page, on: :collection
        end
        resources :social_media_accounts do
          get :confirm_destroy, on: :member
        end
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
        resources :people, controller: "organisation_people", only: [:index] do
          get :reorder, on: :collection
          put :order, on: :collection
        end
        member do
          get :about, to: "organisations_about#show", as: :about
          get "/features(.:locale)", as: "features", to: "organisations#features", constraints: { locale: valid_locales_regex }
          get :confirm_destroy
        end
        resources :offsite_links do
          get :confirm_destroy, on: :member
        end
      end
      resources :corporate_information_pages, concerns: :attachable
      resources :policy_groups, path: "groups", except: [:show], concerns: :attachable do
        get :confirm_destroy, on: :member
      end
      resources :operational_fields, except: [:show]

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

      resources :editions, only: [:index], concerns: %i[attachable attachable_with_html attachable_with_external] do
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
          get  :confirm_publish, to: "edition_workflow#confirm_publish"
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
          patch :update_image_display_option, controller: "case_studies"
          get :confirm_destroy
          get :edit_access_limited, to: "edition_access_limited#edit"
          patch :update_access_limited, to: "edition_access_limited#update"
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
        resources :images, controller: "edition_images", only: %i[create destroy edit update index] do
          get :confirm_destroy, on: :member
        end
        resources :lead_images, controller: "edition_lead_images", only: %i[update]
        resources :social_media_accounts, only: %i[create destroy edit index new update], controller: "editionable_social_media_accounts" do
          get :confirm_destroy, on: :member
          collection do
            get :reorder
            put :order
          end
        end
      end

      get "/editions/:id" => "editions#show"

      get "/whats-new" => "whats_new#index", as: :whats_new

      get "/new-document" => "new_document#index", as: :new_document
      get :new_document_options, to: "new_document#new_document_options_redirect"
      post :new_document_options, to: "new_document#new_document_options_redirect"

      get "/more" => "more#index", as: :more

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

      resources :publications, except: [:index]

      resources :standard_editions, path: "standard-editions", except: [:index] do
        get :choose_type, on: :collection, as: :choose_type

        resources :translations, controller: "standard_edition_translations", except: %i[index show create] do
          get :confirm_destroy, on: :member
        end
      end
      resources :landing_pages, path: "landing-pages", except: [:index]

      resources :news_articles, path: "news", except: [:index]
      resources :fatality_notices, path: "fatalities", except: [:index]
      resources :consultations, except: [:index] do
        resource :outcome, controller: "consultation_responses", type: "ConsultationOutcome", except: %i[new destroy]
        resource :public_feedback, controller: "consultation_responses", type: "ConsultationPublicFeedback", except: %i[new destroy]
      end

      resources :consultation_responses, concerns: %i[attachable attachable_with_html attachable_with_external]
      resources :call_for_evidence_responses, concerns: %i[attachable attachable_with_html attachable_with_external]

      resources :calls_for_evidence, path: "calls-for-evidence", except: [:index] do
        resource :outcome, controller: "call_for_evidence_responses", type: "CallForEvidenceOutcome", except: %i[new destroy], concerns: %i[attachable attachable_with_html attachable_with_external]
      end

      resources :speeches, except: [:index]
      resources :statistical_data_sets, path: "statistical-data-sets", except: [:index]
      resources :worldwide_organisations, path: "worldwide-organisations", except: [:index] do
        resources :pages, controller: "worldwide_organisation_pages" do
          get :confirm_destroy, on: :member

          resources :translations, controller: "worldwide_organisation_page_translations", only: %i[create edit update destroy index] do
            get :confirm_destroy, on: :member
          end
        end

        resources :worldwide_offices, path: "offices", except: [:show] do
          member do
            get :confirm_destroy
          end
          get :reorder, on: :collection
          post :reorder_for_home_page, on: :collection
          resources :translations, controller: "worldwide_office_translations", only: %i[create edit update destroy index] do
            get :confirm_destroy, on: :member
          end
        end
      end

      resources :worldwide_organisation_pages, concerns: %i[attachable attachable_with_external]

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

      resource :cabinet_ministers, only: %i[show] do
        get :reorder_cabinet_minister_roles
        patch :order_cabinet_minister_roles

        get :reorder_also_attends_cabinet_roles
        patch :order_also_attends_cabinet_roles

        get :reorder_whip_roles
        patch :order_whip_roles

        get :reorder_ministerial_organisations
        patch :order_ministerial_organisations
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

      resources :sitewide_settings
      resource :emergency_banner, controller: "emergency_banner" do
        get :confirm_destroy
      end
      post "/link-checker-api-callback" => "link_checker_api#callback"
    end
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

  resources :document_list_export_request, path: "/export/:document_type_slug", param: :export_id, only: [:show]

  scope via: :all do
    match "/400", to: "admin/errors#bad_request"
    match "/403", to: "admin/errors#forbidden"
    match "/404", to: "admin/errors#not_found"
    match "/422", to: "admin/errors#unprocessable_content"
    match "/500", to: "admin/errors#internal_server_error"
  end

  mount SidekiqGdsSsoMiddleware, at: "/sidekiq"

  mount Flipflop::Engine => "/flipflop"

  mount GovukPublishingComponents::Engine, at: "/component-guide"
end
