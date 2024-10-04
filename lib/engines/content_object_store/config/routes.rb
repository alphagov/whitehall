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
          post :publish, to: "workflow#publish"
          patch :update, to: "workflow#update"
          post :edit
        end
      end
    end
  end
end
