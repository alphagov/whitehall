ContentObjectStore::Engine.routes.draw do
  namespace :content_object_store, path: "/" do
    resources :health_check, path: "health-check", only: %i[index]
    root to: "health_check#index", via: :get

    namespace :content_block, path: "content-block" do
      resources :documents, only: %i[index show], path_names: { new: "(:block_type)/new" }
      resources :editions, only: %i[new create edit update], path_names: { new: "(:block_type)/new" }
    end
  end
end
