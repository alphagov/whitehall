ContentBlockManager::Engine.routes.draw do
  namespace :content_block_manager, path: "/" do
    root to: "content_block/documents#index", via: :get

    resources :users, only: %i[show]

    namespace :content_block, path: "content-block" do
      get "content-id/:content_id", to: "documents#content_id", as: :content_id
      resources :documents, only: %i[index show new], path_names: { new: "(:block_type)/new" }, path: "" do
        collection do
          post :new_document_options_redirect
        end
        resources :editions, only: %i[new create]
        resources :embedded_objects, only: %i[new create], path_names: { new: "(:object_type)/new" }, controller: "documents/embedded_objects"
        get "schedule/edit", to: "documents/schedule#edit", as: :schedule_edit
        put "schedule", to: "documents/schedule#update", as: :update_schedule
        patch "schedule", to: "documents/schedule#update"
      end
      resources :editions, only: %i[new create destroy], path_names: { new: ":block_type/new" } do
        member do
          resources :workflow, only: %i[show update], controller: "editions/workflow", param: :step do
            collection do
              get :cancel, to: "editions/workflow#cancel"
            end
          end
          get "embedded-objects/:object_type/new", to: "editions/embedded_objects#new", as: :new_embedded_object
          post "embedded-objects/:object_type", to: "editions/embedded_objects#create", as: :create_embedded_object
          get "embedded-objects/:object_type/:object_title/edit", to: "editions/embedded_objects#edit", as: :edit_embedded_object
          put "embedded-objects/:object_type/:object_title", to: "editions/embedded_objects#update", as: :embedded_object
          get "embedded-objects/:object_type/:object_title/review", to: "editions/embedded_objects#review", as: :review_embedded_object
          post "embedded-objects/:object_type/:object_title/publish", to: "editions/embedded_objects#publish", as: :publish_embedded_object
          get :preview, to: "editions/host_content#preview", path: "host-content/:host_content_id/preview", as: :host_content_preview
        end
      end
    end
  end
end
