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
        get "schedule/edit", to: "documents/schedule#edit", as: :schedule_edit
        put "schedule", to: "documents/schedule#update", as: :update_schedule
        patch "schedule", to: "documents/schedule#update"
      end
      resources :editions, only: %i[new create destroy], path_names: { new: ":block_type/new" } do
        member do
          resources :workflow, only: %i[show update], controller: "editions/workflow", param: :step
          resources :host_content, only: %i[preview], controller: "editions/host_content", param: :id do
            get :preview, to: "editions/host_content#preview"
          end
        end
      end
    end
  end
end
