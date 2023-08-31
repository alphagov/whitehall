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

      get "find-in-admin-bookmarklet" => "find_in_admin_bookmarklet#index", as: :find_in_admin_bookmarklet_instructions_index
      get "find-in-admin-bookmarklet/:browser" => "find_in_admin_bookmarklet#show", as: :find_in_admin_bookmarklet_instructions
      get "by-content-id/:content_id" => "documents#by_content_id"
      get "/:content_id/needs" => "needs#edit", as: :edit_needs
      patch "/:content_id/needs" => "needs#update", as: :update_needs

      resources :users, only: %i[index show edit update]

      resources :documents, only: [] do
        resources :review_reminders, only: %i[new create edit update]
      end

      resources :authors, only: [:show]
      resource :document_searches, only: [:show]
      resources :document_collections, path: "collections", except: [:index] do
        resources :document_collection_groups, as: :groups, path: "groups" do
          member { get :confirm_destroy }
          resource :document_collection_group_membership,
                   as: :members,
                   path: "members",
                   only: [:destroy]
          resources :document_collection_group_memberships, path: "members", only: %i[index destroy] do
            get :confirm_destroy, on: :member
          end
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
          resources :translations, controller: "contact_translations", only: %i[create edit update destroy index] do
            member do
              get :confirm_destroy
            end
          end
          get :reorder, on: :collection
          member do
            post :remove_from_home_page
            post :add_to_home_page
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
          get :choose_main_office
          put :set_main_office
          get :confirm_destroy
          get :about, to: "worldwide_organisations_about#show", as: :about
          get :history, to: "worldwide_organisations_history#index", as: :history
        end
        resource :access_and_opening_time, path: "access_info", except: %i[index show new]
        resources :translations, controller: "worldwide_organisations_translations" do
          get :confirm_destroy, on: :member
        end

        resources :worldwide_offices, path: "offices", except: [:show] do
          member do
            get :confirm_destroy
            post :remove_from_home_page
            post :add_to_home_page
          end
          get :reorder, on: :collection
          post :reorder_for_home_page, on: :collection
          resources :translations, controller: "worldwide_office_translations", only: %i[create edit update destroy index] do
            get :confirm_destroy, on: :member
          end
        end
        resources :corporate_information_pages do
          resources :translations, controller: "corporate_information_pages_translations"
        end
        resources :social_media_accounts do
          get :confirm_destroy, on: :member
        end
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

  get "/healthcheck/live", to: proc { [200, {}, %w[OK]] }
  get "/healthcheck/ready", to: GovukHealthcheck.rack_response(
    GovukHealthcheck::ActiveRecord,
    GovukHealthcheck::SidekiqRedis,
    GovukHealthcheck::RailsCache,
    Healthcheck::S3,
  )

  get "healthcheck/overdue" => "healthcheck#overdue"
  get "healthcheck/unenqueued_scheduled_editions" => "healthcheck#unenqueued_scheduled_editions"

  resources :broken_links_export_request, path: "/export/broken_link_reports", param: :export_id, only: [:show]
  resources :document_list_export_request, path: "/export/:document_type_slug", param: :export_id, only: [:show]

  mount SidekiqGdsSsoMiddleware, at: "/sidekiq"

  mount GovukPublishingComponents::Engine, at: "/component-guide" unless Rails.env.production?
end
