ObjectStore::Engine.routes.draw do
  namespace :object_store, path: "/" do
    root to: "content_block_editions#index", via: :get

    resources :content_block_editions do
      get "new/:block_type", to: "content_block_editions#new", on: :collection, as: :new
      get ":block_type/schema", to: "content_block_editions#info", on: :collection, as: :info
    end
  end
end
