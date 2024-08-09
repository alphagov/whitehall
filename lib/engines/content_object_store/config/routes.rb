ContentObjectStore::Engine.routes.draw do
  namespace :content_object_store, path: "/" do
    root to: "content_block/documents#index", via: :get

    namespace :content_block, path: "content-block" do
      resources :documents, only: %i[index show], path_names: { new: "(:block_type)/new" }
      resources :editions, only: %i[new create edit update], path_names: { new: "(:block_type)/new" } do
        member do
          get :review
          get :review_links
          post :review_links
          post :publish, to: "workflow#publish"
        end
      end
    end
  end
end
