ContentObjectStore::Engine.routes.draw do
  namespace :content_object_store, path: "/" do
    resources :health_check, path: "health-check", only: %i[index]
    root to: "health_check#index", via: :get

    resources :content_block_documents, path: "content-block-documents",
                                        only: %i[index show],
                                        path_names: { new: "(:block_type)/new" }
    resources :content_block_editions, path: "content-block-editions",
                                       only: %i[index new create show edit update],
                                       path_names: { new: "(:block_type)/new" }
  end
end
