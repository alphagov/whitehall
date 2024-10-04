ContentObjectStore::Engine.routes.draw do
  namespace :content_object_store, path: "/" do
    root to: "content_block/documents#index", via: :get

    namespace :content_block, path: "content-block" do
      resources :documents, only: %i[index show new create], path_names: { new: "(:block_type)/new" }, path: "" do
        collection do
          post :new_document_options_redirect
        end
        resources :editions, only: %i[new create]
      end
      resources :editions, only: %i[new create edit update], path_names: { new: "(:block_type)/new" } do
        member do
          get :review
          post :edit
          resources :steps, only: %i[show update], controller: "editions/steps", param: :step
          post :publish, to: "editions/workflow#publish"
        end
      end
    end
  end
end
