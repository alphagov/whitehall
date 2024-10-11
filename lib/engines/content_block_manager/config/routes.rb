ContentBlockManager::Engine.routes.draw do
  namespace :content_block_manager, path: "/" do
    root to: "content_block/documents#index", via: :get

    namespace :content_block, path: "content-block" do
      resources :documents, only: %i[index show new], path_names: { new: "(:block_type)/new" }, path: "" do
        collection do
          post :new_document_options_redirect
        end
        resources :editions, only: %i[new create]
      end
      resources :editions, only: %i[new create destroy], path_names: { new: ":block_type/new" } do
        member do
          resources :workflow, only: %i[show update], controller: "editions/workflow", param: :step
        end
      end
    end
  end
end
